//
//  SoundManager.swift
//  AudioTest
//
//  Created by Alex Yoshida on 2024-05-15.
//

import UIKit
import AVFoundation

class SoundManager: NSObject {

    static let main = SoundManager()
    
    var soundPlayers = [String: AVAudioPlayer]() // Basic pre-loaded players. Can control volume and rate, but not pitch
    
    let engine = AVAudioEngine()  // Allows pitch-shifting
    var audioPlayer = AVAudioPlayerNode()
    let pitchControl = AVAudioUnitTimePitch()
    var soundFile = [String: AVAudioFile]() // Using buffers instead of AVAudioFiles because they can be scheduled much more quickly
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        
        engine.connect(audioPlayer, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("AUDIO: \tEngine error: \(error).")
        }
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: nil)
    }
    
    // MARK: - Public Methods
    
    // AVAudioPlayer version
//    public func preloadSounds() {
//        guard soundPlayers.count < Test.Animal.allCases.count else {
//            return // They're already loaded
//        }
//
//        for animal in Test.Animal.allCases where soundPlayers[animal.audioName] == nil {
//            let filename = animal.audioName
//            if  let url = Bundle.main.url(forResource: filename, withExtension: nil),
//                let player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: "mp3")
//            {
//                player.enableRate = true
//                player.prepareToPlay()
//                soundPlayers[filename] = player
//                print("AUDIO: \tLoaded \(filename)", terminator: ", ")
//            } else {
//                Helper.warning("\nCouldn't preload sound: \(filename)")
//            }
//        }
//        print ("\nPreloading -- \(soundPlayers.count) audio files are ready")
//    }
    
    // AVAudioEngine version
    public func preloadSounds() {
            
        if  let url = Bundle.main.url(forResource: "that_was_easy.mp3", withExtension: nil),
        let player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: "mp3")
        {
            player.enableRate = true
            player.prepareToPlay()
            soundPlayers["that_was_easy.mp3"] = player
        } else {
            
        }
        
    }
    
    public func playSound(_ filename: String) {
        
        guard let player = soundPlayers[filename] else {
            print("")
            return
        }
        player.rate = 2
        try? engine.start() // If using this one, comment out the one in init
        player.play()
    }
    
    public func ensureEngineIsRunning() {
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                print ("Could not start engine! \(error)")
            }
        }
    }
    
    // MARK: - Private Helpers
    
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {

        case .began: ()
            // An interruption began. Update the UI as needed.

        case .ended:
           // An interruption ended. Resume playback, if appropriate.

            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption ended. Playback should resume.
                ensureEngineIsRunning()
            } else {
                // Interruption ended. Playback should not resume.
            }

        default: ()
        }
      }
}
