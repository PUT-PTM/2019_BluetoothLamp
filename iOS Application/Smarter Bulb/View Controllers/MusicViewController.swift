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

class MusicViewController: ViewController, MPMediaPickerControllerDelegate {
    
    weak var delegate: ColorDelegate?
    
    @IBOutlet weak var songArt: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playerSlider: UISlider!
    
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
            //player.buffering = .always
            tracker = AKFrequencyTracker(player)
            AudioKit.output = tracker
            
            do {
                try AudioKit.start()
            } catch {
                print("error")
            }
            
            player.play()
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            becomeFirstResponder()
            
            updateNowPlayingCenter()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            AKPlaygroundLoop(every: 0.1) {
                if self.player.isPlaying {
                    print(self.tracker.amplitude)
                    self.changeColor(amp: self.tracker.amplitude)
                    self.playerSlider.value = Float(self.player!.currentTime)
                }
            }
            
            playerSlider.maximumValue = Float(player.duration)
            
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
        
        songArt.image = songProperties.artwork?.image(at: CGSize(width: 300, height: 300))
        songTitle.text = songProperties.title
        songArtist.text = songProperties.artist
    }
    
    override func viewDidLoad() {
        preparePlayer()
        player = AKPlayer()
        songArt.image = #imageLiteral(resourceName: "no_cover")
        prepareSlider()
        
    }
    
    func prepareSlider() {
        playerSlider.addTarget(self, action: #selector(self.handlePlayheadSliderTouchBegin), for: .touchDown)
        playerSlider.addTarget(self, action:    #selector(self.handlePlayheadSliderTouchEnd), for: .touchUpInside)
        playerSlider.addTarget(self, action: #selector(self.handlePlayheadSliderTouchEnd), for: .touchUpOutside)
        playerSlider.addTarget(self, action: #selector(self.handlePlayheadSliderValueChanged), for: .valueChanged)
    }
    @IBAction func handlePlayheadSliderTouchBegin(_ sender: UISlider) {
        player.pause()
    }
    @IBAction func handlePlayheadSliderValueChanged(_ sender: UISlider) {
        player.startTime = Double(sender.value)
    }
    @IBAction func handlePlayheadSliderTouchEnd(_ sender: UISlider) {
        player.resume()
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
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
        } else if player.isPlaying {
            player.pause()
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
    
    func changeColor(amp: Double) {
        delegate?.changeLampColor(newColor: delegate!.getCurrentColor(), brightness: amp)
    }
    
}

