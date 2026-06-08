import Foundation

public struct MinimalMangaEpubBuilder: EpubBuilder {
    public var pageProgressionDirection: EpubBook.PageProgressionDirection { .rightToLeft }
    public var renditionLayout: EpubBook.RenditionLayout? { .prepaginated }

    public var width: Int
    public var height: Int

    public init(width: Int, height: Int, coverPageTitle: String) {
        self.width = width
        self.height = height
    }

    public var styles: [StyleSheet] {
        [
            StyleSheet(
                name: "fixed-layout-jp.css",
                content: """
                    @charset "UTF-8";

                    html,
                    body {
                        margin:    0;
                        padding:   0;
                        font-size: 0;
                    }
                    svg, img {
                        margin:    0;
                        padding:   0;
                    }
                    """
            )
        ]
    }

    public var navigationFileName: String? { "navigation-documents.xhtml" }

    func contentBody(imageName: String) -> String {
        """
        <div class="main">
        <svg xmlns="http://www.w3.org/2000/svg" version="1.1"
         xmlns:xlink="http://www.w3.org/1999/xlink"
         width="100%" height="100%" viewBox="0 0 \(width) \(height)">
        <image width="100%" height="100%" preserveAspectRatio="none" xlink:href="../images/\(imageName)" />
        </svg>
        </div>
        """
    }

    func contentHead(title: String) -> ContentPage.Head {
        .init(
            title: title, styles: ["fixed-layout-jp.css"], viewport: (width: width, height: height))
    }

    func buildNavigationPage(book: Book) -> ContentPage {
        var items: [String] = []
        var pageIndex = 0
        for section in book.sections {
            if let title = section.title {
                items.append(
                    """
                    <li><a href="p_\(String(format: "%04d", pageIndex)).xhtml">\(title)</a></li>
                    """)
            }
            pageIndex += section.content.count
        }

        return ContentPage(
            name: navigationFileName!,
            language: book.language,
            head: contentHead(title: "Navigation"),
            body: """
                <nav epub:type="toc" id="toc">
                <h1>Navigation</h1>
                <ol>
                \(items.joined(separator: "\n"))\
                </ol>
                </nav>
                """,
            isInSpine: false
        )
    }

    public func buildContentPages(book: Book) -> [ContentPage] {
        var contentPages: [ContentPage] = [buildNavigationPage(book: book)]
        var pageIndex = 0
        for section in book.sections {
            for block in section.content {
                guard case .image(let imageName) = block else {
                    fatalError("MinimalMangaEpubBuilder only supports image content.")
                }
                let contentPage = ContentPage(
                    name: "p_\(String(format: "%04d", pageIndex)).xhtml",
                    language: book.language,
                    head: contentHead(title: book.title),
                    body: contentBody(imageName: imageName),
                    pageSpread: pageIndex % 2 == 0 ? .right : .left,
                    svg: true
                )
                contentPages.append(contentPage)
                pageIndex += 1
            }
        }
        return contentPages
    }
}
