// えり字でヒーロータイトルを2色・透過PNGに書き出す（CoreText）
import Foundation
import CoreText
import AppKit

let fontPath = "/Users/yui/Desktop/フォント/えり字/えり字.otf"
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/hero-title.png"

CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: fontPath) as CFURL, .process, nil)
let fontSize: CGFloat = 220
guard let font = NSFont(name: "ERIJI", size: fontSize) else { print("フォント生成失敗"); exit(1) }

let ink = NSColor(srgbRed: 0x1a/255.0, green: 0x25/255.0, blue: 0x30/255.0, alpha: 1)
let accent = NSColor(srgbRed: 0x2b/255.0, green: 0x6c/255.0, blue: 0xb0/255.0, alpha: 1)

func makeLine(_ parts: [(String, NSColor)]) -> CTLine {
    let s = NSMutableAttributedString()
    for (text, color) in parts {
        s.append(NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color]))
    }
    return CTLineCreateWithAttributedString(s)
}
let line1 = makeLine([("信頼でつなぐ、", ink)])
let line2 = makeLine([("人を想う仕事", accent), ("がここに。", ink)])

func bounds(_ line: CTLine) -> (w: CGFloat, asc: CGFloat, desc: CGFloat) {
    var a: CGFloat = 0, d: CGFloat = 0, l: CGFloat = 0
    let w = CTLineGetTypographicBounds(line, &a, &d, &l)
    return (CGFloat(w), a, d)
}
let b1 = bounds(line1), b2 = bounds(line2)
let pad: CGFloat = fontSize * 0.16
let gap: CGFloat = fontSize * 0.34
let lineH = b1.asc + b1.desc
let imgW = ceil(max(b1.w, b2.w) + pad * 2)
let imgH = ceil(lineH * 2 + gap + pad * 2)

guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imgW), pixelsHigh: Int(imgH),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
      let ctx = NSGraphicsContext(bitmapImageRep: rep)?.cgContext else { print("ctx失敗"); exit(1) }

let y1 = imgH - pad - b1.asc
ctx.textPosition = CGPoint(x: pad, y: y1)
CTLineDraw(line1, ctx)
let y2 = y1 - lineH - gap
ctx.textPosition = CGPoint(x: pad, y: y2)
CTLineDraw(line2, ctx)

if let data = rep.representation(using: .png, properties: [:]) {
    try? data.write(to: URL(fileURLWithPath: outPath))
    print("出力:", outPath, "/ \(Int(imgW)) x \(Int(imgH))")
}
