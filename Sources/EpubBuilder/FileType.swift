import Foundation

public struct JpgFile {
    public var name: String
    public var data: Data

    public init(name: String, data: Data) {
        guard name.hasSuffix(".jpg") else {
            fatalError("File name must end with .jpg. Received: \(name)")
        }
        self.name = name
        self.data = data
    }
}

public struct TextFile {
    public var name: String
    public var content: String

    public init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}