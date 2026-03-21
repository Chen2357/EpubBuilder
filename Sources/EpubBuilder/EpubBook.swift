import Foundation

public struct EpubBook {
    public var title: String
    public var author: String
    public var bookId: UUID = UUID()

    public var images: [JpgFile]
    public var styles: [TextFile]
    public var contents: [TextFile]
    public var navigationPoints: [NavigationPoint]

    public var coverImageName: String = "cover.jpg"
    public var navigationFileName: String = "nav.xhtml"

    public init(
        title: String, author: String, bookId: UUID = UUID(), images: [JpgFile], styles: [TextFile],
        contents: [TextFile], navigationPoints: [NavigationPoint], coverImageName: String = "cover.jpg",
        navigationFileName: String = "nav.xhtml"
    ) {
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
        self.navigationPoints = navigationPoints
    }
}

public struct NavigationPoint {
    public var label: String
    public var source: String
    public var children: [NavigationPoint]

    public init(label: String, source: String, children: [NavigationPoint] = []) {
        self.label = label
        self.source = source
        self.children = children
    }

    var depth: Int {
        1 + (children.map(\.depth).max() ?? 0)
    }

    func navigationControlEntry(playOrder: inout Int) -> String {
        let currentPlayOrder = playOrder
        playOrder += 1

        let childEntries = children.map { $0.navigationControlEntry(playOrder: &playOrder) }.joined(separator: "\n")

        return """
        <navPoint id="navPoint-\(currentPlayOrder)" playOrder="\(currentPlayOrder)">
        <navLabel>
        <text>\(label)</text>
        </navLabel>
        <content src="text/\(source)"/>
        \(childEntries)</navPoint>
        """
    }
}

extension EpubBook {
    var navigationDepth: Int {
        navigationPoints.map(\.depth).max() ?? 1
    }
}

public extension EpubBook {
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
            <item id="toc" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
        </manifest>
        <spine page-progression-direction="rtl" toc="toc">
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

    var tableOfContents: String {
        var playOrder = 0
        return """
        <?xml version='1.0' encoding='utf-8'?>
        <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="ja">
        <head>
            <meta name="dtb:uid" content="urn:uuid:\(bookId.uuidString)"/>
            <meta name="dtb:depth" content="\(navigationDepth)"/>
            <meta name="dtb:totalPageCount" content="0"/>
            <meta name="dtb:maxPageNumber" content="0"/>
        </head>
        <docTitle>
            <text>\(title)</text>
        </docTitle>
        <navMap>
        \(navigationPoints.map { $0.navigationControlEntry(playOrder: &playOrder) }.joined(separator: "\n"))
        </navMap>
        </ncx>
        """
    }

    @FileSystemNodeBuilder
    var epubFileSystemNode: FileSystemNode {
        File("mimetype", text: EpubBook.mimetype)
        Folder("META-INF") {
            File("container.xml", text: EpubBook.container)
        }
        Folder("OEBPS") {
            File("content.opf", text: contentOpf)
            File("toc.ncx", text: tableOfContents)
            Folder("images") {
                for image in images {
                    File(image.name, data: image.data)
                }
            }
            Folder("style") {
                for style in styles {
                    File(style.name, text: style.content)
                }
            }
            Folder("text") {
                for content in contents {
                    File(content.name, text: content.content)
                }
            }
        }
    }

    func write(to url: URL) throws {
        try epubFileSystemNode.write(to: url)
    }
}
