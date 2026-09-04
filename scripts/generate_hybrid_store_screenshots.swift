#!/usr/bin/env swift

import AppKit
import Foundation

struct HybridShot {
    let concept: String
    let appScreen: String
    let output: String
    let headline: String
    let subtitle: String
    let screenOnRight: Bool
}

let arguments = CommandLine.arguments
guard arguments.count == 4 else {
    fputs("Usage: generate_hybrid_store_screenshots.swift <concept-dir> <app-screen-dir> <output-dir>\n", stderr)
    exit(2)
}

let conceptDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)
let screenDirectory = URL(fileURLWithPath: arguments[2], isDirectory: true)
let outputDirectory = URL(fileURLWithPath: arguments[3], isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let shots = [
    HybridShot(
        concept: "01-daily-card.png",
        appScreen: "01-home-tr.png",
        output: "01-bugun-ne-gunuymus.jpg",
        headline: "BUGÜN NE\nGÜNÜYMÜŞ?",
        subtitle: "Her gün birine yazmak için yeni bir bahane.",
        screenOnRight: true
    ),
    HybridShot(
        concept: "02-shared-countdown.png",
        appScreen: "02-shared-space-tr.png",
        output: "02-bizim-sayacimiz.jpg",
        headline: "BİZİM\nSAYACIMIZ",
        subtitle: "Ortak günler, geri sayımlar ve anılar tek yerde.",
        screenOnRight: true
    ),
    HybridShot(
        concept: "03-bet-certificate.png",
        appScreen: "day-club.png",
        output: "03-o-gunun-iddiasi.jpg",
        headline: "O GÜNÜN\nİDDİASI",
        subtitle: "Arkadaşınla iddiayı mühürle; zafer makbuzu hazır.",
        screenOnRight: false
    ),
    HybridShot(
        concept: "04-time-capsule.png",
        appScreen: "day-club.png",
        output: "04-muhurlu-kapsul.jpg",
        headline: "MÜHÜRLÜ ZAMAN\nKAPSÜLÜ",
        subtitle: "Bugünün notu, tam bir yıl sonra geri gelsin.",
        screenOnRight: true
    ),
    HybridShot(
        concept: "05-soundtrack.png",
        appScreen: "day-club.png",
        output: "05-gunun-sarkisi.jpg",
        headline: "GÜNÜN\nŞARKISI",
        subtitle: "Güne bir soundtrack iliştir; birlikte hatırlayın.",
        screenOnRight: false
    )
]

let canvasSize = NSSize(width: 1320, height: 2868)

func aspectFill(_ image: NSImage, in rect: NSRect) {
    let source = NSRect(origin: .zero, size: image.size)
    let scale = max(rect.width / source.width, rect.height / source.height)
    let scaled = NSSize(width: source.width * scale, height: source.height * scale)
    let destination = NSRect(
        x: rect.midX - scaled.width / 2,
        y: rect.midY - scaled.height / 2,
        width: scaled.width,
        height: scaled.height
    )
    image.draw(in: destination, from: source, operation: .copy, fraction: 1)
}

func drawText(_ text: String, rect: NSRect, font: NSFont, color: NSColor, lineSpacing: CGFloat = 0) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.lineSpacing = lineSpacing
    (text as NSString).draw(
        in: rect,
        withAttributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
    )
}

for shot in shots {
    let conceptURL = conceptDirectory.appendingPathComponent(shot.concept)
    let screenURL = screenDirectory.appendingPathComponent(shot.appScreen)
    guard let concept = NSImage(contentsOf: conceptURL), let screen = NSImage(contentsOf: screenURL) else {
        fputs("Missing input for \(shot.output)\n", stderr)
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
        exit(4)
    }

    bitmap.size = canvasSize
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics
    aspectFill(concept, in: NSRect(origin: .zero, size: canvasSize))

    let context = graphics.cgContext
    let fadeColors = [
        NSColor(calibratedWhite: 0.98, alpha: 0.98).cgColor,
        NSColor(calibratedWhite: 0.98, alpha: 0.83).cgColor,
        NSColor(calibratedWhite: 0.98, alpha: 0.00).cgColor
    ] as CFArray
    let fade = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: fadeColors, locations: [0, 0.67, 1])!
    context.drawLinearGradient(
        fade,
        start: CGPoint(x: 0, y: canvasSize.height),
        end: CGPoint(x: 0, y: 1730),
        options: []
    )

    let brandRect = NSRect(x: 76, y: 2690, width: 220, height: 64)
    NSColor.black.setFill()
    NSBezierPath(rect: brandRect).fill()
    drawText("✦  WHADAY", rect: NSRect(x: 94, y: 2704, width: 184, height: 36), font: .systemFont(ofSize: 24, weight: .black), color: .white)

    let headlineFont = NSFont(name: "Georgia-Bold", size: 94) ?? .systemFont(ofSize: 94, weight: .black)
    drawText(shot.headline, rect: NSRect(x: 76, y: 2250, width: 1168, height: 390), font: headlineFont, color: .black, lineSpacing: -8)
    drawText(shot.subtitle, rect: NSRect(x: 78, y: 2080, width: 1080, height: 150), font: .systemFont(ofSize: 47, weight: .medium), color: NSColor(calibratedWhite: 0.16, alpha: 1), lineSpacing: 4)

    let screenWidth: CGFloat = 530
    let screenHeight = screenWidth * (screen.size.height / screen.size.width)
    let screenX: CGFloat = shot.screenOnRight ? 710 : 80
    let screenRect = NSRect(x: screenX, y: 80, width: screenWidth, height: screenHeight)

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -20), blur: 36, color: NSColor.black.withAlphaComponent(0.32).cgColor)
    NSColor(calibratedWhite: 0.04, alpha: 1).setFill()
    NSBezierPath(roundedRect: screenRect.insetBy(dx: -12, dy: -12), xRadius: 62, yRadius: 62).fill()
    context.restoreGState()

    context.saveGState()
    NSBezierPath(roundedRect: screenRect, xRadius: 50, yRadius: 50).addClip()
    screen.draw(in: screenRect, from: .zero, operation: .copy, fraction: 1)
    context.restoreGState()

    NSGraphicsContext.restoreGraphicsState()

    guard let jpeg = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.96]) else { exit(5) }
    try jpeg.write(to: outputDirectory.appendingPathComponent(shot.output))
    print("Generated \(shot.output)")
}
