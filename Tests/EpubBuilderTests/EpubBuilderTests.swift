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
        Folder("style") {}
        Folder("text") {
            File("p-001.xhtml")
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
        sections: [1, 2, 3, 4, 10, 11, 12, 100].map { index in
            BookSection(
                title: "第\(index)話",
                content: [
                    .paragraph("第\(index)話の内容です。")
                ])
        })
}

@Test("Test depth one navigation document generation")
func testBook2Navigation() throws {
    let builder = FancyVrtlEpubBuilder(depth: .one)

    let expectedNavigation = """
        <nav epub:type="toc">
        <h1>Contents</h1>
        <ol>
        <li><a href="p-001.xhtml">第１話</a></li>
        <li><a href="p-002.xhtml">第２話</a></li>
        <li><a href="p-003.xhtml">第３話</a></li>
        <li><a href="p-004.xhtml">第４話</a></li>
        <li><a href="p-005.xhtml">第<span class="tcy">10</span>話</a></li>
        <li><a href="p-006.xhtml">第<span class="tcy">11</span>話</a></li>
        <li><a href="p-007.xhtml">第<span class="tcy">12</span>話</a></li>
        <li><a href="p-008.xhtml">第<span class="tcy">100</span>話</a></li>
        </ol>
        </nav>
        """
    let actualNavigation = try builder.buildNavigationBody(book: book2())
    #expect(expectedNavigation == actualNavigation)
}

@Test("Test depth one Epub generation")
func testBook2Epub() throws {
    let book = try book2().toEpub(builder: FancyVrtlEpubBuilder(depth: .one), bookId: .zero)
    let outputURL = try getOutputFolderURL().appendingPathComponent("Book2")
    try FileManager.default.ensureDirectoryExists(at: outputURL)
    try book.write(to: outputURL)
}

@Test func outputBook2Epub() throws {
    let book = try book2().toEpub(builder: FancyVrtlEpubBuilder(depth: .one), bookId: .zero)
    let outputURL = try getOutputFolderURL().appendingPathComponent("Book2")
    try FileManager.default.ensureDirectoryExists(at: outputURL)
    try book.writeEpub(to: outputURL.appending(component: "Book2.epub"))
}

func book3() throws -> Book {
    Book(
        title: "タイトル",
        creators: [.init(name: "作者", role: .author), .init(name: "イラストレーター", role: .illustrator)],
        language: "ja",
        sections: [
            BookSection(
                title: "<ruby>始<rt>はじ</rt>まり</ruby>",
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
                        ]),
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
                ]),
        ],
        images: [.init(name: "cover.jpg", data: try getCoverImageData(), mediaType: .jpeg)],
        coverImageName: "cover.jpg")
}

func getBook3Builder() -> FancyVrtlEpubBuilder {
    FancyVrtlEpubBuilder(
        depth: .two,
        colophon: [
            .heading("『タイトル』"),
            .paragraph("作者"),
            .horizontalRule,
            .paragraph("EPUB by Swift package EpubBuilder"),
        ]
    )
}

@Test("Test depth two navigation document generation")
func testBook3Navigation() throws {
    let builder = getBook3Builder()

    let expectedNavigation = """
        <nav epub:type="toc">
        <h1>Contents</h1>
        <ol>
        <li><a href="p-001.xhtml"><ruby>始<rt>はじ</rt>まり</ruby></a>
        <ol>
        <li><a href="p-002.xhtml">第１話</a></li>
        <li><a href="p-003.xhtml">第２話</a></li>
        </ol>
        </li>
        <li><a href="p-004.xhtml">終わり</a>
        <ol>
        <li><a href="p-005.xhtml">第３話</a></li>
        </ol>
        </li>
        </ol>
        </nav>
        """
    let actualNavigation = try builder.buildNavigationBody(book: book3())
    #expect(expectedNavigation == actualNavigation)
}

@Test func testBook3Epub() throws {
    let book = try book3().toEpub(builder: getBook3Builder(), bookId: .zero)
    let outputURL = try getOutputFolderURL().appendingPathComponent("Book3")
    try FileManager.default.ensureDirectoryExists(at: outputURL)
    try book.write(to: outputURL)
    try book.writeEpub(to: outputURL.appending(component: "Book3.epub"))
}

func manga() -> Book {
    Book(
        title: "タイトル",
        creators: [.init(name: "作者", role: .author)],
        language: "ja",
        sections: [
            BookSection(
                title: nil,
                content: [
                    .image("i_0000.jpg")
                ]
            ),
            BookSection(
                title: "第１話",
                content: [
                    .image("i_0001.jpg"),
                    .image("i_0002.jpg")
                ]
            ),
            BookSection(
                title: "第２話",
                content: [
                    .image("i_0003.jpg")
                ]
            )
        ],
        images: (0...3).map { index in
            ImageFile(name: "i_\(String(format: "%04d", index)).jpg", data: try! getCoverImageData(), mediaType: .jpeg)
        } + [ImageFile(name: "cover.jpg", data: try! getCoverImageData(), mediaType: .jpeg)],
        coverImageName: "cover.jpg"
    )
}

@Test func outputMinimalManga() throws {
    let book = manga().toEpub(builder: MinimalMangaEpubBuilder(width: 1792, height: 2380, coverPageTitle: "表紙"), bookId: .zero)
    let outputURL = try getOutputFolderURL().appendingPathComponent("Manga")
    try FileManager.default.ensureDirectoryExists(at: outputURL)
    try book.write(to: outputURL)
    try book.writeEpub(to: outputURL.appending(component: "Manga.epub"))
}

