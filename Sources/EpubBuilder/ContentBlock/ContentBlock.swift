// public struct BookContent {
//     public var blocks: [Block]

//     public init(blocks: [Block]) {
//         self.blocks = blocks
//     }

//     public enum Block {
//         case paragraph(String)
//         case image(String)
//         case list([BookContent])
//         case sectionLink(reference: [Int], text: String)
//         case heading(level: Int, text: String)
//         case navigation()
//     }

//     public enum NavigationType {
//         case toc
//         case landmarks
//     }
// }



// public struct NavigationBlock {
//     public var title: String
//     public var link: String
//     public var children: [NavigationBlock]

//     public init(title: String, link: String, children: [NavigationBlock] = []) {
//         self.title = title
//         self.link = link
//         self.children = children
//     }
// }

// extension NavigationBlock {
//     func toHTML() -> String {

//     }
// }