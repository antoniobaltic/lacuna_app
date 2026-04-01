import SwiftUI

struct VoicePlaybackView: View {
    let fileName: String
    @State private var audioManager = AudioManager()
    @State private var playTrigger = false

    var body: some View {
        VStack(spacing: 24) {
            AnimatedWaveformView(isPlaying: audioManager.isPlaying)
                .padding(.horizontal, 24)

            if audioManager.isPlaying {
                ProgressView(value: audioManager.playbackTime, total: max(audioManager.playbackDuration, 0.01))
                    .tint(.primary)
                    .padding(.horizontal, 40)
            }

            Button(audioManager.isPlaying ? "stop" : "play", systemImage: audioManager.isPlaying ? "stop.fill" : "play.fill") {
                playTrigger.toggle()
                if audioManager.isPlaying {
                    audioManager.stopPlayback()
                } else {
                    audioManager.play(fileName: fileName)
                }
            }
            .labelStyle(.iconOnly)
            .font(.title2)
            .foregroundStyle(Design.bg)
            .frame(width: 72, height: 72)
            .background(Design.fg)
            .clipShape(.circle)
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .light), trigger: playTrigger)
        }
        .onDisappear {
            audioManager.stopPlayback()
        }
    }
}
