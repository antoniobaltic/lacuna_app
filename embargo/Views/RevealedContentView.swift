import SwiftUI

struct RevealedContentView: View {
    let capsule: Capsule
    let onDone: () -> Void
    let onSealBack: (() -> Void)?
    let showDone: Bool
    @State private var doneTrigger = false
    @State private var sealBackTrigger = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)

            Spacer()

            Group {
                switch capsule.type {
                case .text:
                    ScrollView {
                        Text(Design.renderMarkdown(capsule.textContent))
                            .font(.title3.weight(.light))
                            .fontDesign(.serif)
                            .tracking(Design.trackingTight)
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                case .photo:
                    if let data = capsule.imageData, let uiImage = Self.downsampledImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(.rect(cornerRadius: Design.radiusLarge))
                    }
                case .voice:
                    VoicePlaybackView(fileName: capsule.audioFileName ?? "")
                }
            }

            Spacer()

            // Bottom buttons
            VStack(spacing: 12) {
                if capsule.isReceived, let onSealBack {
                    Button {
                        sealBackTrigger.toggle()
                        onSealBack()
                    } label: {
                        Text("seal one back")
                            .font(.body.weight(.medium))
                            .tracking(Design.trackingButton)
                            .foregroundStyle(Design.bg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Design.fg)
                            .clipShape(.rect(cornerRadius: Design.radiusMedium))
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .medium), trigger: sealBackTrigger)
                }

                Button {
                    doneTrigger.toggle()
                    onDone()
                } label: {
                    Text("done")
                        .font(.body.weight(.medium))
                        .tracking(Design.trackingButton)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Design.surface)
                        .clipShape(.rect(cornerRadius: Design.radiusMedium))
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: doneTrigger)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .opacity(showDone ? 1 : 0)
        }
        .padding(.horizontal, 20)
    }

    private static func downsampledImage(data: Data) -> UIImage? {
        let maxDimension = UITraitCollection.current.displayScale * 400
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return UIImage(data: data)
        }
        return UIImage(cgImage: cgImage)
    }
}
