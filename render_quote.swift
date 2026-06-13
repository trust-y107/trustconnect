// vision.html の引用文を えり字 で青色・透過PNGに書き出す（1行・漢字大きめ・細め）
import Foundation
import CoreText
import AppKit

let fontPath = "/Users/yui/Desktop/フォント/えり字/えり字.otf"
CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: fontPath) as CFURL, .process, nil)
let fontSize: CGFloat = 200
let kanaSize = fontSize * 0.84
let kern = -fontSize * 0.10
let color = NSColor(srgbRed: 0x2b/255.0, green: 0x6c/255.0, blue: 0xb0/255.0, alpha: 1)

func isKanji(_ s: Unicode.Scalar) -> Bool {
    let v = s.value
    return (v >= 0x4E00 && v <= 0x9FFF) || (v >= 0x3400 && v <= 0x4DBF) || (v >= 0xF900 && v <= 0xFAFF)
}

let text = "信頼でつなぐ、人を想う仕事がここに。"
let s = NSMutableAttributedString()
for ch in text {
    let k = ch.unicodeScalars.contains(where: isKanji)
    guard let f = NSFont(name: "ERIJI", size: k ? fontSize : kanaSize) else { continue }
    s.append(NSAttributedString(string: String(ch), attributes: [.font: f, .foregroundColor: color, .kern: kern]))
}
let line = CTLineCreateWithAttributedString(s)
var a: CGFloat = 0, d: CGFloat = 0, l: CGFloat = 0
let w = CGFloat(CTLineGetTypographicBounds(line, &a, &d, &l))
let pad: CGFloat = fontSize * 0.10
let imgW = ceil(w + pad * 2), imgH = ceil(a + d + pad * 2)
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imgW), pixelsHigh: Int(imgH),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
      let ctx = NSGraphicsContext(bitmapImageRep: rep)?.cgContext else { exit(1) }
ctx.textPosition = CGPoint(x: pad, y: imgH - pad - a)
CTLineDraw(line, ctx)
try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "images/vision-quote.png"))
print("出力: images/vision-quote.png / \(Int(imgW)) x \(Int(imgH))")
