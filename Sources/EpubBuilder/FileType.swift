import Foundation

struct JpgFile {
    var name: String
    var data: Data

    init(name: String, data: Data) {
        guard name.hasSuffix(".jpg") else {
            fatalError("File name must end with .jpg. Received: \(name)")
        }
        self.name = name
        self.data = data
    }
}

struct TextFile {
    var name: String
    var content: String

    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}