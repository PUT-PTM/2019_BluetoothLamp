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
    
    var player: AKPlayer!
    var tracker: AKFrequencyTracker!
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for thisItem in mediaItemCollection.items {
            let itemUrl = thisItem.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL
            let file = try! AKAudioFile(forReading: itemUrl! as URL)
            
            player = AKPlayer(audioFile: file)
            player.buffering = .always
            tracker = AKFrequencyTracker(player)
            AudioKit.output = tracker
            
            
            try! AudioKit.start()
            player.play()
            
            AKPlaygroundLoop(every: 0.1) {
                print(self.tracker.amplitude)
                self.changeColor(freq: self.tracker.frequency, amp: self.tracker.amplitude)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        AKSettings.playbackWhileMuted = true
        
    }
    
    @IBAction func play(_ sender: Any) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: {})
    }
    
    @IBAction func pause(_ sender: Any) {
        player.stop()
        try! AudioKit.stop()
    }
    
    func changeColor(freq: Double, amp: Double) {
        setColor(r: 255, g: 0, b: 0, brightness: amp)
    }
    
    func setColor(r: Int, g: Int, b: Int, brightness: Double){
        view.backgroundColor = UIColor(red: CGFloat(r*brightness/255.0), green: CGFloat(g*brightness/255.0), blue: CGFloat(b*brightness/255.0), alpha: 1.0)
    }
}

