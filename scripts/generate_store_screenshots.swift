#!/usr/bin/env swift

import AppKit
import Foundation

struct StoreShot {
    let source: String
    let output: String
    let kicker: String
    let headline: String
    let accent: NSColor
}

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    fputs("Usage: generate_store_screenshots.swift <raw-dir> <output-dir>\n", stderr)
    exit(2)
}

let rawDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)
let outputDirectory = URL(fileURLWithPath: arguments[2], isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let shots = [
    StoreShot(
        source: "01-home-tr.png",
        output: "01-bugun-ne-gunuymus.jpg",
        kicker: "HER GÜN YENİ BİR KEŞİF",
        headline: "Bugün ne\ngünüymüş?",
        accent: NSColor(calibratedRed: 0.49, green: 0.90, blue: 1.00, alpha: 1)
    ),
    StoreShot(
        source: "03-cat-day-tr.png",
        output: "02-aklina-biri-geldiyse.jpg",
        kicker: "GÖR · HATIRLA · GÖNDER",
        headline: "Aklına biri geldiyse\nbahane hazır.",
        accent: NSColor(calibratedRed: 0.85, green: 1.00, blue: 0.40, alpha: 1)
    ),
    StoreShot(
        source: "02-calendar-tr.png",
        output: "03-365-gun.jpg",
        kicker: "TÜM YIL TEK YERDE",
        headline: "365 gün.\nTek kaydırma.",
        accent: NSColor(calibratedRed: 0.56, green: 0.52, blue: 1.00, alpha: 1)
    ),
    StoreShot(
        source: "05-settings-tr.png",
        output: "04-her-sabah-surpriz.jpg",
        kicker: "İSTEĞE BAĞLI HATIRLATICI",
        headline: "Her sabah küçük\nbir sürpriz.",
        accent: NSColor(calibratedRed: 1.00, green: 0.70, blue: 0.38, alpha: 1)
    )
]

let canvasSize = NSSize(width: 1320, height: 2868)
let screenshotRect = NSRect(x: 175, y: 72, width: 970, height: 2107)

func drawText(_ text: String, rect: NSRect, font: NSFont, color: NSColor, paragraph: NSParagraphStyle? = nil) {
    var attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
    ]
    if let paragraph { attributes[.paragraphStyle] = paragraph }
    (text as NSString).draw(in: rect, withAttributes: attributes)
}

for shot in shots {
    let sourceURL = rawDirectory.appendingPathComponent(shot.source)
    guard let sourceImage = NSImage(contentsOf: sourceURL) else {
        fputs("Missing source image: \(sourceURL.path)\n", stderr)
        exit(3)
    }

    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width),
        pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fputs("Could not create bitmap context\n", stderr)
        exit(4)
    }
    bitmap.size = canvasSize
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics

    let context = graphics.cgContext

    let backgroundColors = [
        NSColor(calibratedRed: 0.035, green: 0.042, blue: 0.067, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.075, green: 0.075, blue: 0.135, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.025, green: 0.030, blue: 0.050, alpha: 1).cgColor
    ] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: backgroundColors, locations: [0, 0.55, 1])!
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: canvasSize.height),
        end: CGPoint(x: canvasSize.width, y: 0),
        options: []
    )

    context.saveGState()
    context.setFillColor(shot.accent.withAlphaComponent(0.18).cgColor)
    context.addEllipse(in: CGRect(x: 850, y: 2280, width: 720, height: 720))
    context.fillPath()
    context.restoreGState()

    drawText(
        "✦  WhaDay",
        rect: NSRect(x: 92, y: 2710, width: 500, height: 70),
        font: NSFont.systemFont(ofSize: 40, weight: .heavy),
        color: NSColor(calibratedWhite: 0.97, alpha: 1)
    )

    let pillRect = NSRect(x: 92, y: 2595, width: 570, height: 72)
    shot.accent.setFill()
    NSBezierPath(roundedRect: pillRect, xRadius: 36, yRadius: 36).fill()
    drawText(
        shot.kicker,
        rect: NSRect(x: 122, y: 2612, width: 520, height: 40),
        font: NSFont.systemFont(ofSize: 25, weight: .black),
        color: NSColor(calibratedRed: 0.05, green: 0.055, blue: 0.075, alpha: 1)
    )

    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = -8
    drawText(
        shot.headline,
        rect: NSRect(x: 88, y: 2200, width: 1140, height: 330),
        font: NSFont.systemFont(ofSize: 94, weight: .black),
        color: NSColor(calibratedWhite: 0.97, alpha: 1),
        paragraph: paragraph
    )

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -26), blur: 46, color: NSColor.black.withAlphaComponent(0.55).cgColor)
    NSColor.black.setFill()
    NSBezierPath(roundedRect: screenshotRect.insetBy(dx: -5, dy: -5), xRadius: 68, yRadius: 68).fill()
    context.restoreGState()

    context.saveGState()
    NSBezierPath(roundedRect: screenshotRect, xRadius: 62, yRadius: 62).addClip()
    sourceImage.draw(in: screenshotRect, from: .zero, operation: .copy, fraction: 1)
    context.restoreGState()

    shot.accent.withAlphaComponent(0.55).setStroke()
    let border = NSBezierPath(roundedRect: screenshotRect, xRadius: 62, yRadius: 62)
    border.lineWidth = 3
    border.stroke()

    NSGraphicsContext.restoreGraphicsState()

    guard let jpeg = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.96]) else {
        fputs("Could not encode \(shot.output)\n", stderr)
        exit(4)
    }

    try jpeg.write(to: outputDirectory.appendingPathComponent(shot.output))
    print("Generated \(shot.output)")
}
