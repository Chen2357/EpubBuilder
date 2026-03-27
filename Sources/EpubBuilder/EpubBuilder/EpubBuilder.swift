import Foundation

public protocol EpubBuilder {
    var pageProgressionDirection: EpubBook.PageProgressionDirection { get }
    var styles: [StyleSheet] { get }
    var navigationFileName: String? { get }

    func buildContentPages(book: Book) -> [ContentPage]
}

public extension Book {
    func toEpub(builder: some EpubBuilder, bookId: UUID = UUID()) -> EpubBook {
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