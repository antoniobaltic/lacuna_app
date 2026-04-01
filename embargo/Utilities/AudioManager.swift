import AVFoundation
import Observation

@Observable
@MainActor
final class AudioManager: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var isRecording = false
    var isPlaying = false
    var recordingTime: TimeInterval = 0
    var playbackTime: TimeInterval = 0
    var playbackDuration: TimeInterval = 0

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var recordingTask: Task<Void, Never>?
    private var playbackTask: Task<Void, Never>?
    private var currentFileName: String?

    static func audioFileURL(for fileName: String) -> URL {
        URL.documentsDirectory.appending(path: fileName)
    }

    func startRecording() -> String? {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            return nil
        }

        let fileName = "\(UUID().uuidString).m4a"
        let url = Self.audioFileURL(for: fileName)
        currentFileName = fileName

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.delegate = self
            recorder?.record()
            isRecording = true
            recordingTime = 0
            recordingTask = Task { @MainActor [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(100))
                    self?.recordingTime += 0.1
                }
            }
            return fileName
        } catch {
            return nil
        }
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false
        recordingTask?.cancel()
        recordingTask = nil
    }

    func play(fileName: String) {
        let url = Self.audioFileURL(for: fileName)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            isPlaying = true
            playbackDuration = player?.duration ?? 0
            playbackTime = 0
            playbackTask = Task { @MainActor [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(50))
                    self?.playbackTime = self?.player?.currentTime ?? 0
                }
            }
        } catch {
            isPlaying = false
        }
    }

    func stopPlayback() {
        player?.stop()
        player = nil
        isPlaying = false
        playbackTask?.cancel()
        playbackTask = nil
        playbackTime = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func deleteAudioFile(named fileName: String) {
        let url = Self.audioFileURL(for: fileName)
        try? FileManager.default.removeItem(at: url)
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.handlePlaybackFinished()
        }
    }

    private func handlePlaybackFinished() {
        isPlaying = false
        playbackTask?.cancel()
        playbackTask = nil
        playbackTime = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
