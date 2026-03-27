import Foundation

public struct FancyVrtlEpubBuilder {
    public var pageProgressionDirection: EpubBook.PageProgressionDirection { .rightToLeft }
    public var styles: [StyleSheet] {
        [
            StyleSheet(
                name: "reset.css",
                content: """
                    @charset "utf-8";
                    html,body,div,span,applet,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote,pre,a,abbr,acronym,address,big,cite,code,del,dfn,em,img,ins,kbd,q,s,samp,small,strike,strong,sub,sup,tt,var,b,u,i,center,dl,dt,dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article,aside,canvas,details,embed,figure,figcaption,footer,header,hgroup,menu,nav,output,ruby,section,summary,time,mark,audio,video{border:0;font:inherit;font-size:100%;vertical-align:baseline;margin:0;padding:0;}
                    article,aside,details,figcaption,figure,footer,header,hgroup,menu,nav,section{display:block;}body{line-height:1;}
                    ol,ul{list-style:none;}
                    blockquote,q{quotes:none;}
                    blockquote:before,blockquote:after,q:before,q:after{content:none;}
                    table{border-collapse:collapse;border-spacing:0;}
                    """),
            StyleSheet(
                name: "bookstyle.css",
                content: """
                    @charset "utf-8";
                    body{
                        writing-mode: vertical-rl;
                        -webkit-writing-mode: vertical-rl;
                        -epub-writing-mode: vertical-rl;
                        line-height: 1.75;
                        text-align: justify;
                        margin:0;
                        padding:0;
                        font-size:100%;
                    }
                    .vertical {
                        writing-mode: vertical-rl;
                        -webkit-writing-mode: vertical-rl;
                        -epub-writing-mode: vertical-rl;
                    }
                    .horizontal{
                        writing-mode:horizontal-tb;
                        -epub-writing-mode:horizontal-tb;
                        -webkit-writing-mode:horizontal-tb;
                    }
                    /* 縦中横 */
                    .tcy {
                        font-size:0.9em;
                        letter-spacing:-0.1ex;
                        text-combine-upright: horizontal;
                        -webkit-text-combine: horizontal;
                        -epub-text-combine: horizontal;
                    }
                    /* 傍点 */
                    .sesami {
                        text-emphasis-style : sesame;
                        text-emphasis-color : #333333;
                        -epub-text-emphasis-style : sesame;
                        -epub-text-emphasis-color : #333333;
                        -webkit-text-emphasis-style : sesame;
                        -webkit-text-emphasis-color : #333333;
                    }
                    .emphasisDots span{
                        text-emphasis-style : sesame;
                        text-emphasis-color : #333333;
                        -epub-text-emphasis-style : sesame;
                        -epub-text-emphasis-color : #333333;
                        -webkit-text-emphasis-style : sesame;
                        -webkit-text-emphasis-color : #333333;
                    }
                    .ten {
                        text-emphasis-style : dot;
                        text-emphasis-color : #333333;
                        -epub-text-emphasis-style : dot;
                        -epub-text-emphasis-color : #333333;
                        -webkit-text-emphasis-style : dot;
                        -webkit-text-emphasis-color : #333333;
                    }
                    h1{
                        text-indent:0em;
                        font-size:1.1em;
                        font-weight:bold;
                    }
                    h1.normal-title{
                        margin:0em 1em 0em 2em;
                    }
                    h2{
                        text-indent:1em;
                        font-size:1.1em;
                        font-weight:bold;
                    }
                    h2.komidashi0{
                        padding-right:1em;
                    }
                    h3{
                        text-indent:2em;
                        font-size:1em;
                        font-weight:bold;
                    }
                    img{
                        width:auto;
                        height:auto;
                        max-width:100%;
                        max-height:100%;
                    }
                    b{
                        font-weight:bold;
                    }
                    i{
                        font-style:italic;
                    }
                    p{
                        text-indent:0;
                        margin:0;
                    }
                    p.line-indent1{
                        text-indent:1em;
                    }
                    p.line-indent05{
                        text-indent:0.5em;
                    }
                    /* 字下げ */
                    p.paragraph-indent1{
                        padding-top:1em;
                        text-indent:1em;
                    }
                    p.paragraph-indent2{
                        padding-top:2em;
                        text-indent:1em;
                    }
                    p.paragraph-indent3{
                        padding-top:3em;
                        text-indent:1em;
                    }
                    p.paragraph-indent4{
                        padding-top:4em;
                        text-indent:1em;
                    }
                    p.paragraph-indent5{
                        padding-top:5em;
                        text-indent:1em;
                    }
                    /* 指定したブロックの直後で改ページ */
                    .pagebreak-after {
                    page-break-after:  always;
                    }
                    /* 指定したブロックの直前で改ページ */
                    .pagebreak-before {
                    page-break-before: always;
                    }
                    /* 指定したブロックの前後で改ページ */
                    .pagebreak-both {
                    page-break-before: always;
                    page-break-after:  always;
                    }

                    /* 挿絵 */
                    div.sashie{
                        margin:0;
                        padding:0;
                        width:100%;
                        text-align:center;
                    }
                    div.sashie img{
                        vertical-align:top;
                        width:auto;
                        height:auto;
                    }

                    /* cover.xhtml */
                    body.coverpage{
                        margin:0;
                        padding:0;
                        text-align:center;
                    }
                    body.coverpage div{
                        margin:0;
                        padding:0;
                        width:100%;
                        text-align:center;
                    }
                    body.coverpage div img{
                        vertical-align:top;
                        width:auto;
                        height:auto;
                    }

                    /* 扉ページ（縦書き中央配置） */
                    div.tobira-page{
                        width:100%;
                    }
                    div.tobira-text{
                        margin-left:auto;
                        margin-right:auto;
                        padding-top:1em;
                        -epub-writing-mode:vertical-rl;
                        writing-mode:vertical-rl;
                        height:100%;
                    }
                    div.tobira-text h1{
                        font-size:1.2em;
                        text-indent:0;
                    }
                    div.tobira-text p.subtitle{
                        font-size:0.8em;
                        padding-top:4em;
                    }

                    /* 了 完 終*/
                    p.endmark{
                        text-align:right;
                    }
                    /* ● ◆ */
                    p.kugirimark{
                        padding-top:3em;
                    }
                    /* image */
                    .image-wrap{
                        clear:both;
                        padding:0;
                        margin:0.2em;
                    }

                    .-epub-media-overlay-active {
                        background-color:#ffff99;
                        color:#000000;
                    }

                    p.status_name{
                        text-align:right;
                        font-size:0.9em;
                    }
                    """),
        ]
    }

    public var depth: Depth
    public var colophon: [ColophonElement]?

    public var navigationFileName: String? { "nav.xhtml" }

    public enum Depth: Int {
        case one = 1
        case two = 2
    }

    public enum ColophonElement {
        case heading(String)
        case paragraph(String)
        case horizontalRule
    }

    public enum SectionNumberingStyle {
        case flat
        case hierarchical
    }

    public init(
        depth: Depth,
        colophon: [ColophonElement]? = nil
    ) {
        self.depth = depth
        self.colophon = colophon
    }
}

extension FancyVrtlEpubBuilder {
    func buildCoverPage(book: Book) -> ContentPage? {
        guard let coverImageName = book.coverImageName else { return nil }
        return ContentPage(
            name: "cover.xhtml",
            language: book.language,
            head: .init(title: book.title, styles: ["reset.css", "bookstyle.css"]),
            body: """
                <div class="coverpage">
                <img src="../images/\(coverImageName)" alt="cover" />
                </div>
                """
        )
    }

    func buildTitlePage(book: Book) -> ContentPage {
        ContentPage(
            name: "title.xhtml",
            language: book.language,
            head: .init(title: book.title, styles: ["reset.css", "bookstyle.css"]),
            body: """
                <div class="horizontal tobira-page"><div class="tobira-text"><h1>\(book.title)</h1></div></div>
                """
        )
    }

    func buildColophonPage(book: Book) -> ContentPage? {
        guard let colophon = colophon else { return nil }
        let body = colophon.map { element in
            switch element {
            case .heading(let text):
                return "<h1 style=\"font-size:1em; font-weight:normal;\">\(text)</h1>"
            case .paragraph(let text):
                return "<p style=\"margin:0.75em 0;\">\(text)</p>"
            case .horizontalRule:
                return "<hr style=\"margin:1em 0;\" />"
            }
        }.joined(separator: "\n")

        return ContentPage(
            name: "colophon.xhtml",
            language: book.language,
            head: .init(title: book.title, styles: ["reset.css"]),
            body: body
        )
    }

    struct PageInfo {
        var pageNumber: Int
        var children: [PageInfo]
    }

    func buildNavigationBody(book: Book) -> String {
        switch depth {
        case .one:
            let items = book.sections.enumerated().map { (index, section) in
                return "<li><a href=\"p-\(String(format: "%03d", index + 1)).xhtml\">\(section.title)</a></li>"
            }.joined(separator: "\n")
            return """
                <nav epub:type="toc">
                <h1>Contents</h1>
                <ol>
                \(items)
                </ol>
                </nav>
                """
        case .two:
            var pageCounter = 0
            var items: [String] = []
            for section in book.sections {
                items.append("<li><a href=\"p-\(String(format: "%03d", pageCounter + 1)).xhtml\">\(section.title)</a>")
                if !section.subsections.isEmpty {
                    items.append("<ol>")
                    for subsection in section.subsections {
                        pageCounter += 1
                        items.append("<li><a href=\"p-\(String(format: "%03d", pageCounter)).xhtml\">\(subsection.title)</a></li>")
                    }
                    items.append("</ol>")
                }
                items.append("</li>")
            }
            return """
                <nav epub:type="toc">
                <h1>Contents</h1>
                <ol>
                \(items.joined(separator: "\n"))
                </ol>
                </nav>
                """
        }
    }

    func buildVerticalNavigationPage(book: Book) -> ContentPage {
        let body = buildNavigationBody(book: book)
        return ContentPage(
            name: "nav.xhtml",
            language: book.language,
            head: .init(title: book.title, styles: ["reset.css", "bookstyle.css"]),
            body: body
        )
    }

    func buildContentPageNames(book: Book) -> [(name: String, subsectionNames: [String])] {
        var counter = 0
        switch depth {
        case .one:
            return book.sections.map { section in
                counter += 1
                return ("p-\(String(format: "%03d", counter)).xhtml", [])
            }
        case .two:
            return book.sections.map { section in
                let thisSectionName = "p-\(String(format: "%03d", counter + 1)).xhtml"
                let subsectionNames = section.subsections.map { subsection in
                    counter += 1
                    return "p-\(String(format: "%03d", counter)).xhtml"
                }
                return (thisSectionName, subsectionNames)
            }
        }
    }
}

extension FancyVrtlEpubBuilder: EpubBuilder {
    func contentBody(section: BookSection) -> String {
        let body = section.content.map { content in
            switch content {
            case .paragraph(let text):
                return "<p>\(text)</p>"
            case .image(let name):
                return "<p><div class=\"sashie\"><img src=\"../images/\(name)\" /></div></p>"
            }
        }.joined(separator: "\n")
        return """
            <p><br/></p>
            <div class="tobira-text" style="font-size: 1.30em">\(section.title)</div>
            <p><br/></p>
            \(body)
            """
    }

    public func buildContentPages(book: Book) -> [ContentPage] {
        let sections = book.sections
        guard sections.allSatisfy({ $0.depth == depth.rawValue }) else {
            fatalError("All sections must have the same depth as the builder's depth.")
        }

        let contentPageNames = buildContentPageNames(book: book)
        let contentPages: [ContentPage]

        switch depth {
        case .one:
            contentPages = zip(sections, contentPageNames).map { (section, name) in
                ContentPage(
                    name: name.name,
                    language: book.language,
                    head: .init(title: section.title, styles: ["reset.css", "bookstyle.css"]),
                    body: contentBody(section: section)
                )
            }
        case .two:
            contentPages = zip(sections, contentPageNames).flatMap { (section, names) in
                zip(sections, names.subsectionNames).map { (section, name) in
                    ContentPage(
                        name: name,
                        language: book.language,
                        head: .init(title: section.title, styles: ["reset.css", "bookstyle.css"]),
                        body: contentBody(section: section)
                    )
                }
            }
        }

        guard contentPages.count <= 999 else {
            fatalError("Too many content pages. The current implementation supports up to 999 pages.")
        }

        return [buildCoverPage(book: book), buildTitlePage(book: book), buildVerticalNavigationPage(book: book)].compactMap { $0 }
            + contentPages + [buildColophonPage(book: book)].compactMap { $0 }
    }
}