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

func epubBook1() throws -> EpubBook {
    EpubBook(
        title: "Title",
        creators: [
            .init(name: "Alice", role: .author),
            .init(name: "Bob", role: .illustrator),
        ],
        bookId: .init(uuidString: "00000000-0000-0000-0000-000000000000")!,
        language: "en",
        images: [
            .init(name: "cover.jpg", data: try getCoverImageData(), mediaType: .jpeg)
        ],
        styles: [
            .init(
                name: "bookstyle.css",
                content: """
                    .section {
                        font-size: 1.2em;
                        font-weight: bold;
                        margin-top: 1em;
                    }
                    """)
        ],
        contents: [
            .init(
                name: "nav.xhtml", language: "en", head: .init(title: "Navigation", styles: []),
                body: """
                    <nav epub:type="toc">
                    <ol>
                    <li><a href="p-1.xhtml">Section 1</a></li>
                    </ol>
                    </nav>
                    """),
            .init(
                name: "p-1.xhtml", language: "en", head: .init(title: "Section 1", styles: ["bookstyle.css"]),
                body: """
                        <div class="section">Section 1</div>
                        <p>Section 1 content.</p>
                    """),
        ],
        coverImageName: "cover.jpg",
        navigationSource: .content(name: "nav.xhtml")
    )
}

@Test func EpubBookTest1() async throws {
    let book = try epubBook1()
    let outputURL = try getOutputFolderURL().appendingPathComponent("EpubBookTest1")
    try FileManager.default.ensureDirectoryExists(at: outputURL)

    try book.write(to: outputURL)
}
