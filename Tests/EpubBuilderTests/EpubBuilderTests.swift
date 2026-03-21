import Testing
@testable import EpubBuilder
import Foundation

func getOutputFolderURL() throws -> URL {
    let fileManager = FileManager.default
    let projectRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath)
    let outputFolder = projectRoot.appendingPathComponent("TestOutputs.nosync")

    if !fileManager.fileExists(atPath: outputFolder.path) {
        try fileManager.createDirectory(at: outputFolder, withIntermediateDirectories: true)
    }
    return outputFolder
}

extension URL {
    func appendingPathComponents(_ components: String...) -> URL {
        components.reduce(self) { url, component in
            url.appendingPathComponent(component)
        }
    }
}

@Test func example() async throws {
    let fileManager = FileManager.default
    let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)

    let cover = try Data(contentsOf: currentDirectory.appendingPathComponents("Tests", "EpubBuilderTests", "cover.jpg"))
    let book = Book(title: "タイトル", author: "作者", cover: cover, images: [], chapters: [
        Chapter(title: "第１話", content: [
            .text("第１話の内容です。"),
        ])
    ])
    let bookEpub = book.toEpubStyle1(uuid: UUID(uuidString: "8900242B-DAFB-498C-8768-04813F9AFF46")!)

    let outputPath = currentDirectory.appendingPathComponents("TestOutputs.nosync", "Example")
    try fileManager.ensureDirectoryExists(at: outputPath)

    try bookEpub.write(to: outputPath)

    @FileSystemNodeBuilder
    var contentStructure: FileSystemNode {
        File("mimetype")
        Folder("META-INF") {
            File("container.xml")
        }
        Folder("OEBPS") {
            File("content.opf")
            Folder("images") {
                File("cover.jpg")
            }
            Folder("style") {
                File("reset.css")
                File("bookstyle.css")
            }
            Folder("text") {
                File("cover.xhtml")
                File("title.xhtml")
                File("nav.xhtml")
                File("p-0001.xhtml")
            }
        }
    }
    var expectedContent = contentStructure
    try expectedContent.load(at: currentDirectory.appendingPathComponents("Tests", "EpubBuilderTests", "Example"))

    var actualContent = contentStructure
    try actualContent.load(at: outputPath)

    #expect(expectedContent == actualContent)
}