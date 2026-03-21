import Foundation

struct Book {
    var title: String
    var author: String
    var cover: Data
    var images: [JpgFile]

    var chapters: [Chapter]
}

enum Content {
    case text(String)
    case image(String)
    case lineBreak
}

struct Chapter {
    var title: String
    var content: [Content]
}

extension Book {
    func toEpubStyle1(uuid: UUID = UUID()) -> EpubBook {
        guard images.allSatisfy({ $0.name != "cover.jpg" }) else {
            fatalError(
                "'cover.jpg' must be reserved for the cover image and not appear in the images array."
            )
        }

        let coverPage = TextFile(
            name: "cover.xhtml",
            content: """
                <?xml version="1.0" encoding="utf-8"?>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja"
                    xmlns:epub="http://www.classpf.org/2007/ops">
                <head>
                <link href="../style/reset.css" rel="stylesheet" type="text/css" />
                <link rel="stylesheet" type="text/css" href="../style/bookstyle.css" />
                <title>togetter</title>
                </head><body>
                <div class="coverpage">
                <img src="../images/cover.jpg" alt="cover" />
                </div>
                </body></html>
                """)

        let titlePage = TextFile(
            name: "title.xhtml",
            content: """
                <?xml version="1.0" encoding="utf-8"?>
                <!DOCTYPE html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja"
                    xmlns:epub="http://www.idpf.org/2007/ops">
                <head>
                <link href="../style/reset.css" rel="stylesheet" type="text/css" />
                <link rel="stylesheet" type="text/css" href="../style/bookstyle.css" />
                <title>\(title)</title>
                </head><body>
                <div class="horizontal tobira-page"><div class="tobira-text"><h1>\(title)</h1></div></div></body></html>
                """)

        let navigationPage = TextFile(
            name: "nav.xhtml",
            content: """
                <?xml version='1.0' encoding='utf-8'?>
                <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="ja" lang="ja">

                <head>
                    <link href="../style/reset.css" rel="stylesheet" type="text/css" />
                    <link rel="stylesheet" type="text/css" href="../style/bookstyle.css" />
                    <title>目次</title>
                </head>

                <body>
                    <nav epub:type="toc" id="nav">
                        <h1>Contents</h1>
                        <ol>
                            \(chapters.enumerated().map { index, chapter in
                        "<li><a href=\"p-\(String(format: "%04d", index + 1)).xhtml\">\(chapter.title)</a></li>"
                    }.joined(separator: "\n"))
                        </ol>
                    </nav>
                    <nav epub:type="landmarks" id="landmarks" hidden="hidden">
                        <h2 style="margin-top:2em;">Guide</h2>
                        <ol>
                            <li><a epub:type="cover" href="cover.xhtml">表紙</a></li>
                            <li><a epub:type="titlepage" href="title.xhtml">\(title)</a></li>
                            <li><a epub:type="toc" href="nav.xhtml">目次</a></li>
                        </ol>
                    </nav>
                </body>

                </html>
                """)

        let contents = chapters.enumerated().map { (index, chapter) in
            let body = chapter.content.map { content in
                switch content {
                case .text(let text):
                    return "<p>\(text)</p>"
                case .image(let source):
                    return "<p><div class=\"sashie\"><img src=\"../images/\(source)\" /></div></p>"
                case .lineBreak:
                    return "<p><br/></p>"
                }
            }.joined(separator: "\n")
            let content = """
                <?xml version="1.0" encoding="utf-8"?>
                <!DOCTYPE html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja"
                    xmlns:epub="http://www.idpf.org/2007/ops">
                <head>
                <link href="../style/reset.css" rel="stylesheet" type="text/css" />
                <link rel="stylesheet" type="text/css" href="../style/bookstyle.css" />
                <title>\(chapter.title)</title>
                </head><body>
                <div class="horizontal tobira-page"><div class="tobira-text"><h1>\(chapter.title)</h1></div></div>
                \(body)
                </body></html>
                """
            return TextFile(name: "p-\(String(format: "%04d", index + 1)).xhtml", content: content)
        }

        let styles = [
            TextFile(
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
            TextFile(
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

        return EpubBook(
            title: title, author: author, bookId: uuid, images: [JpgFile(name: "cover.jpg", data: cover)] + images, styles: styles,
            contents: [coverPage, titlePage, navigationPage] + contents)
    }
}
