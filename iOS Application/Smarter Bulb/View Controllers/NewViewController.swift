//
//  NewViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 22.03.2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit
import HapticButton
import CoreBluetooth
import SPStorkController
import Cards
import Pastel

class NewViewController: UIViewController {

    @IBOutlet weak var informationAboutLamp: UILabel!
    @IBOutlet weak var turnOnOffButton: HapticButton!
    @IBOutlet weak var showPaletteButton: HapticButton!
    @IBOutlet weak var changeBrightnessButton: HapticButton!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    
    @IBOutlet weak var natureMode: CardHighlight!
    
    var manager: CBCentralManager!
    var myBluetoothPeripheral: CBPeripheral!
    var myCharacteristic: CBCharacteristic!
    var isMyPeripheralConected = false
    
    var isBulbTurnedOn = false
    var currentColor: UIColor!
    var isAlarmSet = false
    var isMusicModeSet = false
    
    lazy var pastelView = PastelView(frame: view.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.layer.contents = #imageLiteral(resourceName: "powder").cgImage
        
        manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        initUI()
    }
    
    func initUI() {
        initButtons()
        initGradientBackground()
    }
    
    func initGradientBackground() {
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 2.5
        
        // Custom Color
        pastelView.setPastelGradient(.trueSunset)
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
    
    func initButtons() {
        
        turnOnOffButton.mode = .image(image: #imageLiteral(resourceName: "bulb_white"))
        turnOnOffButton.addBlurView(style: .dark)
        turnOnOffButton.layer.borderWidth = 1
        turnOnOffButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        showPaletteButton.mode = .image(image: #imageLiteral(resourceName: "palette_white"))
        showPaletteButton.addBlurView(style: .dark)
        showPaletteButton.layer.borderWidth = 1
        showPaletteButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        changeBrightnessButton.mode = .image(image: #imageLiteral(resourceName: "sun_white"))
        changeBrightnessButton.addBlurView(style: .dark)
        changeBrightnessButton.layer.borderWidth = 1
        changeBrightnessButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        
        let tapGestureAlarm = UITapGestureRecognizer(target: self, action: #selector(normalTapAlarmOnOff(_:)))
        tapGestureAlarm.numberOfTapsRequired = 1
        alarmButton.addGestureRecognizer(tapGestureAlarm)
        
        let tapGestureMusic = UITapGestureRecognizer(target: self, action: #selector(normalTapMusicOnOff(_:)))
        tapGestureMusic.numberOfTapsRequired = 1
        musicButton.addGestureRecognizer(tapGestureMusic)
        
        let longGestureAlarm = UILongPressGestureRecognizer(target: self, action: #selector(longTapAlarmSettings(_:)))
        alarmButton.addGestureRecognizer(longGestureAlarm)
        
        let longGestureMusic = UILongPressGestureRecognizer(target: self, action: #selector(longTapMusicSettings(_:)))
        musicButton.addGestureRecognizer(longGestureMusic)
        
        alarmButton.layer.borderWidth = 1
        alarmButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        musicButton.layer.borderWidth = 1
        musicButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
    }
    
    @objc func normalTapAlarmOnOff(_ sender: UIGestureRecognizer){
        print("Normal tap")
        print("Alarm button pressed.")
        
        if isAlarmSet {
            isAlarmSet = false
            alarmButton.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.08235294118, blue: 0.09019607843, alpha: 0.7)
        } else {
            isAlarmSet = true
            alarmButton.backgroundColor = #colorLiteral(red: 0.231372549, green: 0.231372549, blue: 0.231372549, alpha: 0.7)
        }
    }
    
    @objc func longTapAlarmSettings(_ sender: UIGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
    }
    
    @objc func normalTapMusicOnOff(_ sender: UIGestureRecognizer){
        print("Normal tap")
        print("Music Mode button pressed.")
        
        if isMusicModeSet {
            isMusicModeSet = false
            musicButton.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.08235294118, blue: 0.09019607843, alpha: 0.7)
        } else {
            isMusicModeSet = true
            musicButton.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.231372549, blue: 0.2352941176, alpha: 0.7)
        }
    }
    
    @objc func longTapMusicSettings(_ sender: UIGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
            let controller = MusicViewController()
            let transitionDelegate = SPStorkTransitioningDelegate()
            controller.transitioningDelegate = transitionDelegate
            controller.modalPresentationStyle = .custom
            controller.modalPresentationCapturesStatusBarAppearance = true
            //controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func turnOnOff(_ sender: Any) {
        if isBulbTurnedOn {
            print("Lamp is turned off")
            writeValue(value: "off")
            turnOnOffButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            isBulbTurnedOn = false
        } else {
            print("Lamp is turned on")
            writeValue(value: "on")
            turnOnOffButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            isBulbTurnedOn = true
        }
        
        /*else {
         notchy = NotchyAlert(title: "You are not connected", description: nil, image: nil)
         notchy.presentNotchy(in: self.view, duration: 3)
         } */
    }
    
    @IBAction func changeBrightness(_ sender: Any) {
        print("Brightness button pressed.")
    }
    
    @IBAction func openColorPalette(_ sender: Any) {
        let controller = ColorPickerViewController()
        let transitionDelegate = SPStorkTransitioningDelegate()
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
}

extension NewViewController: PopupDelegate {
    func pickedColor(newColor: UIColor) {
        pastelView.setColors([newColor.darker(by: 40)!, newColor, newColor.lighter(by: 40)!])
    }
}
