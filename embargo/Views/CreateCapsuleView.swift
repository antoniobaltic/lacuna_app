import SwiftUI
import SwiftData
import PhotosUI

struct CreateCapsuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(StoreManager.self) private var storeManager
    @Query(sort: \Capsule.createdAt) private var allCapsules: [Capsule]

    @State private var step = CreateStep.selectType
    @State private var selectedType: CapsuleType?
    @State private var title = ""
    @State private var textContent = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var audioFileName: String?
    @State private var unlockDate = Date.now.addingTimeInterval(86400)
    @State private var audioManager = AudioManager()
    @State private var typeTrigger = false
    @State private var stepTrigger = false
    @State private var goingForward = true
    @State private var cancelTrigger = false
    @State private var swipeBackTrigger = false
    @State private var shareFileURL: URL?
    @State private var pendingSenderName = ""
    @State private var paywallReason: PaywallReason?
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false

    private var canProceed: Bool {
        switch step {
        case .selectType: selectedType != nil
        case .addContent: hasContent
        case .pickDate: unlockDate > Date.now
        case .confirm: true
        }
    }

    private var activeSealedTextCount: Int {
        allCapsules.filter { $0.isLocal && $0.isSealed && $0.type == .text }.count
    }

    private var activeSealedPhotoCount: Int {
        allCapsules.filter { $0.isLocal && $0.isSealed && $0.type == .photo }.count
    }

    private var activeSealedVoiceCount: Int {
        allCapsules.filter { $0.isLocal && $0.isSealed && $0.type == .voice }.count
    }

    private var hasContent: Bool {
        switch selectedType {
        case .text: !textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .photo: imageData != nil
        case .voice: audioFileName != nil && !audioManager.isRecording
        case nil: false
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("new capsule")
                        .font(.title3.weight(.medium))
                        .tracking(Design.trackingWide)

                    Spacer()

                    Button {
                        cancelTrigger.toggle()
                        cleanup()
                        dismiss()
                    } label: {
                        Text("cancel")
                            .font(.body.weight(.medium))
                            .tracking(Design.trackingNormal)
                            .foregroundStyle(Design.bg)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Design.fg)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: cancelTrigger)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)

                StepProgressBar(currentStep: step)

                Group {
                    switch step {
                    case .selectType:
                        TypeSelectionStep(
                            selectedType: $selectedType,
                            typeTrigger: $typeTrigger
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                        ))
                    case .addContent:
                        ContentInputStep(
                            selectedType: selectedType,
                            textContent: $textContent,
                            selectedPhoto: $selectedPhoto,
                            imageData: $imageData,
                            audioFileName: $audioFileName,
                            audioManager: audioManager
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                        ))
                    case .pickDate:
                        DateSelectionStep(unlockDate: $unlockDate)
                            .transition(.asymmetric(
                            insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                        ))
                    case .confirm:
                        ConfirmSealStep(
                            title: $title,
                            selectedType: selectedType,
                            unlockDate: unlockDate,
                            onSeal: { sealCapsule() },
                            onSend: { senderName in sendCapsule(senderName: senderName) },
                            canSend: storeManager.canSend,
                            onSendPaywall: {
                                paywallReason = .sendGated
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture(minimumDistance: 40)
                        .onEnded { value in
                            // Swipe right to go back
                            if value.translation.width > 80, abs(value.translation.height) < 50, step.rawValue > 0 {
                                if let prev = CreateStep(rawValue: step.rawValue - 1) {
                                    swipeBackTrigger.toggle()
                                    goingForward = false
                                    withAnimation(Design.springSnappy) {
                                        step = prev
                                    }
                                }
                            }
                        }
                )
                .background(Design.bg)

                if step == .selectType {
                    Text("who exactly made\nthe choice though?")
                        .font(.caption)
                        .tracking(Design.trackingWide)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.15 : 0.4) : 0))
                        .offset(y: whisperAppeared ? 0 : 8)
                        .padding(.bottom, 40)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.2).delay(1.0)) { whisperAppeared = true }
                            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.2)) { whisperBreathing = true }
                        }
                }

                if step != .confirm {
                    Button(step == .selectType ? "i made my choice" : "continue") {
                        // Check pro limits when advancing from type selection
                        if step == .selectType, let type = selectedType {
                            if !storeManager.canCreate(type: type, activeSealedText: activeSealedTextCount, activeSealedPhoto: activeSealedPhotoCount, activeSealedVoice: activeSealedVoiceCount) {
                                if type == .text {
                                    paywallReason = .textLimit
                                } else if type == .photo {
                                    paywallReason = .photoLimit
                                } else {
                                    paywallReason = .voiceGated
                                }
                                return
                            }
                        }
                        stepTrigger.toggle()
                        goingForward = true
                        withAnimation(Design.springSnappy) {
                            if let next = CreateStep(rawValue: step.rawValue + 1) {
                                step = next
                            }
                        }
                    }
                    .font(.body.weight(.medium))
                    .tracking(Design.trackingButton)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? Design.fg : Design.surface)
                    .foregroundStyle(canProceed ? Design.bg : .secondary)
                    .clipShape(.rect(cornerRadius: Design.radiusMedium))
                    .disabled(!canProceed)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .sensoryFeedback(.impact(weight: .light), trigger: stepTrigger)
                }
            }
            .background(Design.bg.ignoresSafeArea())
            .overlay { FloatingParticlesView().allowsHitTesting(false).ignoresSafeArea() }
            .toolbar(.hidden, for: .navigationBar)
            .interactiveDismissDisabled(step != .selectType)
            .sensoryFeedback(.selection, trigger: typeTrigger)
            .sensoryFeedback(.selection, trigger: swipeBackTrigger)
            .sheet(item: $paywallReason) { reason in
                PaywallView(storeManager: storeManager, reason: reason)
            }
            .onChange(of: notificationManager.pendingCapsuleID) { _, id in
                if id != nil {
                    cleanup()
                    dismiss()
                }
            }
        }
    }

    private func sealCapsule() {
        // Convert audio file to inline Data for iCloud sync
        let audioData: Data? = if let audioFileName, selectedType == .voice {
            audioManager.loadAudioData(for: audioFileName)
        } else {
            nil
        }

        let capsule = Capsule(
            title: title,
            type: selectedType ?? .text,
            textContent: selectedType == .text ? textContent : nil,
            imageData: selectedType == .photo ? imageData : nil,
            audioData: audioData,
            unlocksAt: unlockDate
        )
        modelContext.insert(capsule)
        NotificationManager.scheduleCapsuleNotification(
            id: capsule.id.uuidString,
            title: title,
            unlockDate: unlockDate
        )

        // Trigger 3: After sealing the 2nd capsule — user is hooked
        let totalLocal = allCapsules.filter(\.isLocal).count + 1
        if totalLocal == 2 {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                RatingManager.requestIfEligible()
            }
        }

        dismiss()
    }

    private func sendCapsule(senderName: String) {
        let audioData: Data? = if let audioFileName, selectedType == .voice {
            audioManager.loadAudioData(for: audioFileName)
        } else {
            nil
        }

        // Package the capsule data for export (don't insert into DB yet)
        let tempCapsule = Capsule(
            title: title,
            type: selectedType ?? .text,
            textContent: selectedType == .text ? textContent : nil,
            imageData: selectedType == .photo ? imageData : nil,
            audioData: audioData,
            unlocksAt: unlockDate,
            isSent: true
        )

        guard let fileURL = CapsuleExporter.export(capsule: tempCapsule, senderName: senderName) else { return }
        shareFileURL = fileURL
        pendingSenderName = senderName

        // Present share sheet via UIKit to avoid SwiftUI sheet conflicts
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(600))
            presentShareSheet(url: fileURL)
        }
    }

    private func presentShareSheet(url: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.rootViewController else { return }

        // Find the topmost presented view controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        let shareItem = CapsuleShareItem(fileURL: url, unlockDate: unlockDate)
        let appStoreLink = "https://apps.apple.com/app/lacuna-time-capsule/id6761478231"
        let message = "i sealed a time capsule for you. download lacuna to open it: \(appStoreLink)"
        let activityVC = UIActivityViewController(activityItems: [message, shareItem], applicationActivities: nil)
        // Exclude iMessage — custom file types can't be opened from iMessage
        activityVC.excludedActivityTypes = [.message]
        activityVC.completionWithItemsHandler = { _, completed, _, _ in
            // Clean up temp file
            try? FileManager.default.removeItem(at: url)
            self.shareFileURL = nil

            if completed {
                self.saveSentCapsule()
            }
        }

        topVC.present(activityVC, animated: true)
    }

    private func saveSentCapsule() {
        let audioData: Data? = if let audioFileName, selectedType == .voice {
            audioManager.loadAudioData(for: audioFileName)
        } else {
            nil
        }

        // Only called after share sheet completes successfully
        let capsule = Capsule(
            title: title,
            type: selectedType ?? .text,
            textContent: selectedType == .text ? textContent : nil,
            imageData: selectedType == .photo ? imageData : nil,
            audioData: audioData,
            unlocksAt: unlockDate,
            isSent: true
        )
        modelContext.insert(capsule)
        NotificationManager.scheduleCapsuleNotification(
            id: capsule.id.uuidString,
            title: title,
            unlockDate: unlockDate
        )
        dismiss()
    }

    private func cleanup() {
        if audioManager.isRecording { audioManager.stopRecording() }
        if audioManager.isPlaying { audioManager.stopPlayback() }
        if let audioFile = audioFileName { audioManager.deleteAudioFile(named: audioFile) }
    }
}
