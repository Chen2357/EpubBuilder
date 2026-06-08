import Foundation

public struct ImageFile {
    public var name: String
    public var data: Data
    public var mediaType: MediaType

    public enum MediaType: String {
        case jpeg = "jpeg"
        case png = "png"
        case gif = "gif"
        case svg = "svg+xml"
        case webp = "webp"
    }

    public init?(name: String, data: Data) {
        self.name = name
        self.data = data

        let ext = URL(fileURLWithPath: name).pathExtension.lowercased()
        switch ext {
        case "jpeg", "jpg":
            self.mediaType = .jpeg
        case "png":
            self.mediaType = .png
        case "gif":
            self.mediaType = .gif
        case "svg":
            self.mediaType = .svg
        case "webp":
            self.mediaType = .webp
        default:
            return nil
        }
    }

    public init(name: String, data: Data, mediaType: MediaType) {
        self.name = name
        self.data = data
        self.mediaType = mediaType
    }
}

public struct StyleSheet {
    public var name: String
    public var content: String

    public init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}

public struct ContentPage {
    public struct Head {
        public var title: String
        public var styles: [String]
        public var viewport: (width: Int, height: Int)?

        var html: String { """
            <title>\(title)</title>
            \(styles.map { "<link rel=\"stylesheet\" type=\"text/css\" href=\"../style/\($0)\"/>" }.joined(separator: "\n"))
            \(viewport.map { "<meta name=\"viewport\" content=\"width=\($0.width), height=\($0.height)\" />" } ?? "")
            """
        }

        public init(title: String, styles: [String], viewport: (width: Int, height: Int)? = nil) {
            self.title = title
            self.styles = styles
            self.viewport = viewport
        }
    }

    public var name: String

    public var language: String
    public var `class`: String?

    public var head: Head
    public var body: String

    public var isInSpine: Bool

    public var linear: Bool
    public var pageSpread: PageSpread?

    public var svg: Bool

    public enum PageSpread: String {
        case left = "page-spread-left"
        case right = "page-spread-right"
        case center = "rendition:page-spread-center"
    }

    public init(
        name: String, language: String, head: Head, body: String, `class`: String? = nil, isInSpine: Bool = true, linear: Bool = true, pageSpread: PageSpread? = nil, svg: Bool = false
    ) {
        self.name = name
        self.language = language
        self.head = head
        self.body = body
        self.class = `class`
        self.linear = linear
        self.pageSpread = pageSpread
        self.isInSpine = isInSpine
        self.svg = svg
    }

    var html: String { """
        <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="\(language)"\(`class`.map { " class=\"\($0)\"" } ?? "")>
        <head>
        \(head.html)
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }
}
