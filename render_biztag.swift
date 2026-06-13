// 事業内容ページのカードタグ（NN — テキスト）を えり字 で青・透過PNGに。
// えり字に em dash が無いため、ダッシュは手描きで補う。
import Foundation
import CoreText
import AppKit

let fontPath = "/Users/yui/Desktop/フォント/えり字/えり字.otf"
CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: fontPath) as CFURL, .process, nil)
let fontSize: CGFloat = 96
guard let font = NSFont(name: "ERIJI", size: fontSize) else { print("font失敗"); exit(1) }
let blue = NSColor(srgbRed: 0x3b/255.0, green: 0x82/255.0, blue: 0xc4/255.0, alpha: 1)
let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: blue, .kern: -fontSize * 0.02]

func bounds(_ line: CTLine) -> (w: CGFloat, a: CGFloat, d: CGFloat) {
    var a: CGFloat = 0, d: CGFloat = 0, l: CGFloat = 0
    let w = CGFloat(CTLineGetTypographicBounds(line, &a, &d, &l))
    return (w, a, d)
}

func renderTag(_ prefix: String, _ suffix: String, _ out: String) {
    let pl = CTLineCreateWithAttributedString(NSAttributedString(string: prefix, attributes: attrs))
    let sl = CTLineCreateWithAttributedString(NSAttributedString(string: suffix, attributes: attrs))
    let pb = bounds(pl), sb = bounds(sl)
    let asc = max(pb.a, sb.a), desc = max(pb.d, sb.d)
    let dashW = fontSize * 0.5, gap = fontSize * 0.2, dashThick = fontSize * 0.05
    let pad = fontSize * 0.14
    let imgW = ceil(pad * 2 + pb.w + gap + dashW + gap + sb.w)
    let imgH = ceil(asc + desc + pad * 2)
    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imgW), pixelsHigh: Int(imgH),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
          let ctx = NSGraphicsContext(bitmapImageRep: rep)?.cgContext else { return }
    let baseY = imgH - pad - asc
    ctx.textPosition = CGPoint(x: pad, y: baseY)
    CTLineDraw(pl, ctx)
    // 手描きダッシュ（文字の中ほどに）
    let dashX = pad + pb.w + gap
    let dashY = baseY + asc * 0.30
    ctx.setFillColor(blue.cgColor)
    ctx.fill(CGRect(x: dashX, y: dashY - dashThick / 2, width: dashW, height: dashThick))
    ctx.textPosition = CGPoint(x: dashX + dashW + gap, y: baseY)
    CTLineDraw(sl, ctx)
    try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: out))
    print("出力:", out, "/ \(Int(imgW)) x \(Int(imgH))")
}

renderTag("01", "自社事業", "images/label-biz-detail-01.png")
renderTag("02", "セールスプロモーション", "images/label-biz-detail-02.png")
