import Foundation

public struct Book {
    public var title: String
    public var creators: [EpubBook.Creator]
    public var language: String

    public var sections: [BookSection]

    public var images: [ImageFile]
    public var coverImageName: String?

    public init(title: String, creators: [EpubBook.Creator], language: String, sections: [BookSection], images: [ImageFile] = [], coverImageName: String? = nil) {
        self.title = title
        self.creators = creators
        self.language = language
        self.sections = sections
        self.images = images
        self.coverImageName = coverImageName
    }
}

public struct BookSection {
    public var title: String
    public var content: [ContentBlock]
    public var subsections: [BookSection] = []

    public init(title: String, content: [ContentBlock], subsections: [BookSection] = []) {
        self.title = title
        self.content = content
        self.subsections = subsections
    }
}

public extension BookSection {
    var depth: Int {
        1 + (subsections.map(\.depth).max() ?? 0)
    }
}

public enum ContentBlock {
    case paragraph(String)
    case image(String)
}