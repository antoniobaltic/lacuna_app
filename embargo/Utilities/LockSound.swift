import AVFoundation

/// Synthesizes lock mechanism sounds for the capsule reveal ceremony.
/// Two sounds: tension (ratchet clicks during anticipation) and release (metallic snap at unlock).
enum LockSound {
    private static var tensionEngine: AVAudioEngine?
    private static var tensionPlayer: AVAudioPlayerNode?
    private static var releaseEngine: AVAudioEngine?
    private static var releasePlayer: AVAudioPlayerNode?

    /// Ascending ratchet clicks that build tension. Call at phase1 start.
    static func playTension() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: .mixWithOthers)
        try? session.setActive(true)

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let sampleRate: Double = 44100
        let duration: Double = 0.85
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }

        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        // 4 ascending clicks spaced ~180ms apart
        let clickFrequencies: [Float] = [300, 340, 390, 440]
        let clickDuration: Float = 0.022   // 22ms per click
        let clickSpacing: Float = 0.19     // 190ms between click starts
        let masterVolume: Float = 0.18

        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)
            var sample: Float = 0

            for (clickIndex, freq) in clickFrequencies.enumerated() {
                let clickStart = Float(clickIndex) * clickSpacing
                let clickTime = t - clickStart

                if clickTime >= 0 && clickTime < clickDuration {
                    let progress = clickTime / clickDuration
                    // Sharp attack, fast exponential decay
                    let envelope = exp(-8.0 * progress)
                    // Primary tone + slight harmonic for metallic character
                    let wave = sin(2.0 * .pi * freq * clickTime) * 0.7
                             + sin(2.0 * .pi * freq * 2.5 * clickTime) * 0.3
                    sample += wave * envelope
                }
            }

            data[i] = sample * masterVolume
        }

        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, completionHandler: nil)

            Self.tensionEngine = engine
            Self.tensionPlayer = player

            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.3) {
                player.stop()
                engine.stop()
                Self.tensionEngine = nil
                Self.tensionPlayer = nil
            }
        } catch {}
    }

    /// Sharp metallic click-snap. Call at phase2 (the break).
    static func playRelease() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: .mixWithOthers)
        try? session.setActive(true)

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let sampleRate: Double = 44100
        let duration: Double = 0.18
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }

        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        let masterVolume: Float = 0.28

        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)

            // Layer 1: Sharp high transient (800Hz, 30ms)
            let highEnvelope: Float = t < 0.03 ? exp(-40.0 * t) : 0
            let high = sin(2.0 * .pi * 800 * t) * 0.6
                     + sin(2.0 * .pi * 1200 * t) * 0.2

            // Layer 2: Lower resonance (200Hz, full duration)
            let lowAttack: Float = min(t / 0.002, 1.0)
            let lowDecay: Float = exp(-12.0 * t)
            let low = sin(2.0 * .pi * 200 * t) * 0.5
                    + sin(2.0 * .pi * 400 * t) * 0.15

            let sample = high * highEnvelope + low * lowAttack * lowDecay
            data[i] = sample * masterVolume
        }

        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, completionHandler: nil)

            Self.releaseEngine = engine
            Self.releasePlayer = player

            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.3) {
                player.stop()
                engine.stop()
                Self.releaseEngine = nil
                Self.releasePlayer = nil
            }
        } catch {}
    }
}
