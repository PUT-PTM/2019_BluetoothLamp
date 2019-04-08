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
    
    @IBOutlet weak var songArt: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var player: AKPlayer!
    var tracker: AKFrequencyTracker!
    var songProperties: MPMediaItem!
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for thisItem in mediaItemCollection.items {
            let itemUrl = thisItem.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL
            let file = try! AKAudioFile(forReading: itemUrl! as URL)
            
            songProperties = thisItem
            
            player = AKPlayer(audioFile: file)
            player.buffering = .always
            tracker = AKFrequencyTracker(player)
            AudioKit.output = tracker
            
            try! AudioKit.start()
            player.play()
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            becomeFirstResponder()
            
            updateNowPlayingCenter()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            AKPlaygroundLoop(every: 0.1) {
                if self.player.isPlaying {
                    print(self.tracker.amplitude)
                    //self.changeColor(amp: self.tracker.amplitude)
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
        
        songArt.image = songProperties.artwork?.image(at: CGSize(width: 300, height: 300))
        songTitle.text = songProperties.title
        songArtist.text = songProperties.artist
    }
    
    override func viewDidLoad() {
        preparePlayer()
        player = AKPlayer()
    }
    
    func preparePlayer() {
        AKSettings.playbackWhileMuted = true
        AKSettings.disableAVAudioSessionCategoryManagement = true
        try! AKSettings.setSession(category: AKSettings.SessionCategory.playback)
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(playOrPause))
        
    }
    
    @IBAction func playOrPause(_ sender: UIButton) {

        if player.isPaused {
            try! AudioKit.start()
            player.resume()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
        } else if player.isPlaying {
            player.pause()
            try! AudioKit.stop()
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
        setColor(r: 255, g: 0, b: 0, brightness: amp)
    }
    
    func setColor(r: Int, g: Int, b: Int, brightness: Double){
        view.backgroundColor = UIColor(red: CGFloat(r*brightness/255.0), green: CGFloat(g*brightness/255.0), blue: CGFloat(b*brightness/255.0), alpha: 1.0)
    }
}

