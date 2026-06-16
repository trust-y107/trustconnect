// 価値観カードの見出し3つを えり字 で（漢字大きめ・複数行・濃インク）透過PNGに書き出す
import Foundation
import CoreText
import AppKit

let fontPath = "/Users/yui/Desktop/フォント/えり字/えり字.otf"
CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: fontPath) as CFURL, .process, nil)
let fontSize: CGFloat = 100
let kanaSize = fontSize * 0.84
let kern = -fontSize * 0.08
let ink = NSColor(srgbRed: 0x1a/255.0, green: 0x25/255.0, blue: 0x30/255.0, alpha: 1)

func isKanji(_ s: Unicode.Scalar) -> Bool {
    let v = s.value
    return (v >= 0x4E00 && v <= 0x9FFF) || (v >= 0x3400 && v <= 0x4DBF) || (v >= 0xF900 && v <= 0xFAFF)
}
func line(_ text: String) -> CTLine {
    let s = NSMutableAttributedString()
    for ch in text {
        let k = ch.unicodeScalars.contains(where: isKanji)
        guard let f = NSFont(name: "ERIJI", size: k ? fontSize : kanaSize) else { continue }
        s.append(NSAttributedString(string: String(ch), attributes: [.font: f, .foregroundColor: ink, .kern: kern]))
    }
    return CTLineCreateWithAttributedString(s)
}

func render(_ lines: [String], _ out: String) {
    let cts = lines.map { line($0) }
    var asc: CGFloat = 0, desc: CGFloat = 0, maxW: CGFloat = 0
    for ct in cts {
        var a: CGFloat = 0, d: CGFloat = 0, l: CGFloat = 0
        let w = CGFloat(CTLineGetTypographicBounds(ct, &a, &d, &l))
        asc = max(asc, a); desc = max(desc, d); maxW = max(maxW, w)
    }
    let lineH = asc + desc
    let gap = fontSize * 0.34
    let pad = fontSize * 0.08
    let imgW = ceil(maxW + pad * 2)
    let imgH = ceil(lineH * CGFloat(cts.count) + gap * CGFloat(cts.count - 1) + pad * 2)
    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imgW), pixelsHigh: Int(imgH),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
          let ctx = NSGraphicsContext(bitmapImageRep: rep)?.cgContext else { return }
    var y = imgH - pad - asc
    for ct in cts {
        ctx.textPosition = CGPoint(x: pad, y: y)
        CTLineDraw(ct, ctx)
        y -= (lineH + gap)
    }
    try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: out))
    print("出力:", out, "/ \(Int(imgW)) x \(Int(imgH))")
}

render(["愛され、信頼される", "存在であること"], "images/value-title-01.png")
render(["一人ひとりに寄り添うこと"], "images/value-title-02.png")
render(["社員も、関わるすべての人も、", "安心して幸せに"], "images/value-title-03.png")
