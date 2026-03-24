import Foundation

public struct EpubBook {
    public var title: String
    public var creators: [Creator]
    public var bookId: UUID = UUID()
    public var language: String
    public var pageProgressionDirection: PageProgressionDirection

    public var images: [ImageFile]
    public var styles: [StyleSheet]
    public var contents: [ContentPage]

    public var coverImageName: String?
    public var navigationSource: NavigationSource

    public init(
        title: String,
        creators: [Creator],
        bookId: UUID = UUID(),
        language: String,
        pageProgressionDirection: PageProgressionDirection = .leftToRight,
        images: [ImageFile],
        styles: [StyleSheet],
        contents: [ContentPage],
        coverImageName: String? = nil,
        navigationSource: NavigationSource
    ) {
        self.title = title
        self.creators = creators
        self.bookId = bookId
        self.language = language
        self.pageProgressionDirection = pageProgressionDirection

        self.images = images
        self.styles = styles
        self.contents = contents

        self.coverImageName = coverImageName
        self.navigationSource = navigationSource
    }
}

public extension EpubBook {
    struct Creator {
        public var name: String
        public var role: String?

        public enum Role: String {
            case author = "aut"
            case illustrator = "ill"
        }

        public init(name: String, role: Role? = nil) {
            self.name = name
            self.role = role?.rawValue
        }

        public init(name: String, role: String) {
            self.name = name
            self.role = role
        }

        func metadata(id: String) -> String {
            let common = """
            <dc:creator id="\(id)">\(name)</dc:creator>
            """
            if let role = role {
                return common + """
                \n<meta refines="#\(id)" property="role" scheme="marc:relators">\(role)</meta>
                """
            } else {
                return common
            }
        }
    }

    enum PageProgressionDirection {
        case leftToRight
        case rightToLeft
    }

    enum NavigationSource {
        case content(name: String)
        case standalone(`class`: String?, body: String)
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

    var creatorMetadata: String {
        if creators.count == 1 {
            creators[0].metadata(id: "id")
        } else {
            creators.enumerated().map { (index, creator) in
                """
                \(creator.metadata(id: "\(index == 0 ? "id" : "id-\(index)")"))
                <meta refines="#\("\(index == 0 ? "id" : "id-\(index)")")" property="display-seq">\(index + 1)</meta>
                """
            }.joined(separator: "\n")
        }
    }

    var stylesheetItems: String {
        styles.map { style in
            """
            <item id="style.\(style.name)" href="style/\(style.name)" media-type="text/css"/>
            """
        }.joined(separator: "\n")
    }

    var imageItems: String {
        images.map { image in
            """
            <item id="images.\(image.name)" href="images/\(image.name)" media-type="image/\(image.mediaType)"\(image.name == coverImageName ? " properties=\"cover-image\"" : "")/>
            """
        }.joined(separator: "\n")
    }

    var contentItems: String {
        switch navigationSource {
        case .content(let name):
            contents.map { content in
                """
                <item id="text.\(content.name)" href="text/\(content.name)" media-type="application/xhtml+xml"\(content.name == name ? " properties=\"nav\"" : "")/>
                """
            }.joined(separator: "\n")

        case .standalone:
            (contents.map { content in
                """
                <item id="text.\(content.name)" href="text/\(content.name)" media-type="application/xhtml+xml"/>
                """
            } + [
                """
                <item id="nav" href="navigation-documents.xhtml" media-type="application/xhtml+xml" properties="nav"/>
                """
            ]).joined(separator: "\n")
        }
    }

    var navigationDocuments: String? {
        guard case .standalone(let `class`, let body) = navigationSource else { return nil }
        return """
        <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="\(language)"\(`class`.map { " class=\"\($0)\"" } ?? "")>
        <head>
        <title>Navigation</title>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }

    var spine: String {
        contents.map { content in
            """
            <itemref idref="text.\(content.name)"\(content.linear == false ? " linear=\"no\"" : "")\(content.pageSpread.map { " properties=\"page-spread-\($0)\"" } ?? "")/>
            """
        }.joined(separator: "\n")
    }

    var contentOpf: String {
        """
        <?xml version='1.0' encoding='utf-8'?>
        <package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookID" version="3.0" xml:lang="\(language)">
        <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
        <dc:title id="title0">\(title)</dc:title>
        \(creatorMetadata)
        <dc:identifier id="BookID">uuid:\(bookId.uuidString)</dc:identifier>
        <dc:language>\(language)</dc:language>
        \(coverImageName.map { """
        <meta name="cover" content="images.\($0)"/>
        """} ?? "")
        </metadata>
        <manifest>
        \(stylesheetItems)
        \(imageItems)
        \(contentItems)
        </manifest>
        <spine page-progression-direction="\(pageProgressionDirection)">
        \(spine)
        </spine>
        </package>
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
            if let navigationDocuments = navigationDocuments {
                File("navigation-documents.xhtml", text: navigationDocuments)
            }
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
                    File(content.name, text: content.html)
                }
            }
        }
    }

    public func write(to url: URL) throws {
        try epubFileSystemNode.write(to: url)
    }
}
