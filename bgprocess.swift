// 背景の切り抜き＆ぼかしを行うスクリプト（macOS Vision / Core Image）
// 使い方: swift bgprocess.swift <入力画像のパス>
//   → 同じフォルダに team_cutout.png（切り抜き）と team_blur.png（背景ぼかし）を出力
import Foundation
import Vision
import CoreImage
import AppKit

guard CommandLine.arguments.count >= 2 else {
    print("usage: swift bgprocess.swift <input-image>"); exit(1)
}
let inputPath = CommandLine.arguments[1]
let dir = (inputPath as NSString).deletingLastPathComponent

guard let nsimg = NSImage(contentsOfFile: inputPath),
      let tiff = nsimg.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let cgImage = bitmap.cgImage else {
    print("画像を読み込めませんでした: \(inputPath)"); exit(1)
}

let ctx = CIContext()
let inputCI = CIImage(cgImage: cgImage)

// 前景（人物）のマスクを生成
let request = VNGenerateForegroundInstanceMaskRequest()
let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
do {
    try handler.perform([request])
} catch {
    print("Vision 解析に失敗: \(error)"); exit(2)
}
guard let result = request.results?.first else {
    print("人物（前景）を検出できませんでした"); exit(3)
}

// 人物だけを切り抜いた画像（背景は透明）
guard let maskedPB = try? result.generateMaskedImage(
        ofInstances: result.allInstances, from: handler,
        croppedToInstancesExtent: false) else {
    print("マスク生成に失敗"); exit(4)
}
let subjectCI = CIImage(cvPixelBuffer: maskedPB)

func savePNG(_ image: CIImage, _ path: String) {
    guard let cg = ctx.createCGImage(image, from: image.extent) else {
        print("書き出し失敗: \(path)"); return
    }
    let rep = NSBitmapImageRep(cgImage: cg)
    if let data = rep.representation(using: .png, properties: [:]) {
        try? data.write(to: URL(fileURLWithPath: path))
        print("出力: \(path)")
    }
}

// 1) 切り抜き版（背景透明）
savePNG(subjectCI, dir + "/team_cutout.png")

// 2) 背景ぼかし版（背景だけぼかし、人物はくっきり）
let blurred = inputCI.clampedToExtent()
    .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 16])
    .cropped(to: inputCI.extent)
let composite = subjectCI.composited(over: blurred)
savePNG(composite, dir + "/team_blur.png")

print("完了")
