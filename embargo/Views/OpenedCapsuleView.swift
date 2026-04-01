import SwiftUI
import SwiftData

struct OpenedCapsuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let capsule: Capsule

    @State private var showDeleteConfirmation = false
    @State private var audioManager = AudioManager()
    @State private var appeared = false
    @State private var backTrigger = false
    @State private var deleteTrigger = false
    @State private var shareTrigger = false
    @State private var sealBackTrigger = false
    @State private var showCreateSheet = false
    @State private var playTrigger = false
    @State private var zoomedPhoto = false

    var body: some View {
        VStack(spacing: 0) {
            // Header — pinned at top
            VStack(spacing: 10) {
                Text(capsule.title.isEmpty ? capsule.type.label : capsule.title)
                    .font(.title3.weight(.medium))
                    .tracking(Design.trackingWide)

                HStack(spacing: 20) {
                    Label(Design.formatDateShort(capsule.createdAt), systemImage: "calendar.badge.plus")
                    Label(capsule.openedAt.map { Design.formatDateShort($0) } ?? "—", systemImage: "lock.open")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .tracking(Design.trackingTight)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Content — centered in remaining space
            GeometryReader { geo in
                ScrollView {
                    Group {
                        switch capsule.type {
                        case .text:
                            Text(Design.renderMarkdown(capsule.textContent))
                                .font(.body)
                                .fontDesign(.serif)
                                .tracking(Design.trackingTight)
                                .lineSpacing(6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(24)
                                .background(Design.surface)
                                .clipShape(.rect(cornerRadius: Design.radiusLarge))
                                .overlay {
                                    RoundedRectangle(cornerRadius: Design.radiusLarge)
                                        .strokeBorder(Design.border, lineWidth: 1)
                                }
                                .textSelection(.enabled)

                        case .photo:
                            if let data = capsule.imageData, let uiImage = downsampledImage(data: data, maxDimension: UITraitCollection.current.displayScale * 400) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(.rect(cornerRadius: Design.radiusLarge))
                                    .onTapGesture { zoomedPhoto = true }
                                    .accessibilityAddTraits(.isButton)
                                    .accessibilityLabel("zoom photo")
                            }

                        case .voice:
                            VStack(spacing: 20) {
                                AnimatedWaveformView(isPlaying: audioManager.isPlaying)
                                    .padding(.horizontal, 16)

                                if audioManager.isPlaying {
                                    ProgressView(value: audioManager.playbackTime, total: max(audioManager.playbackDuration, 0.01))
                                        .tint(.primary)
                                        .padding(.horizontal, 24)
                                }

                                Button(audioManager.isPlaying ? "stop" : "play", systemImage: audioManager.isPlaying ? "stop.fill" : "play.fill") {
                                    playTrigger.toggle()
                                    if audioManager.isPlaying {
                                        audioManager.stopPlayback()
                                    } else if let fileName = capsule.audioFileName {
                                        audioManager.play(fileName: fileName)
                                    }
                                }
                                .labelStyle(.iconOnly)
                                .font(.title2)
                                .foregroundStyle(Design.bg)
                                .frame(width: 64, height: 64)
                                .background(Design.fg)
                                .clipShape(.circle)
                                .buttonStyle(.plain)
                                .sensoryFeedback(.impact(weight: .light), trigger: playTrigger)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 36)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 80)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .frame(minHeight: geo.size.height)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .overlay { FloatingParticlesView().ignoresSafeArea() }
        .overlay(alignment: .bottom) {
            HStack(spacing: 16) {
                Button {
                    backTrigger.toggle()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Design.bg)
                        .frame(width: 48, height: 48)
                        .background(Design.fg)
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: backTrigger)

                Spacer()

                if capsule.isReceived {
                    Button {
                        sealBackTrigger.toggle()
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Design.bg)
                            .frame(width: 48, height: 48)
                            .background(Design.fg)
                            .clipShape(.circle)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .medium), trigger: sealBackTrigger)
                }

                Button {
                    shareTrigger.toggle()
                    shareContent()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Design.bg)
                        .frame(width: 48, height: 48)
                        .background(Design.fg)
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: shareTrigger)

                Button {
                    deleteTrigger.toggle()
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Design.bg)
                        .frame(width: 48, height: 48)
                        .background(Design.fg)
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.warning, trigger: deleteTrigger)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Design.bg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
        .onDisappear {
            audioManager.stopPlayback()
        }
        .confirmationDialog("let it go?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("annihilate", role: .destructive) {
                if let audioFile = capsule.audioFileName {
                    audioManager.deleteAudioFile(named: audioFile)
                }
                NotificationManager.cancelCapsuleNotification(id: capsule.id.uuidString)
                modelContext.delete(capsule)
                dismiss()
            }
        } message: {
            Text("this moment will be lost in time. like tears in the rain. there is no undoing this.")
        }
        .fullScreenCover(isPresented: $zoomedPhoto) {
            if let data = capsule.imageData, let uiImage = UIImage(data: data) {
                ZoomablePhotoView(image: uiImage, onDismiss: { zoomedPhoto = false })
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateCapsuleView()
        }
    }

    private func shareContent() {
        var items: [Any] = []
        switch capsule.type {
        case .text:
            if let text = capsule.textContent {
                // Strip markdown markers, keep plain text with paragraph breaks
                let plain = text
                    .replacing("***", with: "")
                    .replacing("**", with: "")
                    .replacing("*", with: "")
                items.append(plain)
            }
        case .photo:
            if let data = capsule.imageData, let image = UIImage(data: data) { items.append(image) }
        case .voice:
            if let fileName = capsule.audioFileName {
                let url = URL.documentsDirectory.appending(path: fileName)
                if FileManager.default.fileExists(atPath: url.path) { items.append(url) }
            }
        }
        guard !items.isEmpty else { return }
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            // Find the topmost presented VC (handles sheets, nav stacks, etc.)
            var topVC = root
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(ac, animated: true)
        }
    }

    private func downsampledImage(data: Data, maxDimension: CGFloat) -> UIImage? {
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

// MARK: - Zoomable Photo View

private struct ZoomablePhotoView: View {
    let image: UIImage
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = lastScale * value.magnification
                        }
                        .onEnded { _ in
                            lastScale = max(1.0, scale)
                            if scale < 1.0 {
                                withAnimation(.spring(response: 0.3)) { scale = 1.0 }
                                lastScale = 1.0
                            }
                        }
                        .simultaneously(with:
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1.0 {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                    if scale <= 1.0 {
                                        withAnimation(.spring(response: 0.3)) { offset = .zero }
                                        lastOffset = .zero
                                    }
                                }
                        )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring(response: 0.3)) {
                        if scale > 1.0 {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.5
                            lastScale = 2.5
                        }
                    }
                }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.2))
                            .clipShape(.circle)
                    }
                    .buttonStyle(.plain)
                    .padding(20)
                }
                Spacer()
            }
        }
    }
}
