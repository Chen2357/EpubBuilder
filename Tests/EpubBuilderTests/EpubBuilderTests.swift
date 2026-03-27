import Foundation
import Testing

@testable import EpubBuilder

func book1() throws -> Book {
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
        Folder("images") {
            File("cover.jpg")
        }
        Folder("style") { }
        Folder("text") {
            File("p-0001.xhtml")
        }
    }
}

@Test("Holistic test of MinimalEpubBuilder")
func test1() async throws {
    let book = try book1Epub()
    let outputURL = try getOutputFolderURL().appendingPathComponent("Book1")
    try FileManager.default.ensureDirectoryExists(at: outputURL)

    try book.write(to: outputURL)

    var expected = book1FileSystemContent
    try expected.load(at: outputURL)

    var actual = book1FileSystemContent
    try actual.load(at: getTestsFolderURL().appending(path: "Book1"))

    #expect(expected == actual)
}

func book2() throws -> Book {
    Book(
        title: "タイトル",
        creators: [.init(name: "作者", role: .author), .init(name: "イラストレーター", role: .illustrator)],
        language: "ja",
        sections: [
            BookSection(
                title: "第１話",
                content: [
                    .paragraph("第１話の内容です。")
                ]),
            BookSection(
                title: "第２話",
                content: [
                    .paragraph("第２話の内容です。")
                ])
        ],
        images: [.init(name: "cover.jpg", data: try getCoverImageData(), mediaType: .jpeg)],
        coverImageName: "cover.jpg")
}

@Test("Test depth one navigation document generation")
func testBook2Navigation() throws {
    let builder = FancyVrtlEpubBuilder(
        depth: .one,
        sectionTitleFormatter: { number, title in
            "#\(number[0]). \(title)"
        }
    )

    let expectedNavigation = """
    <nav epub:type="toc">
    <h1>Contents</h1>
    <ol>
    <li><a href="text/p-0001.xhtml">#1. 第１話</a></li>
    <li><a href="text/p-0002.xhtml">#2. 第２話</a></li>
    </ol>
    </nav>
    """
    let actualNavigation = try builder.buildNavigationBody(book: book2())
    #expect(expectedNavigation == actualNavigation)
}

@Test("Test depth one Epub generation")
func testBook2Epub() throws {
    let book = try book2().toEpub(builder: FancyVrtlEpubBuilder(
        depth: .one,
        sectionTitleFormatter: { number, title in
            "#\(number[0]). \(title)"
        }
    ), bookId: .zero)
    let outputURL = try getOutputFolderURL().appendingPathComponent("Book2")
    try FileManager.default.ensureDirectoryExists(at: outputURL)
    try book.write(to: outputURL)
}


func book3() throws -> Book {
    Book(
        title: "タイトル",
        creators: [.init(name: "作者", role: .author), .init(name: "イラストレーター", role: .illustrator)],
        language: "ja",
        sections: [
            BookSection(
                title: "始まり",
                content: [],
                subsections: [
                    BookSection(
                        title: "第１話",
                        content: [
                            .paragraph("第１話の内容です。")
                        ]),
                    BookSection(
                        title: "第２話",
                        content: [
                            .paragraph("第２話の内容です。")
                        ])
                ]),
            BookSection(
                title: "終わり",
                content: [],
                subsections: [
                    BookSection(
                        title: "第３話",
                        content: [
                            .paragraph("第３話の内容です。")
                        ])
                ])
        ],
        images: [.init(name: "cover.jpg", data: try getCoverImageData(), mediaType: .jpeg)],
        coverImageName: "cover.jpg")
}

@Test("Test depth two navigation document generation")
func testBook3Navigation() throws {
    let builder = FancyVrtlEpubBuilder(
        depth: .two,
        sectionTitleFormatter: { number, title in
            if number.count == 1 {
                return "#\(number[0]). \(title)"
            } else {
                return "##\(number[0]).\(number[1]). \(title)"
            }
        }
    )

    let expectedNavigation = """
    <nav epub:type="toc">
    <h1>Contents</h1>
    <ol>
    <li><a href="text/p-0001.xhtml">#1. 始まり</a>
    <ol>
    <li><a href="text/p-0001.xhtml">##1.1. 第１話</a></li>
    <li><a href="text/p-0002.xhtml">##1.2. 第２話</a></li>
    </ol>
    </li>
    <li><a href="text/p-0003.xhtml">#2. 終わり</a>
    <ol>
    <li><a href="text/p-0003.xhtml">##2.1. 第３話</a></li>
    </ol>
    </li>
    </ol>
    </nav>
    """
    let actualNavigation = try builder.buildNavigationBody(book: book3())
    #expect(expectedNavigation == actualNavigation)
}