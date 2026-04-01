import AVFoundation

/// Synthesizes a single deep resonant tone for the capsule reveal ceremony.
/// No external audio files — pure mathematics.
enum RevealTone {
    private static var engine: AVAudioEngine?
    private static var playerNode: AVAudioPlayerNode?

    /// Play a deep resonant tone with slow decay. Call once at the moment of "the break."
    static func play() {
        // Don't interrupt user's music — use ambient session
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: .mixWithOthers)
        try? session.setActive(true)

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let sampleRate: Double = 44100
        let duration: Double = 2.5
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }

        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        // Fundamental frequency: deep tone ~160Hz
        let fundamental: Float = 160.0
        // Overtone: gentle fifth above ~240Hz
        let overtone: Float = 240.0
        // Sub-harmonic: weight at ~80Hz
        let sub: Float = 80.0

        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)
            let progress = t / Float(duration)

            // Envelope: quick attack (50ms), long exponential decay
            let attack: Float = min(t / 0.05, 1.0)
            let decay: Float = exp(-2.5 * progress)
            let envelope = attack * decay

            // Layered sine waves with harmonics
            let wave = sin(2.0 * .pi * fundamental * t) * 0.5         // fundamental
                     + sin(2.0 * .pi * overtone * t) * 0.15           // gentle overtone
                     + sin(2.0 * .pi * sub * t) * 0.25                // sub-harmonic weight
                     + sin(2.0 * .pi * fundamental * 2.0 * t) * 0.08  // second harmonic

            // Apply envelope and master volume
            data[i] = wave * envelope * 0.35
        }

        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, completionHandler: nil)

            // Hold references until playback completes, then clean up
            Self.engine = engine
            Self.playerNode = player

            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
                player.stop()
                engine.stop()
                Self.engine = nil
                Self.playerNode = nil
                try? session.setActive(false, options: .notifyOthersOnDeactivation)
            }
        } catch {
            // Silent failure — haptics still carry the moment
        }
    }
}
