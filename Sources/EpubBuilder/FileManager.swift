import Foundation

extension FileManager {
    func ensureFileExists(at url: URL) throws {
        if !fileExists(atPath: url.path) {
            createFile(atPath: url.path, contents: nil)
        }
    }

    func ensureDirectoryExists(at url: URL) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}

protocol FileSystemItem {
    func addToFileStructure(_ structure: inout FileSystemNode)
}

public struct File: FileSystemItem, Equatable {
    public var name: String
    public var data: Data?

    public init(_ name: String, data: Data? = nil) {
        self.name = name
        self.data = data
    }

    public init(_ name: String, text: String) {
        self.name = name
        self.data = text.data(using: .utf8)
    }

    func addToFileStructure(_ structure: inout FileSystemNode) {
        structure.files.append(self)
    }
}

public struct Folder: FileSystemItem, Equatable {
    public var name: String
    public var node: FileSystemNode
    public var files: [File] {
        node.files
    }
    public var subfolders: [Folder] {
        node.folders
    }

    public init(_ name: String, node: FileSystemNode) {
        self.name = name
        self.node = node
    }

    public init(_ name: String, @FileSystemNodeBuilder _ content: () -> FileSystemNode) {
        self.init(name, node: content())
    }

    public func addToFileStructure(_ structure: inout FileSystemNode) {
        structure.folders.append(self)
    }
}

public struct FileSystemNode: FileSystemItem, Equatable {
    public var files: [File]
    public var folders: [Folder]

    public init(files: [File] = [], folders: [Folder] = []) {
        self.files = files
        self.folders = folders
    }

    public init(@FileSystemNodeBuilder _ content: () -> FileSystemNode) {
        self = content()
    }

    public static func + (lhs: FileSystemNode, rhs: FileSystemNode) -> FileSystemNode {
        var combined = FileSystemNode()
        combined.files = lhs.files + rhs.files
        combined.folders = lhs.folders + rhs.folders
        return combined
    }

    public func addToFileStructure(_ structure: inout FileSystemNode) {
        structure.files += files
        structure.folders += folders
    }
}

public extension FileSystemNode {
    func write(to url: URL) throws {
        let fileManager = FileManager.default
        for file in files {
            let fileURL = url.appendingPathComponent(file.name)
            try fileManager.ensureFileExists(at: fileURL)
            try file.data?.write(to: fileURL)
        }
        for folder in folders {
            let folderURL = url.appendingPathComponent(folder.name)
            try fileManager.ensureDirectoryExists(at: folderURL)
            let existingFiles = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            let existingFileNames = Set(existingFiles.map(\.lastPathComponent))
            let newFileNames = Set(folder.files.map(\.name))
            let filesToRemove = existingFileNames.subtracting(newFileNames)
            for fileName in filesToRemove {
                let fileURL = folderURL.appendingPathComponent(fileName)
                try fileManager.removeItem(at: fileURL)
            }
            try FileSystemNode(files: folder.files, folders: folder.subfolders).write(to: folderURL)
        }
    }

    mutating func load(at url: URL) throws {
        let fileManager = FileManager.default
        for i in files.indices {
            let fileURL = url.appendingPathComponent(files[i].name)
            if fileManager.fileExists(atPath: fileURL.path) {
                files[i].data = try Data(contentsOf: fileURL)
            }
        }
        for i in folders.indices {
            let folderURL = url.appendingPathComponent(folders[i].name)
            if fileManager.fileExists(atPath: folderURL.path) {
                try folders[i].node.load(at: folderURL)
            }
        }
    }
}

@resultBuilder
struct FileSystemNodeBuilder {
    static func buildBlock<each T: FileSystemItem>(_ items: repeat each T) -> FileSystemNode {
        var structure = FileSystemNode()
        for item in repeat each items {
            item.addToFileStructure(&structure)
        }
        return structure
    }

    static func buildArray(_ components: [FileSystemNode]) -> FileSystemNode {
        components.reduce(FileSystemNode(), +)
    }
}