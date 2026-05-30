import Foundation

public struct MinimalEpubBuilder: EpubBuilder {
    public var pageProgressionDirection: EpubBook.PageProgressionDirection
    public var styles: [StyleSheet] { [] }
    public var navigationFileName: String? { nil }

    public init(pageProgressionDirection: EpubBook.PageProgressionDirection = .leftToRight) {
        self.pageProgressionDirection = pageProgressionDirection
    }

    func contentBody(section: BookSection) -> String {
        section.content.map { content in
            switch content {
            case .paragraph(let text):
                return "<p>\(text)</p>"
            case .image(let name):
                return "<img src=\"../images/\(name)\"/>"
            }
        }.joined(separator: "\n")
    }

    public func buildContentPages(book: Book) -> [ContentPage] {
        book.sections.enumerated().map { (index, section) in
            ContentPage(
                name: "p-\(String(format: "%04d", index + 1)).xhtml", language: book.language,
                head: .init(title: section.title ?? book.title, styles: []),
                body: contentBody(section: section))
        }
    }
}
