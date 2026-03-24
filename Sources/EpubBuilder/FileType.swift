import Foundation

public extension EpubBook {
    struct ImageFile {
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

        public init(name: String, data: Data, mediaType: MediaType) {
            self.name = name
            self.data = data
            self.mediaType = mediaType
        }
    }

    struct StyleSheet {
        public var name: String
        public var content: String

        public init(name: String, content: String) {
            self.name = name
            self.content = content
        }
    }

    struct ContentPage {
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

        public var linear: Bool
        public var pageSpread: PageSpread?

        public enum PageSpread: String {
            case left = "left"
            case right = "right"
        }

        public init(
            name: String, language: String, head: Head, body: String, `class`: String? = nil, linear: Bool = true, pageSpread: PageSpread? = nil
        ) {
            self.name = name
            self.language = language
            self.head = head
            self.body = body
            self.class = `class`
            self.linear = linear
            self.pageSpread = pageSpread
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
}