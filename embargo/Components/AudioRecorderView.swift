import SwiftUI

struct AudioRecorderView: View {
    @Bindable var audioManager: AudioManager
    @Binding var recordedFileName: String?

    var body: some View {
        VStack(spacing: 24) {
            if let fileName = recordedFileName, !audioManager.isRecording {
                AudioPlaybackControls(
                    audioManager: audioManager,
                    fileName: fileName,
                    onDelete: {
                        audioManager.stopPlayback()
                        audioManager.deleteAudioFile(named: fileName)
                        recordedFileName = nil
                    }
                )
            } else {
                AudioRecordControls(
                    audioManager: audioManager,
                    onRecordingStarted: { fileName in
                        recordedFileName = fileName
                    }
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
