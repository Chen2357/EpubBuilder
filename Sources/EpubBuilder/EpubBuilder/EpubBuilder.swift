import Foundation

public protocol EpubBuilder<Content> {
    associatedtype Content

    var pageProgressionDirection: EpubBook.PageProgressionDirection { get }
    var styles: [StyleSheet] { get }
    var navigationFileName: String? { get }

    func buildContentPages(book: Book<Content>) -> [ContentPage]
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
            navigationFileName: builder.navigationFileName
        )
    }
}