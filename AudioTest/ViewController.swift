//
//  ViewController.swift
//  AudioTest
//
//  Created by Alex Yoshida on 2024-05-15.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var player = AVPlayer()
    
    
    let engine = AVAudioEngine()  // Allows pitch-shifting
    let audioPlayer = AVAudioPlayerNode()
    let pitchControl = AVAudioUnitTimePitch()
    var soundBuffers = AVAudioPCMBuffer()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        createAudiobutton()
        createPlaybutton()
        setupPlayer()
        setupAudio()
        NotificationCenter.default.addMainObserver(forName: .AVPlayerItemDidPlayToEndTime, owner: self, action: ViewController.videoFinished)
    }
    
    func createAudiobutton(){
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 50, y: 200, width: 100, height: 50)
        button.backgroundColor = .green
        button.setTitle("Audio", for: .normal)
        
        button.addTarget(self, action: #selector(didTapAudio), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    func createPlaybutton(){
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 200, y: 200, width: 100, height: 50)
        button.backgroundColor = .red
        button.setTitle("Play Video", for: .normal)
        
        button.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    @objc private func didTapAudio(){
        print("audio")
        SoundManager.main.playSound("that_was_easy.mp3")
    }
    
    @objc private func didTapPlay(){
        print("play")
        player.play()
    }
    
    private func setupPlayer() {
        guard let path = Bundle.main.path(forResource: "app_intro", ofType:"mp4") else {
            debugPrint("Video not found")
            return
        }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.frame
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
    }
    
    private func setupAudio() {
        SoundManager.main.preloadSounds()
    }
    
    private func videoFinished(_ notification: Notification? = nil) {
        print ("Video done")
        player.pause()
        player = AVPlayer()
        setupPlayer()
    }
    
   
}

extension NotificationCenter {
    
    @discardableResult
    public func addMainObserver <T: AnyObject>(forName name: NSNotification.Name?, object obj: Any? = nil, owner: T, action: @escaping (T)->(Notification) -> Void) -> NSObjectProtocol {
        return addObserver(forName: name, object: obj, queue: OperationQueue.main, using: weakify(owner: owner, f: action))
    }
    
    private func weakify <T: AnyObject>(owner: T, f: @escaping (T)->(Notification) -> Void) -> ((Notification) -> Void) {
        return { [weak owner] obj in
            if let owner = owner {
                f(owner)(obj)
            }
        }
    }
}


public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Float {
        return Float.random(in: 0 ... 1)
    }
    
    /// Random float between min and max (inclusive).
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}
