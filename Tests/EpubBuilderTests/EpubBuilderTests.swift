import Testing
@testable import EpubBuilder
import Foundation

// @Test func example() async throws {
//     let fileManager = FileManager.default
//     let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)

//     let cover = try Data(contentsOf: currentDirectory.appendingPathComponents("Tests", "EpubBuilderTests", "cover.jpg"))
//     let book = Book(title: "タイトル", author: "作者", cover: cover, images: [], sections: [
//         Section(title: "第１話", content: [
//             .paragraph("第１話の内容です。"),
//         ])
//     ])
//     let bookEpub = book.toEpubStyle1(depth: 1, bookId: UUID(uuidString: "8900242B-DAFB-498C-8768-04813F9AFF46")!)

//     let outputPath = currentDirectory.appendingPathComponents("TestOutputs.nosync", "Example")
//     try fileManager.ensureDirectoryExists(at: outputPath)

//     try bookEpub.write(to: outputPath)

//     @FileSystemNodeBuilder
//     var contentStructure: FileSystemNode {
//         File("mimetype")
//         Folder("META-INF") {
//             File("container.xml")
//         }
//         Folder("OEBPS") {
//             File("content.opf")
//             File("toc.ncx")
//             Folder("images") {
//                 File("cover.jpg")
//             }
//             Folder("style") {
//                 File("reset.css")
//                 File("bookstyle.css")
//             }
//             Folder("text") {
//                 File("cover.xhtml")
//                 File("title.xhtml")
//                 File("nav.xhtml")
//                 File("p-0001.xhtml")
//             }
//         }
//     }
//     var expected = contentStructure
//     try expected.load(at: currentDirectory.appendingPathComponents("Tests", "EpubBuilderTests", "Example"))

//     var actual = contentStructure
//     try actual.load(at: outputPath)

//     #expect(expected == actual)
// }

// @Test func example2() async throws {
//     let fileManager = FileManager.default
//     let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)

//     let cover = try Data(contentsOf: currentDirectory.appendingPathComponents("Tests", "EpubBuilderTests", "cover.jpg"))
//     let book = Book(title: "タイトル", author: "作者", cover: cover, images: [], sections: [
//         Section(title: "パート１", subsections: [
//             Section(title: "第１話", content: [
//                 .paragraph("第１話の内容です。"),
//             ]),
//             Section(title: "第２話", content: [
//                 .paragraph("第２話の内容です。"),
//             ])
//         ]),
//         Section(title: "パート２", subsections: [
//             Section(title: "第３話", content: [
//                 .paragraph("第３話の内容です。"),
//             ])
//         ])
//     ])
//     let bookEpub = book.toEpubStyle1(depth: 2, bookId: UUID(uuidString: "8900242B-DAFB-498C-8768-04813F9AFF46")!)

//     let outputPath = currentDirectory.appendingPathComponents("TestOutputs.nosync", "Example2")
//     try fileManager.ensureDirectoryExists(at: outputPath)

//     try bookEpub.write(to: outputPath)

    // @FileSystemNodeBuilder
    // var contentStructure: FileSystemNode {
    //     File("mimetype")
    //     Folder("META-INF") {
    //         File("container.xml")
    //     }
    //     Folder("OEBPS") {
    //         File("content.opf")
    //         File("toc.ncx")
    //         Folder("images") {
    //             File("cover.jpg")
    //         }
    //         Folder("style") {
    //             File("reset.css")
    //             File("bookstyle.css")
    //         }
    //         Folder("text") {
    //             File("cover.xhtml")
    //             File("title.xhtml")
    //             File("nav.xhtml")
    //             File("p-0001.xhtml")
    //             File("p-0002.xhtml")
    //             File("p-0003.xhtml")
    //         }
    //     }
    // }
// }

// @Test func navigationCntrol() async throws {
//     let navigationPoint = NavigationPoint(label: "Chapter 1", source: "p-0001.xhtml", children: [
//         NavigationPoint(label: "Episode 1", source: "p-0002.xhtml"),
//         NavigationPoint(label: "Episode 2", source: "p-0003.xhtml")
//     ])

//     let expected = """
//     <navPoint id="navPoint-1" playOrder="1">
//     <navLabel>
//     <text>Chapter 1</text>
//     </navLabel>
//     <content src="text/p-0001.xhtml"/>
//     <navPoint id="navPoint-2" playOrder="2">
//     <navLabel>
//     <text>Episode 1</text>
//     </navLabel>
//     <content src="text/p-0002.xhtml"/>
//     </navPoint>
//     <navPoint id="navPoint-3" playOrder="3">
//     <navLabel>
//     <text>Episode 2</text>
//     </navLabel>
//     <content src="text/p-0003.xhtml"/>
//     </navPoint></navPoint>
//     """

//     var playOrder = 1
//     let actual = navigationPoint.navigationControlEntry(playOrder: &playOrder)
//     #expect(actual == expected)
// }