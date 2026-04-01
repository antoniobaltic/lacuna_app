import SwiftUI
import UIKit

struct TextContentEditor: View {
    @Binding var textContent: String
    @State private var isFocused = false
    @State private var boldActive = false
    @State private var italicActive = false
    @State private var textView: UITextView?
    @State private var formatTrigger = false
    @State private var doneTapTrigger = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if textContent.isEmpty && !isFocused {
                    Text("someone will read this...")
                        .font(.body)
                        .fontDesign(.serif)
                        .tracking(Design.trackingNormal)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }

                RichTextEditor(
                    text: $textContent,
                    isFocused: $isFocused,
                    boldActive: $boldActive,
                    italicActive: $italicActive,
                    textViewRef: $textView
                )
                .frame(minHeight: 180)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }

            Divider().overlay(Design.divider)

            HStack(spacing: 8) {
                Button { formatTrigger.toggle(); toggleTrait(.traitBold) } label: {
                    Text("B")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(boldActive ? Design.bg : .secondary)
                        .frame(width: 32, height: 28)
                        .background(boldActive ? Color.primary : .clear)
                        .clipShape(.rect(cornerRadius: Design.radiusSmall))
                }
                .buttonStyle(.plain)

                Button { formatTrigger.toggle(); toggleTrait(.traitItalic) } label: {
                    Text("I")
                        .font(Font(UIFont(descriptor: UIFont.systemFont(ofSize: 15, weight: .regular).fontDescriptor.withDesign(.serif)!.withSymbolicTraits(.traitItalic)!, size: 15)))
                        .foregroundStyle(italicActive ? Design.bg : .secondary)
                        .frame(width: 32, height: 28)
                        .background(italicActive ? Color.primary : .clear)
                        .clipShape(.rect(cornerRadius: Design.radiusSmall))
                }
                .buttonStyle(.plain)

                Spacer()

                if isFocused {
                    Button { doneTapTrigger.toggle(); textView?.resignFirstResponder() } label: {
                        Text("done")
                            .font(.subheadline.weight(.medium))
                            .tracking(Design.trackingNormal)
                            .foregroundStyle(Design.bg)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.primary)
                            .clipShape(.rect(cornerRadius: Design.radiusSmall))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .sensoryFeedback(.selection, trigger: formatTrigger)
            .sensoryFeedback(.impact(weight: .light), trigger: doneTapTrigger)
        }
        .background(Design.surface)
        .clipShape(.rect(cornerRadius: Design.radiusMedium))
        .overlay {
            RoundedRectangle(cornerRadius: Design.radiusMedium)
                .strokeBorder(Design.border, lineWidth: 1)
        }
    }

    private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard let tv = textView else { return }

        let baseFont = Design.editorBaseFont
        let range = tv.selectedRange

        if range.length > 0 {
            // Selection exists — toggle trait on selected text
            let mutable = NSMutableAttributedString(attributedString: tv.attributedText)
            mutable.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
                guard let font = value as? UIFont else { return }
                let currentTraits = font.fontDescriptor.symbolicTraits
                var newTraits = currentTraits
                if currentTraits.contains(trait) {
                    newTraits.remove(trait)
                } else {
                    newTraits.insert(trait)
                }
                let descriptor = baseFont.fontDescriptor.withSymbolicTraits(newTraits) ?? baseFont.fontDescriptor
                let newFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                mutable.addAttribute(.font, value: newFont, range: subRange)
            }
            tv.attributedText = mutable
            tv.selectedRange = range

            // Sync to binding
            textContent = Design.nsAttributedStringToMarkdown(tv.attributedText)
        } else {
            // No selection — toggle typing attributes for next input
            var attrs = tv.typingAttributes
            let currentFont = attrs[.font] as? UIFont ?? baseFont
            let currentTraits = currentFont.fontDescriptor.symbolicTraits
            var newTraits = currentTraits
            if currentTraits.contains(trait) {
                newTraits.remove(trait)
            } else {
                newTraits.insert(trait)
            }
            let descriptor = baseFont.fontDescriptor.withSymbolicTraits(newTraits) ?? baseFont.fontDescriptor
            attrs[.font] = UIFont(descriptor: descriptor, size: baseFont.pointSize)
            tv.typingAttributes = attrs
        }

        // Update button states
        updateTraitStates(from: tv)
    }

    private func updateTraitStates(from tv: UITextView) {
        let font = tv.typingAttributes[.font] as? UIFont ?? Design.editorBaseFont
        let traits = font.fontDescriptor.symbolicTraits
        boldActive = traits.contains(.traitBold)
        italicActive = traits.contains(.traitItalic)
    }
}

// MARK: - UITextView wrapper

private struct RichTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    @Binding var boldActive: Bool
    @Binding var italicActive: Bool
    @Binding var textViewRef: UITextView?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.typingAttributes = Design.editorBaseAttributes

        // Load initial text as rich text from markdown
        if !text.isEmpty {
            textView.attributedText = Design.markdownToNSAttributedString(text)
        }

        DispatchQueue.main.async {
            textViewRef = textView
        }

        context.coordinator.textView = textView
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        guard !context.coordinator.isUpdatingFromUIKit else { return }
        // No external text sync needed — all edits happen through UITextView directly
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        var isUpdatingFromUIKit = false
        weak var textView: UITextView?

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            isUpdatingFromUIKit = true
            parent.text = Design.nsAttributedStringToMarkdown(textView.attributedText)
            DispatchQueue.main.async { [weak self] in
                self?.isUpdatingFromUIKit = false
            }
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            // Update bold/italic button states based on current cursor position
            let font = textView.typingAttributes[.font] as? UIFont ?? Design.editorBaseFont
            let traits = font.fontDescriptor.symbolicTraits
            DispatchQueue.main.async { [weak self] in
                self?.parent.boldActive = traits.contains(.traitBold)
                self?.parent.italicActive = traits.contains(.traitItalic)
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.isFocused = true
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.isFocused = false
            }
        }
    }
}
