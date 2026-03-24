import Foundation
import Testing
@testable import EpubBuilder

func getCoverImageData() throws -> Data {
    let fileManager = FileManager.default
    let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
    let coverImageURL = currentDirectory.appendingPathComponents(
        "Tests", "EpubBuilderTests", "cover.jpg")
    return try Data(contentsOf: coverImageURL)
}

func getOutputFolderURL() throws -> URL {
    let fileManager = FileManager.default
    let projectRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath)
    let outputFolder = projectRoot.appendingPathComponent("TestOutputs.nosync")

    if !fileManager.fileExists(atPath: outputFolder.path) {
        try fileManager.createDirectory(at: outputFolder, withIntermediateDirectories: true)
    }
    return outputFolder
}

func getTestsFolderURL() -> URL {
    let fileManager = FileManager.default
    let projectRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath)
    let testsFolder = projectRoot.appendingPathComponents("Tests", "EpubBuilderTests")
    return testsFolder
}

extension URL {
    func appendingPathComponents(_ components: String...) -> URL {
        components.reduce(self) { url, component in
            url.appendingPathComponent(component)
        }
    }
}

extension Data {
    func string(encoding: String.Encoding = .utf8) -> String? {
        String(data: self, encoding: encoding)
    }
}