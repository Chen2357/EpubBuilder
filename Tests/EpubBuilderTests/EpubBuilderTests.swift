import Foundation
import Testing

@testable import EpubBuilder

func book1() throws -> Book<[SimpleBlock]> {
    Book(
        title: "タイトル",
        creators: [.init(name: "作者", role: .author), .init(name: "イラストレーター", role: .illustrator)],
        language: "ja",
        sections: [
            BookSection(
                title: "第１話",
                content: [
                    .paragraph("第１話の内容です。")
                ])
        ],
        images: [.init(name: "cover.jpg", data: try getCoverImageData(), mediaType: .jpeg)],
        coverImageName: "cover.jpg")
}

func book1Epub() throws -> EpubBook {
    try book1().toEpub(builder: MinimalEpubBuilder(), bookId: .zero)
}

@FileSystemNodeBuilder
var book1FileSystemContent: FileSystemNode {
    File("mimetype")
    Folder("META-INF") {
        File("container.xml")
    }
    Folder("OEBPS") {
        File("content.opf")
        File("navigation-documents.xhtml")
        Folder("images") {
            File("cover.jpg")
        }
        Folder("style") { }
        Folder("text") {
            File("p-0001.xhtml")
        }
    }
}

@Test func test1() async throws {
    let book = try book1Epub()
    let outputURL = try getOutputFolderURL().appendingPathComponent("Test1")
    try FileManager.default.ensureDirectoryExists(at: outputURL)

    try book.write(to: outputURL)

    var expected = book1FileSystemContent
    try expected.load(at: outputURL)

    var actual = book1FileSystemContent
    try actual.load(at: getTestsFolderURL().appending(path: "Test1"))

    #expect(expected == actual)
}