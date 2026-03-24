import Foundation

public protocol EpubBuilder<Content> {
    associatedtype Content

    var pageProgressionDirection: EpubBook.PageProgressionDirection { get }
    var styles: [EpubBook.StyleSheet] { get }

    func buildContentPages(book: Book<Content>) -> [EpubBook.ContentPage]
    func buildNavigationSource(book: Book<Content>) -> EpubBook.NavigationSource
}

public extension Book {
    func toEpub<B: EpubBuilder>(builder: B, bookId: UUID = UUID()) -> EpubBook where B.Content == Content {
        EpubBook(
            title: title,
            creators: creators,
            bookId: bookId,
            language: language,
            pageProgressionDirection: builder.pageProgressionDirection,
            images: images,
            styles: builder.styles,
            contents: builder.buildContentPages(book: self),
            coverImageName: coverImageName,
            navigationSource: builder.buildNavigationSource(book: self)
        )
    }
}