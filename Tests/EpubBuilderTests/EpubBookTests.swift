import Foundation
import Testing
@testable import EpubBuilder

func epubBook1() throws -> EpubBook {
    EpubBook(
        title: "Title",
        creators: [
            .init(name: "Alice", role: .author),
            .init(name: "Bob", role: .illustrator),
        ],
        bookId: .zero,
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
                name: "p-1.xhtml", language: "en",
                head: .init(title: "Section 1", styles: ["bookstyle.css"]),
                body: """
                    <div class="section">Section 1</div>
                    <p>Section 1 content.</p>
                    """),
        ],
        coverImageName: "cover.jpg",
        navigationSource: .content(name: "nav.xhtml")
    )
}

@FileSystemNodeBuilder
    var epubBook1FileSystemContent: FileSystemNode {
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
                File("bookstyle.css")
            }
            Folder("text") {
                File("nav.xhtml")
                File("p-1.xhtml")
            }
        }
    }

@Test("Check if EpubBook1 can be written and read back correctly")
func EpubBookTest1() async throws {
    let book = try epubBook1()
    let outputURL = try getOutputFolderURL().appendingPathComponent("EpubBook1")
    try FileManager.default.ensureDirectoryExists(at: outputURL)
    try book.write(to: outputURL)

    var actual = epubBook1FileSystemContent
    try actual.load(at: outputURL)

    var expected = epubBook1FileSystemContent
    try expected.load(at: getTestsFolderURL().appending(path: "EpubBook1"))

    #expect(expected == actual)
}

@Test("Check content of EpubBook1")
func EpubBook1ContentTest() async throws {
    let book = try epubBook1()
    let epub = book.epubFileSystemNode

    #expect(
        epub.files.first(where: { $0.name == "mimetype" })?.data?.string() == "application/epub+zip"
    )

    let metaInfFolder = epub.folders.first(where: { $0.name == "META-INF" })
    #expect(metaInfFolder != nil)
    #expect(
        metaInfFolder?.files.first(where: { $0.name == "container.xml" })?.data?.string() == """
            <?xml version="1.0" encoding="utf-8"?>
            <container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
            <rootfiles>
                <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml" />
            </rootfiles>
            </container>
            """)

    let oebpsFolder = epub.folders.first(where: { $0.name == "OEBPS" })
    #expect(oebpsFolder != nil)
    #expect(
        oebpsFolder?.files.first(where: { $0.name == "content.opf" })?.data?.string() == """
            <?xml version='1.0' encoding='utf-8'?>
            <package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookID" version="3.0" xml:lang="en">
            <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
            <dc:title id="title0">Title</dc:title>
            <dc:creator id="id">Alice</dc:creator>
            <meta refines="#id" property="role" scheme="marc:relators">aut</meta>
            <meta refines="#id" property="display-seq">1</meta>
            <dc:creator id="id-1">Bob</dc:creator>
            <meta refines="#id-1" property="role" scheme="marc:relators">ill</meta>
            <meta refines="#id-1" property="display-seq">2</meta>
            <dc:identifier id="BookID">uuid:00000000-0000-0000-0000-000000000000</dc:identifier>
            <dc:language>en</dc:language>
            <meta name="cover" content="images.cover.jpg"/>
            </metadata>
            <manifest>
            <item id="style.bookstyle.css" href="style/bookstyle.css" media-type="text/css"/>
            <item id="images.cover.jpg" href="images/cover.jpg" media-type="image/jpeg" properties="cover-image"/>
            <item id="text.nav.xhtml" href="text/nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
            <item id="text.p-1.xhtml" href="text/p-1.xhtml" media-type="application/xhtml+xml"/>

            </manifest>
            <spine page-progression-direction="leftToRight">
            <itemref idref="text.nav.xhtml"/>
            <itemref idref="text.p-1.xhtml"/>
            </spine>
            </package>
            """)

    let imagesFolder = oebpsFolder?.subfolders.first(where: { $0.name == "images" })
    #expect(imagesFolder != nil)
    let coverImageData = try getCoverImageData()
    #expect(imagesFolder?.files.first(where: { $0.name == "cover.jpg" })?.data == coverImageData)

    let styleFolder = oebpsFolder?.subfolders.first(where: { $0.name == "style" })
    #expect(styleFolder != nil)
    #expect(
        styleFolder?.files.first(where: { $0.name == "bookstyle.css" })?.data?.string() == """
            .section {
                font-size: 1.2em;
                font-weight: bold;
                margin-top: 1em;
            }
            """)

    let textFolder = oebpsFolder?.subfolders.first(where: { $0.name == "text" })
    #expect(textFolder != nil)
    #expect(
        textFolder?.files.first(where: { $0.name == "nav.xhtml" })?.data?.string() == """
            <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="en">
            <head>
            <title>Navigation</title>


            </head>
            <body>
            <nav epub:type="toc">
            <ol>
            <li><a href="p-1.xhtml">Section 1</a></li>
            </ol>
            </nav>
            </body>
            </html>
            """)
    #expect(
        textFolder?.files.first(where: { $0.name == "p-1.xhtml" })?.data?.string() == """
            <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="en">
            <head>
            <title>Section 1</title>
            <link rel="stylesheet" type="text/css" href="../style/bookstyle.css"/>

            </head>
            <body>
            <div class="section">Section 1</div>
            <p>Section 1 content.</p>
            </body>
            </html>
            """)
}
