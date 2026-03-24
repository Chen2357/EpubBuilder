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
    func addToFileNode(_ node: inout FileSystemNode)
}

struct File: FileSystemItem, Equatable {
    var name: String
    var data: Data?

    init(_ name: String, data: Data? = nil) {
        self.name = name
        self.data = data
    }

    init(_ name: String, text: String) {
        self.name = name
        self.data = text.data(using: .utf8)
    }

    func addToFileNode(_ node: inout FileSystemNode) {
        node.files.append(self)
    }
}

struct Folder: FileSystemItem, Equatable {
    var name: String
    var node: FileSystemNode
    var files: [File] {
        node.files
    }
    var subfolders: [Folder] {
        node.folders
    }

    init(_ name: String, node: FileSystemNode) {
        self.name = name
        self.node = node
    }

    init(_ name: String, @FileSystemNodeBuilder _ content: () -> FileSystemNode) {
        self.init(name, node: content())
    }

    func addToFileNode(_ node: inout FileSystemNode) {
        node.folders.append(self)
    }
}

struct FileSystemNode: FileSystemItem, Equatable {
    var files: [File]
    var folders: [Folder]

    init(files: [File] = [], folders: [Folder] = []) {
        self.files = files
        self.folders = folders
    }

    init(@FileSystemNodeBuilder _ content: () -> FileSystemNode) {
        self = content()
    }

    static func + (lhs: FileSystemNode, rhs: FileSystemNode) -> FileSystemNode {
        var combined = FileSystemNode()
        combined.files = lhs.files + rhs.files
        combined.folders = lhs.folders + rhs.folders
        return combined
    }

    func addToFileNode(_ node: inout FileSystemNode) {
        node.files += files
        node.folders += folders
    }
}

extension FileSystemNode {
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
            item.addToFileNode(&structure)
        }
        return structure
    }

    static func buildArray(_ components: [FileSystemNode]) -> FileSystemNode {
        components.reduce(FileSystemNode(), +)
    }

    static func buildEither(first component: FileSystemNode) -> FileSystemNode {
        component
    }

    static func buildEither(second component: FileSystemNode) -> FileSystemNode {
        component
    }

    static func buildOptional(_ component: FileSystemNode?) -> FileSystemNode {
        component ?? .init()
    }
}