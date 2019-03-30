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
import WhatsNew

class NewViewController: UIViewController {

    @IBOutlet weak var informationAboutLamp: UILabel!
    
    @IBOutlet weak var turnOnOffButton: HapticButton!
    @IBOutlet weak var showPaletteButton: HapticButton!
    @IBOutlet weak var changeBrightnessButton: HapticButton!
    
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var natureMode: CardHighlight!
    @IBOutlet weak var bookMode: CardHighlight!
    @IBOutlet weak var relaxMode: CardHighlight!
    @IBOutlet weak var rainbowMode: CardHighlight!
    @IBOutlet weak var fireMode: CardHighlight!
    @IBOutlet weak var oceanMode: CardHighlight!
    
    lazy var pastelView = PastelView(frame: view.bounds)
    
    var manager: CBCentralManager!
    var myBluetoothPeripheral: CBPeripheral!
    var myCharacteristic: CBCharacteristic!
    var isMyPeripheralConected = false
    
    var isBulbTurnedOn = false
    var currentColor: UIColor!
    var isAlarmSet = false
    var isMusicModeSet = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.layer.contents = #imageLiteral(resourceName: "powder").cgImage
        
        manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        initUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        let transitionDelegate = SPStorkTransitioningDelegate()
        vc.transitioningDelegate = transitionDelegate
        vc.modalPresentationStyle = .custom
        vc.modalPresentationCapturesStatusBarAppearance = true
    }
    
    func initUI() {
        initButtons()
        initGradientBackground()
        initBgForModes()
    }
    
    func initBgForModes() {  
        let bgForModes = UIView(frame: CGRect(x: 16, y: 480, width: 344, height: 285))
        bgForModes.layer.cornerRadius = 30
        bgForModes.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.08235294118, blue: 0.09019607843, alpha: 0.7)
        view.insertSubview(bgForModes, at: 1)
    }
    
    func initGradientBackground() {
        
        pastelView.startPastelPoint = .topRight
        pastelView.endPastelPoint = .bottomLeft
        pastelView.animationDuration = 2.5
        
        pastelView.setColors([UIColor(red: 48/255, green: 62/255, blue: 103/255, alpha: 1), .black])
        
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
        
    
        let tapGestureMusic = UITapGestureRecognizer(target: self, action: #selector(normalTapMusicOnOff(_:)))
        tapGestureMusic.numberOfTapsRequired = 1
        musicButton.addGestureRecognizer(tapGestureMusic)
        
        let longGestureMusic = UILongPressGestureRecognizer(target: self, action: #selector(longTapMusicSettings(_:)))
        musicButton.addGestureRecognizer(longGestureMusic)
        
        alarmButton.layer.borderWidth = 1
        alarmButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        musicButton.layer.borderWidth = 1
        musicButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        let tapGestureNatureMode:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(natureModeButtonPressed))
        natureMode.addGestureRecognizer(tapGestureNatureMode)
        
        let tapGestureBookMode:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bookModeButtonPressed))
        bookMode.addGestureRecognizer(tapGestureBookMode)
        
        let tapGestureRelaxMode:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(relaxModeButtonPressed))
        relaxMode.addGestureRecognizer(tapGestureRelaxMode)
        
        let tapGestureRainbowMode:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rainbowModeButtonPressed))
        rainbowMode.addGestureRecognizer(tapGestureRainbowMode)
        
        let tapGestureFireMode:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fireModeButtonPressed))
        fireMode.addGestureRecognizer(tapGestureFireMode)
        
        let tapGestureOceanMode:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(oceanModeButtonPressed))
        oceanMode.addGestureRecognizer(tapGestureOceanMode)
        
    }
    
    @objc func natureModeButtonPressed(sender: UIGestureRecognizer) {
        print("Nature mode tapped")
        writeValue(value: "nature")
    }
    @objc func bookModeButtonPressed(sender: UIGestureRecognizer) {
        print("Book mode tapped")
        writeValue(value: "book")
    }
    @objc func relaxModeButtonPressed(sender: UIGestureRecognizer) {
        print("Relax mode tapped")
        writeValue(value: "relax")
    }
    @objc func rainbowModeButtonPressed(sender: UIGestureRecognizer) {
        print("Rainbow mode tapped")
        writeValue(value: "rainbow")
    }
    @objc func fireModeButtonPressed(sender: UIGestureRecognizer) {
        print("Fire mode tapped")
        writeValue(value: "fire")
    }
    @objc func oceanModeButtonPressed(sender: UIGestureRecognizer) {
        print("Ocean mode tapped")
        writeValue(value: "ocean")
    }
        
    @IBAction func alarmButtonPressed(_ sender: Any) {
        
        let welcomMusicScreen = WhatsNewViewController(items: [
            WhatsNewItem.image(title: "Nice Icons", subtitle: "Completely customize colors, texts and icons.", image: #imageLiteral(resourceName: "nature")),
            WhatsNewItem.image(title: "Such Easy", subtitle: "Setting this up only takes 2 lines of code, impressive you say?", image: #imageLiteral(resourceName: "fire")),
            WhatsNewItem.image(title: "Very Sleep", subtitle: "It helps you get more sleep by writing less code.", image: #imageLiteral(resourceName: "unicorn")),
            WhatsNewItem.text(title: "Text Only", subtitle: "No icons? Just go with plain text."),
            ])
        welcomMusicScreen.titleText = "Welcome in Alarm Mode!"
        welcomMusicScreen.presentationOption = .always
        welcomMusicScreen.presentIfNeeded(on: self)
        
        //TODO when sb click continue show prop viewController
        
    }
    
    //delete
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
        //pastelView.setColors([newColor.darker(by: 40)!, newColor, newColor.lighter(by: 40)!])
        pastelView.setColors([newColor, .black])
    }
}
