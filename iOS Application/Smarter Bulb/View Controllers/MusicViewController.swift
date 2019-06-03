//
//  MusicViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 27/03/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import Foundation
import AudioKit
import AudioKitUI
import MediaPlayer
import AudioIndicatorBars

class MusicViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    weak var delegate: ColorDelegate?
    
    @IBOutlet weak var songArt: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songAlbum: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var timeToSongEnding: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var indicator: AudioIndicatorBarsView!
    
    var player: AKPlayer!
    var tracker: AKFrequencyTracker!
    var songProperties: MPMediaItem!
    var sliderUpdater: CADisplayLink!
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for thisItem in mediaItemCollection.items {
            let itemUrl = thisItem.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL
            let file = try! AKAudioFile(forReading: itemUrl! as URL)
            
            songProperties = thisItem
            
            do {
                try AudioKit.stop()
            } catch {
                print("error")
            }
            player = AKPlayer(audioFile: file)
            player.buffering = .always
            tracker = AKFrequencyTracker(player)
            AudioKit.output = tracker
            
            do {
                try AudioKit.start()
            } catch {
                print("error")
            }
            
            player.play()
            indicator.start()
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            becomeFirstResponder()
            
            updateNowPlayingCenter()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playerSlider.maximumValue = Float(player.duration)
            
            AKPlaygroundLoop(every: 0.2) {
                if self.player.isPlaying {
                    //print(self.tracker.amplitude)
                    //print("\(self.tracker.frequency) Freq")
                    self.changeColor(freq: self.tracker.frequency ,amp: self.tracker.amplitude)
                    self.playerSlider.value = Float(self.player!.currentTime)
                    self.songArt.frame = CGRect(x: CGFloat(self.playerSlider.value/self.player.duration)*(-385), y: 0, width: 760, height: 760)
                    
                    let timeToEnd = self.player.endTime - self.player.currentTime
                    
                    let hours = Int(timeToEnd) / 3600
                    let minutes = Int(timeToEnd) / 60 % 60
                    let seconds = Int(timeToEnd) % 60
                    
                    if hours == 0 {
                        self.timeToSongEnding.text = String(format:"%02i:%02i", minutes, seconds)
                    } else {
                        self.timeToSongEnding.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                    }
                    
                    if hours == 0 && minutes == 0 && seconds == 0 {
                        self.player.stop()
                        self.indicator.stop()
                        self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                    }
                }
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateNowPlayingCenter() {
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: songProperties.title!,
            MPMediaItemPropertyArtist: songProperties.artist!,
            MPMediaItemPropertyArtwork: songProperties.artwork!,
            MPMediaItemPropertyAlbumTitle: songProperties.albumTitle!,
            MPMediaItemPropertyPlaybackDuration: songProperties.playbackDuration]
        
        songArt.image = songProperties.artwork?.image(at: CGSize(width: 760, height: 760))
        songTitle.text = songProperties.title
        songArtist.text = songProperties.albumArtist
        songAlbum.text = songProperties.albumTitle
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preparePlayer()
        player = AKPlayer()
        songArt.image = #imageLiteral(resourceName: "bg")
        prepareSlider()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(1.0).cgColor,
                                UIColor.black.withAlphaComponent(0.0).cgColor]
        gradientLayer.frame = songArt.frame
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.4)
        songArt.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func prepareSlider() {
        playerSlider.addTarget(self, action: #selector(self.handlePlayheadSliderTouchBegin), for: .touchDown)
        playerSlider.addTarget(self, action: #selector(self.handlePlayheadSliderTouchEnd), for: .touchUpInside)
        playerSlider.addTarget(self, action: #selector(self.handlePlayheadSliderTouchEnd), for: .touchUpOutside)
    }
    
    @IBAction func handlePlayheadSliderTouchBegin(_ sender: UISlider) {
        player.pause()
        indicator.stop()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    @IBAction func handlePlayheadSliderTouchEnd(_ sender: UISlider) {
        player.pauseTime = Double(sender.value)
        player.resume()
        indicator.start()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    func preparePlayer() {
        // Allow the app to play in the background
        do {
            try AKSettings.setSession(category: .playback)
        } catch {
            print("error")
        }
        
        AKSettings.playbackWhileMuted = true
        AKSettings.disableAVAudioSessionCategoryManagement = true
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(playOrPause))
    }
    
    @IBAction func playOrPause(_ sender: UIButton) {
        
        if player.isPaused {
            player.resume()
            indicator.start()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
        } else if player.isPlaying {
            player.pause()
            indicator.stop()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
        } else {
            
            showSongLibrary(self)
        }
    }
    
    @IBAction func showSongLibrary(_ sender: Any) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: {})
    }
    
    func changeColor(freq: Double, amp: Double) {
        
        let normalizedBrightness: CGFloat
        if amp > 1 {
            normalizedBrightness = 1
        } else {
            normalizedBrightness = CGFloat(amp)
        }
        
        var normalizedFreq = freq
        while normalizedFreq > 31.5 {
            normalizedFreq /= 2
        }
        
        var newColor: UIColor
        
        if (1 ..< MusicViewController.noteFrequencies[0]).contains(normalizedFreq){
            //newColor = .red
            newColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            // C note
        } else if (MusicViewController.noteFrequencies[0] ..< MusicViewController.noteFrequencies[1]).contains(normalizedFreq){
            //newColor = .yellow
            newColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            // D note
        } else if (MusicViewController.noteFrequencies[1] ..< MusicViewController.noteFrequencies[2]).contains(normalizedFreq){
            //newColor = .cyan
            newColor = #colorLiteral(red: 0.5, green: 0.146009326, blue: 0.8532956243, alpha: 1)
            // E note
        } else if (MusicViewController.noteFrequencies[2] ..< MusicViewController.noteFrequencies[3]).contains(normalizedFreq){
            //newColor = .purple
            newColor = #colorLiteral(red: 0.4989612103, green: 0.2157740789, blue: 0.8529566526, alpha: 1)
            // F note
        } else if (MusicViewController.noteFrequencies[3] ..< MusicViewController.noteFrequencies[4]).contains(normalizedFreq){
            //newColor = .orange
            newColor = #colorLiteral(red: 0.4992839694, green: 0.3814725823, blue: 0.8525800109, alpha: 1)
            // G note
        } else if (MusicViewController.noteFrequencies[4] ..< MusicViewController.noteFrequencies[5]).contains(normalizedFreq){
            //newColor = .green
            newColor = #colorLiteral(red: 0.5006639361, green: 0.6108959505, blue: 0.8509640694, alpha: 1)
            // A note
        } else {
            //newColor = .blue
            newColor = #colorLiteral(red: 0, green: 0.9060894692, blue: 0.9469735492, alpha: 1)
            // H note
        }
        
        delegate?.changeLampColor(newColor: newColor, newBrightness: normalizedBrightness)
    }
    
}

