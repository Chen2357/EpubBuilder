import Foundation

// public protocol BookContent { }

public struct Book<Content> {
    public var title: String
    public var creators: [EpubBook.Creator]
    public var language: String

    public var sections: [BookSection<Content>]

    public var images: [ImageFile]
    public var coverImageName: String?

    public init(title: String, creators: [EpubBook.Creator], language: String, sections: [BookSection<Content>], images: [ImageFile] = [], coverImageName: String? = nil) {
        self.title = title
        self.creators = creators
        self.language = language
        self.sections = sections
        self.images = images
        self.coverImageName = coverImageName
    }
}

public struct BookSection<Content> {
    public var title: String
    public var content: Content
    public var subsections: [BookSection<Content>] = []

    public init(title: String, content: Content, subsections: [BookSection<Content>] = []) {
        self.title = title
        self.content = content
        self.subsections = subsections
    }
}

public enum SimpleBlock {
    case paragraph(String)
    case image(String)
}

public extension Book {
    func mapContent<T>(_ transform: (Content) -> T) -> Book<T> {
        let newSections = sections.map { section in
            section.mapContent(transform)
        }
        return Book<T>(title: title, creators: creators, language: language, sections: newSections, images: images, coverImageName: coverImageName)
    }
}

public extension BookSection {
    var depth: Int {
        1 + (subsections.map(\.depth).max() ?? 0)
    }

    func mapContent<T>(_ transform: (Content) -> T) -> BookSection<T> {
        let newContent = transform(content)
        let newSubsections = subsections.map { subsection in
            subsection.mapContent(transform)
        }
        return .init(title: title, content: newContent, subsections: newSubsections)
    }
}