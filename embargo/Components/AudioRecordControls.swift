import SwiftUI
import AVFoundation

struct AudioRecordControls: View {
    @Bindable var audioManager: AudioManager
    let onRecordingStarted: (String) -> Void

    @State private var recordTrigger = false
    @State private var pulsing = false
    @State private var showMicDenied = false

    var body: some View {
        VStack(spacing: 20) {
            Button(audioManager.isRecording ? "stop recording" : "start recording", systemImage: audioManager.isRecording ? "stop.fill" : "mic.fill") {
                recordTrigger.toggle()
                if audioManager.isRecording {
                    audioManager.stopRecording()
                } else {
                    requestMicAccess()
                }
            }
            .labelStyle(.iconOnly)
            .font(.title2)
            .foregroundStyle(audioManager.isRecording ? Design.bg : .primary)
            .frame(width: 80, height: 80)
            .background(audioManager.isRecording ? Design.fg : Design.surface)
            .clipShape(.circle)
            .overlay {
                Circle()
                    .stroke(Color.primary.opacity(audioManager.isRecording ? 0.3 : 0), lineWidth: 1)
                    .scaleEffect(pulsing ? 1.4 : 1.0)
                    .opacity(pulsing ? 0 : 1)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .medium), trigger: recordTrigger)
            .onChange(of: audioManager.isRecording) { _, recording in
                if recording {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { pulsing = true }
                } else {
                    pulsing = false
                }
            }

            if audioManager.isRecording {
                Text(Duration.seconds(audioManager.recordingTime), format: .time(pattern: .minuteSecond))
                    .font(.system(.title3, design: .monospaced, weight: .ultraLight))
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            } else {
                Text("tap to record")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingNormal)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: audioManager.isRecording)
        .alert("microphone access needed", isPresented: $showMicDenied) {
            Button("open settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("cancel", role: .cancel) {}
        } message: {
            Text("lacuna needs microphone access to record voice notes for your time capsules. you can enable it in settings.")
        }
    }

    private func requestMicAccess() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            if let fileName = audioManager.startRecording() {
                onRecordingStarted(fileName)
            }
        case .undetermined:
            Task {
                let granted = await AVAudioApplication.requestRecordPermission()
                if granted {
                    if let fileName = audioManager.startRecording() {
                        onRecordingStarted(fileName)
                    }
                } else {
                    showMicDenied = true
                }
            }
        case .denied:
            showMicDenied = true
        @unknown default:
            showMicDenied = true
        }
    }
}
