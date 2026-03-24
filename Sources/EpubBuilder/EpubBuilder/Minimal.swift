import Foundation

public struct MinimalEpubBuilder<Content> {
    public var pageProgressionDirection: EpubBook.PageProgressionDirection
    public var styles: [StyleSheet] { [] }

    public init(pageProgressionDirection: EpubBook.PageProgressionDirection = .leftToRight) {
        self.pageProgressionDirection = pageProgressionDirection
    }

    func contentBody(section: BookSection<[SimpleBlock]>) -> String {
        section.content.map { content in
            switch content {
            case .paragraph(let text):
                return "<p>\(text)</p>"
            case .image(let name):
                return "<img src=\"../images/\(name)\"/>"
            }
        }.joined(separator: "\n")
    }

    public func buildNavigationSource(book: Book<Content>) -> EpubBook.NavigationSource {
        let items = book.sections.enumerated().map { (index, section) in
            "<li><a href=\"text/p-\(String(format: "%04d", index + 1)).xhtml\">\(section.title)</a></li>"
        }.joined(separator: "\n")
        return .standalone(
            class: nil,
            body: """
                <nav epub:type="toc">
                <ol>
                \(items)
                </ol>
                </nav>
                """)
    }
}

extension MinimalEpubBuilder: EpubBuilder where Content == [SimpleBlock] {
    public func buildContentPages(book: Book<Content>) -> [ContentPage] {
        book.sections.enumerated().map { (index, section) in
            ContentPage(
                name: "p-\(String(format: "%04d", index + 1)).xhtml", language: book.language,
                head: .init(title: section.title, styles: []),
                body: contentBody(section: section))
        }
    }
}
