import SwiftUI

/// Shared design constants for a monochrome, typography-driven aesthetic.
enum Design {
    // MARK: - Colors (creme-tinted, adapt to light/dark)
    static let bg = Color(.cremeBackground)
    static let fg = Color(.cremeForeground)
    static let surface = Color(.cremeSurface)
    static let surfaceElevated = Color(.systemGray5)
    static let border = Color.primary.opacity(0.1)
    static let divider = Color.primary.opacity(0.12)
    static let dimmed = Color.primary.opacity(0.4)

    // MARK: - Corner Radii (angular — no rounded edges)
    static let radiusSmall: Double = 0
    static let radiusMedium: Double = 0
    static let radiusLarge: Double = 0

    // MARK: - Typography Tracking
    static let trackingTight: Double = 0.5
    static let trackingNormal: Double = 1
    static let trackingWide: Double = 3
    static let trackingButton: Double = 4

    // MARK: - Animations
    static let springSnappy = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let springSoft = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let breathe = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)

    // MARK: - Ambient
    static let particleCount = 18
    static let particleMinSize: Double = 2.5
    static let particleMaxSize: Double = 5
    static let particleMinOpacity: Double = 0.06
    static let particleMaxOpacity: Double = 0.15
    static let particleDriftMin: Double = 12
    static let particleDriftMax: Double = 20

    // MARK: - Proximity Breathing
    static let breatheFarDuration: Double = 3.0
    static let breatheNearDuration: Double = 1.0

    // MARK: - Shockwave & Burst
    static let shockwaveScale: Double = 3.5
    static let shockwaveDuration: Double = 0.7
    static let burstScale: Double = 4.0
    static let burstDuration: Double = 0.9

    // MARK: - Date Formatting
    static func formatDate(_ date: Date) -> String {
        date.formatted(.dateTime.locale(Locale(identifier: "en_US")).month(.abbreviated).day().year())
    }

    static func formatDateShort(_ date: Date) -> String {
        date.formatted(.dateTime.locale(Locale(identifier: "en_US")).month(.abbreviated).day().year())
    }

    static func formatDateFull(_ date: Date) -> String {
        date.formatted(.dateTime.locale(Locale(identifier: "en_US")).month(.wide).day().year())
    }

    static func formatDateTime(_ date: Date) -> String {
        let base = formatDate(date)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(base), \(formatter.string(from: date))"
    }

    // MARK: - Markdown

    static func renderMarkdown(_ text: String?) -> AttributedString {
        guard let text, !text.isEmpty else { return AttributedString() }
        let nsAttr = markdownToNSAttributedString(text)
        return AttributedString(nsAttr)
    }

    // MARK: - Rich text ↔ Markdown

    static let editorParagraphStyle: NSMutableParagraphStyle = {
        let ps = NSMutableParagraphStyle()
        ps.lineSpacing = 2
        ps.paragraphSpacing = 12
        return ps
    }()

    static var editorBaseFont: UIFont {
        // New York (system serif) for capsule text — literary, warm, personal
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            .withDesign(.serif) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        return UIFont(descriptor: descriptor, size: 0) // size 0 = use text style's default
    }

    static var editorBaseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: editorBaseFont,
            .kern: trackingNormal,
            .paragraphStyle: editorParagraphStyle,
            .foregroundColor: UIColor.label
        ]
    }

    /// Convert markdown string → NSAttributedString with real bold/italic font traits
    static func markdownToNSAttributedString(_ markdown: String) -> NSAttributedString {
        guard !markdown.isEmpty else {
            return NSAttributedString(string: "", attributes: editorBaseAttributes)
        }

        let result = NSMutableAttributedString()
        let baseFont = editorBaseFont

        // Process line by line to preserve newlines
        let lines = markdown.components(separatedBy: "\n")
        for (lineIndex, line) in lines.enumerated() {
            // Parse inline markdown: ***bold+italic***, **bold**, *italic*
            var i = line.startIndex
            while i < line.endIndex {
                if line[i] == "*" {
                    // Count consecutive asterisks
                    var starCount = 0
                    var j = i
                    while j < line.endIndex && line[j] == "*" { starCount += 1; j = line.index(after: j) }

                    if starCount >= 2 {
                        // Look for closing **
                        let marker = starCount >= 3 ? "***" : "**"
                        let searchStart = j
                        if let closeRange = line.range(of: marker, range: searchStart..<line.endIndex) {
                            let content = String(line[searchStart..<closeRange.lowerBound])
                            var traits: UIFontDescriptor.SymbolicTraits = .traitBold
                            if starCount >= 3 { traits.insert(.traitItalic) }
                            let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) ?? baseFont.fontDescriptor
                            let styledFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                            var attrs = editorBaseAttributes
                            attrs[.font] = styledFont
                            result.append(NSAttributedString(string: content, attributes: attrs))
                            i = closeRange.upperBound
                            continue
                        }
                    } else if starCount == 1 {
                        // Look for closing *
                        let searchStart = j
                        if let closeRange = line.range(of: "*", range: searchStart..<line.endIndex) {
                            let content = String(line[searchStart..<closeRange.lowerBound])
                            let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitItalic) ?? baseFont.fontDescriptor
                            let styledFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                            var attrs = editorBaseAttributes
                            attrs[.font] = styledFont
                            result.append(NSAttributedString(string: content, attributes: attrs))
                            i = closeRange.upperBound
                            continue
                        }
                    }
                    // Unmatched asterisks — just output them
                    result.append(NSAttributedString(string: String(repeating: "*", count: starCount), attributes: editorBaseAttributes))
                    i = j
                } else {
                    // Regular character — collect run of non-* characters
                    var j = i
                    while j < line.endIndex && line[j] != "*" { j = line.index(after: j) }
                    result.append(NSAttributedString(string: String(line[i..<j]), attributes: editorBaseAttributes))
                    i = j
                }
            }
            if lineIndex < lines.count - 1 {
                result.append(NSAttributedString(string: "\n", attributes: editorBaseAttributes))
            }
        }

        return result
    }

    /// Convert NSAttributedString with font traits → markdown string
    static func nsAttributedStringToMarkdown(_ attrString: NSAttributedString) -> String {
        // Build per-character trait map, then emit markdown line by line
        // so markers never span across newlines
        let baseFont = editorBaseFont
        let string = attrString.string
        guard !string.isEmpty else { return "" }

        // Collect trait for each character
        struct CharInfo {
            let char: Character
            let isBold: Bool
            let isItalic: Bool
        }

        var chars: [CharInfo] = []
        attrString.enumerateAttributes(in: NSRange(location: 0, length: attrString.length), options: []) { attrs, range, _ in
            let font = attrs[.font] as? UIFont ?? baseFont
            let traits = font.fontDescriptor.symbolicTraits
            let isBold = traits.contains(.traitBold)
            let isItalic = traits.contains(.traitItalic)
            let sub = (attrString.string as NSString).substring(with: range)
            for ch in sub {
                chars.append(CharInfo(char: ch, isBold: isBold, isItalic: isItalic))
            }
        }

        // Emit markdown, closing/opening markers at every style change and newline
        var markdown = ""
        var currentBold = false
        var currentItalic = false

        func closeMarkers() {
            if currentItalic { markdown += "*"; currentItalic = false }
            if currentBold { markdown += "**"; currentBold = false }
        }

        func openMarkers(bold: Bool, italic: Bool) {
            if bold { markdown += "**"; currentBold = true }
            if italic { markdown += "*"; currentItalic = true }
        }

        for info in chars {
            if info.char == "\n" {
                closeMarkers()
                markdown += "\n"
                continue
            }

            let needBold = info.isBold
            let needItalic = info.isItalic

            if needBold != currentBold || needItalic != currentItalic {
                closeMarkers()
                openMarkers(bold: needBold, italic: needItalic)
            }

            markdown.append(info.char)
        }
        closeMarkers()

        return markdown
    }
}
