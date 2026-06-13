// 事業内容ページのカードタグ（番号のみ 01/02）を えり字 で青・透過PNGに書き出す
import Foundation
import CoreText
import AppKit

let fontPath = "/Users/yui/Desktop/フォント/えり字/えり字.otf"
CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: fontPath) as CFURL, .process, nil)
let fontSize: CGFloat = 150
guard let font = NSFont(name: "ERIJI", size: fontSize) else { print("font失敗"); exit(1) }
let blue = NSColor(srgbRed: 0x3b/255.0, green: 0x82/255.0, blue: 0xc4/255.0, alpha: 1)

for (t, out) in [("01", "images/label-biz-detail-01.png"), ("02", "images/label-biz-detail-02.png")] {
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: t, attributes: [
        .font: font, .foregroundColor: blue, .kern: -fontSize * 0.03,
    ]))
    var a: CGFloat = 0, d: CGFloat = 0, l: CGFloat = 0
    let w = CGFloat(CTLineGetTypographicBounds(line, &a, &d, &l))
    let pad: CGFloat = fontSize * 0.12
    let imgW = ceil(w + pad * 2), imgH = ceil(a + d + pad * 2)
    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imgW), pixelsHigh: Int(imgH),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
          let ctx = NSGraphicsContext(bitmapImageRep: rep)?.cgContext else { continue }
    ctx.textPosition = CGPoint(x: pad, y: imgH - pad - a)
    CTLineDraw(line, ctx)
    try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: out))
    print("出力:", out, "/ \(Int(imgW)) x \(Int(imgH))")
}
