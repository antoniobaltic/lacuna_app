import SwiftUI

struct AudioPlaybackControls: View {
    @Bindable var audioManager: AudioManager
    let fileName: String
    let onDelete: () -> Void
    @State private var playTrigger = false
    @State private var deleteTrigger = false

    var body: some View {
        VStack(spacing: 24) {
            AnimatedWaveformView(isPlaying: audioManager.isPlaying)
                .padding(.horizontal, 24)

            if audioManager.isPlaying {
                ProgressView(value: audioManager.playbackTime, total: max(audioManager.playbackDuration, 0.01))
                    .tint(.primary)
                    .padding(.horizontal, 32)
            }

            HStack(spacing: 32) {
                Button(audioManager.isPlaying ? "stop" : "play", systemImage: audioManager.isPlaying ? "stop.fill" : "play.fill") {
                    playTrigger.toggle()
                    if audioManager.isPlaying {
                        audioManager.stopPlayback()
                    } else {
                        audioManager.play(fileName: fileName)
                    }
                }
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(width: 56, height: 56)
                .background(Design.surface)
                .clipShape(.circle)
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: playTrigger)

                Button("delete recording", systemImage: "xmark") {
                    deleteTrigger.toggle()
                    onDelete()
                }
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 56, height: 56)
                .background(Design.surface)
                .clipShape(.circle)
                .buttonStyle(.plain)
                .sensoryFeedback(.warning, trigger: deleteTrigger)
            }
        }
    }
}
