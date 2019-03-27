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

class MusicViewController: ViewController {
    
    override func viewDidLoad() {
        
        let file = try! AKAudioFile(readFileName: "1.mp3")
        
        var player = AKPlayer(audioFile: file)
        player.isLooping = true
        player.buffering = .always
        
        let tracker = AKFrequencyTracker(player)
        
        AudioKit.output = tracker
        
        try! AudioKit.start()
        player.play()
        
        AKPlaygroundLoop(every: 0.1) {
            print(tracker.frequency)
            self.changeColor(freq: tracker.frequency, amp: tracker.amplitude)
        }
    }
    
    func convBrightness(value: Double) -> Double {
        var brightness = value/2
        if brightness < 0.2 {
            brightness = 0
        } else if brightness > 1 {
            brightness = 1
        }
        return brightness
    }
    
    func changeColor(freq: Double, amp: Double) {
        
        var brightness = convBrightness(value: amp)
        
        if(freq < 40) {
            setColor(r: 255, g: 0, b: 0, brightness: brightness)
        }
        else if(freq >= 40 && freq <= 77) {
            let temp = Int((freq-40) * 255/37.0)
            setColor(r: 255, g: 0, b: temp, brightness: brightness)
        }
        else if(freq > 77 && freq <= 205) {
            let temp = Int(255 - (freq - 78) * 2)
            setColor(r: temp, g: 0, b: 255, brightness: brightness)
        }
        else if(freq >= 206 && freq <= 238) {
            let temp = Int((freq - 206) * 255/32.0)
            setColor(r: 0, g: temp, b: 255, brightness: brightness)
        }
        else if(freq >= 239 && freq <= 250) {
            let temp = Int((freq-239) * 255/11.0)
            setColor(r: temp, g: 255, b: 255, brightness: brightness)
        }
        else if(freq >= 251 && freq <= 270) {
            setColor(r: 255, g: 255, b: 255, brightness: brightness)
        }
        else if(freq >= 271 && freq <= 398) {
            let temp = Int(255-(freq-271)*2)
            setColor(r: temp, g: 255, b: temp, brightness: brightness)
        }
        else if(freq >= 399 && freq <= 653) {
            setColor(r: 0, g: Int(255-(freq-399)), b: Int(freq-399), brightness: brightness)
        }
        else {
            setColor(r: 255, g: 0, b: 0, brightness: brightness)
        }
    }
    func setColor(r: Int, g: Int, b: Int, brightness: Double){
        view.backgroundColor = UIColor(red: CGFloat(r*brightness/255.0), green: CGFloat(g*brightness/255.0), blue: CGFloat(b*brightness/255.0), alpha: 1.0)
    }
}

