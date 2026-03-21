import Foundation

struct EpubBook {
    var title: String
    var author: String
    var bookId: UUID = UUID()

    var images: [JpgFile]
    var styles: [TextFile]
    var contents: [TextFile]

    var coverImageName: String = "cover.jpg"
    var navigationFileName: String = "nav.xhtml"

    init(title: String, author: String, bookId: UUID = UUID(), images: [JpgFile], styles: [TextFile], contents: [TextFile], coverImageName: String = "cover.jpg", navigationFileName: String = "nav.xhtml") {
        guard contents.contains(where: { $0.name == navigationFileName }) else {
            fatalError("Navigation file with name \(navigationFileName) not found in contents.")
        }
        guard images.contains(where: { $0.name == coverImageName }) else {
            fatalError("Cover image with name \(coverImageName) not found in images.")
        }

        self.title = title
        self.author = author
        self.bookId = bookId
        self.images = images
        self.styles = styles
        self.contents = contents
        self.coverImageName = coverImageName
        self.navigationFileName = navigationFileName
    }
}

extension EpubBook {
    static var mimetype: String {
        "application/epub+zip"
    }

    static var container: String {
        """
        <?xml version="1.0" encoding="utf-8"?>
        <container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
        <rootfiles>
            <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml" />
        </rootfiles>
        </container>
        """
    }

    var contentOpf: String {
        """
        <?xml version='1.0' encoding='utf-8'?>
        <package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookID" version="3.0" xml:lang="ja">
        <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
            <dc:title id="title0">\(title)</dc:title>
            <dc:creator id="id">\(author)</dc:creator>
            <dc:identifier id="BookID">uuid:\(bookId.uuidString)</dc:identifier>
            <dc:language>ja</dc:language>
            <meta name="cover" content="images.\(coverImageName)"/>
        </metadata>
        <manifest>
            \(contents.map { content in
                if content.name == navigationFileName {
                    """
                    <item id="nav" href="text/\(content.name)" media-type="application/xhtml+xml" properties="nav"/>
                    """
                } else {
                    """
                    <item id="text.\(content.name)" href="text/\(content.name)" media-type="application/xhtml+xml"/>
                    """
                }
            }.joined(separator: "\n"))
            \(images.map { image in
                if image.name == coverImageName {
                    """
                    <item id="images.\(image.name)" href="images/\(image.name)" media-type="image/jpeg" properties="cover-image"/>
                    """
                } else {
                    """
                    <item id="images.\(image.name)" href="images/\(image.name)" media-type="image/jpeg"/>
                    """
                }
            }.joined(separator: "\n"))
            \(styles.map { style in
                """
                <item id="style.\(style.name)" href="style/\(style.name)" media-type="text/css"/>
                """
            }.joined(separator: "\n"))
        </manifest>
        <spine page-progression-direction="rtl">
            \(contents.map { content in
                if content.name == navigationFileName {
                    """
                    <itemref idref="nav"/>
                    """
                } else {
                    """
                    <itemref idref="text.\(content.name)"/>
                    """
                }
            }.joined(separator: "\n"))
        </spine>
        </package>
        """
    }

    @FileSystemNodeBuilder
    var epubFileSystemNode: FileSystemNode {
        File("mimetype", data: EpubBook.mimetype.data(using: .utf8))
        Folder("META-INF") {
            File("container.xml", data: EpubBook.container.data(using: .utf8))
        }
        Folder("OEBPS") {
            File("content.opf", data: contentOpf.data(using: .utf8))
            Folder("images") {
                for image in images {
                    File(image.name, data: image.data)
                }
            }
            Folder("style") {
                for style in styles {
                    File(style.name, data: style.content.data(using: .utf8))
                }
            }
            Folder("text") {
                for content in contents {
                    File(content.name, data: content.content.data(using: .utf8))
                }
            }
        }
    }

    func write(to url: URL) throws {
        try epubFileSystemNode.write(to: url)
    }
}