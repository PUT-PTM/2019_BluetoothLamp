//
//  ViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 22.03.2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit
import CoreBluetooth
import SPStorkController
import Cards
import Pastel
import WhatsNew
import NotchyAlert

class ViewController: UIViewController {

    @IBOutlet weak var informationAboutLamp: UILabel!

    @IBOutlet weak var turnOnOffButton: UIButton!
    @IBOutlet weak var changeBrightnessButton: UIButton!
    @IBOutlet weak var showPaletteButton: UIButton!
    
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
    lazy var starBG = StarsOverlay(frame: view.bounds)
    var musicController: MusicViewController!
    var colorPickerController: ColorPickerViewController!
    var brightnessController: BrightnessViewController!
    var settingsController: SettingsViewController!
    
    var manager: CBCentralManager!
    var myBluetoothPeripheral: CBPeripheral!
    var myCharacteristic: CBCharacteristic!
    var isMyPeripheralConected = false
    
    var isBulbTurnedOn = false
    var currentColor = UIColor(red: 48/255, green: 62/255, blue: 103/255, alpha: 1)
    var isAlarmSet = false
    var isMusicModeSet = false
    var currentTheme = 1 // 1-gradientBG, 2-starBG

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    @objc func willEnterForeground() {
        if currentTheme == 1 {
            pastelView.removeFromSuperview()
            initGradientBackground()
        }
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
        
        pastelView.setColors([currentColor, .black])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
    
    func initButtons() {

        turnOnOffButton.addBlurEffect()
        turnOnOffButton.layer.borderWidth = 1
        turnOnOffButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        showPaletteButton.addBlurEffect()
        showPaletteButton.layer.borderWidth = 1
        showPaletteButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        changeBrightnessButton.addBlurEffect()
        changeBrightnessButton.layer.borderWidth = 1
        changeBrightnessButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
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
        writeValue(value: "3-099-999-99999")
        pastelView.setColors([.black, .green])
    }
    @objc func bookModeButtonPressed(sender: UIGestureRecognizer) {
        print("Book mode tapped")
        writeValue(value: "3-199-999-99999")
        pastelView.setColors([.black, .yellow])
    }
    @objc func relaxModeButtonPressed(sender: UIGestureRecognizer) {
        print("Relax mode tapped")
        writeValue(value: "3-299-999-99999")
        pastelView.setPastelGradient(.trueSunset)
    }
    @objc func rainbowModeButtonPressed(sender: UIGestureRecognizer) {
        print("Rainbow mode tapped")
        writeValue(value: "3-399-999-99999")
        pastelView.setColors([.black, .orange])
    }
    @objc func fireModeButtonPressed(sender: UIGestureRecognizer) {
        print("Fire mode tapped")
        writeValue(value: "3-499-999-99999")
        pastelView.setPastelGradient(.youngPassion)
    }
    @objc func oceanModeButtonPressed(sender: UIGestureRecognizer) {
        print("Ocean mode tapped")
        writeValue(value: "3-599-999-99999")
        pastelView.setPastelGradient(.morpheusDen)
    }
        
    @IBAction func showAlarmViewController(_ sender: Any) {
        
        //TODO when sb click continue show prop viewController
        
    }
    
    @IBAction func showMusicViewController(_ sender: Any) {
        
        if isBulbTurnedOn {
            if musicController == nil {
                let storyboard = UIStoryboard(name: "MusicPlayer", bundle: nil)
                musicController = storyboard.instantiateViewController(withIdentifier: "MusicViewController") as? MusicViewController
            }
            let transitionDelegate = SPStorkTransitioningDelegate()
            musicController.transitioningDelegate = transitionDelegate
            musicController.modalPresentationStyle = .custom
            musicController.modalPresentationCapturesStatusBarAppearance = true
            musicController.delegate = self
            
            self.present(musicController, animated: true, completion: nil)
            
        } else {
            let notchy = NotchyAlert(title: "You are not connected", description: nil, image: nil)
            notchy.presentNotchy(in: self.view, duration: 3)
        }
        
        print("Music Mode button pressed.")
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

    
    @IBAction func turnOnOff(_ sender: Any) {
        
        UIView.animate(withDuration: 0.1, animations: { self.turnOnOffButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)}, completion: { _ in UIView.animate(withDuration: 0.1) { self.turnOnOffButton.transform = CGAffineTransform.identity }})
        
        if isBulbTurnedOn {
            print("Lamp is turned off")
            writeValue(value: "0-999-999-99999")
            turnOnOffButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            isBulbTurnedOn = false
        } else if isMyPeripheralConected {
            print("Lamp is turned on")
            writeValue(value: "1-999-999-99999")
            turnOnOffButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            isBulbTurnedOn = true
        } else {
            let notchy = NotchyAlert(title: "You are not connected", description: nil, image: nil)
            notchy.presentNotchy(in: self.view, duration: 3)
         }
    }
    
    @IBAction func changeBrightness(_ sender: Any) {
        
        UIView.animate(withDuration: 0.1, animations: { self.changeBrightnessButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)}, completion: { _ in UIView.animate(withDuration: 0.1) { self.changeBrightnessButton.transform = CGAffineTransform.identity }})
        
        if isBulbTurnedOn {
            if brightnessController == nil {
                let storyboard = UIStoryboard(name: "Brightness", bundle: nil)
                brightnessController = storyboard.instantiateViewController(withIdentifier: "BrightnessViewController") as? BrightnessViewController
            }
            
            brightnessController.modalPresentationStyle = .overCurrentContext
            brightnessController.brightnessDelegate = self
            
            self.present(brightnessController, animated: true, completion: nil)
            
        } else {
            let notchy = NotchyAlert(title: "You are not connected", description: nil, image: nil)
            notchy.presentNotchy(in: self.view, duration: 3)
        }
        
        print("Brightness button pressed.")
    }
    
    @IBAction func openColorPalette(_ sender: Any) {
        
        if isBulbTurnedOn {
            if colorPickerController == nil {
                let storyboard = UIStoryboard(name: "ColorPicker", bundle: nil)
                colorPickerController = storyboard.instantiateViewController(withIdentifier: "ColorPickerViewController") as? ColorPickerViewController
            }
            
            let transitionDelegate = SPStorkTransitioningDelegate()
            colorPickerController.transitioningDelegate = transitionDelegate
            colorPickerController.modalPresentationStyle = .custom
            colorPickerController.modalPresentationCapturesStatusBarAppearance = true
            colorPickerController.colorDelegate = self
            transitionDelegate.swipeToDismissEnabled = false
            transitionDelegate.customHeight = 530
            
            self.present(colorPickerController, animated: true, completion: nil)
            
        } else {
            let notchy = NotchyAlert(title: "You are not connected", description: nil, image: nil)
            notchy.presentNotchy(in: self.view, duration: 3)
        }
    }
    
    @IBAction func showSettingsViewController(_ sender: Any) {
        if settingsController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            settingsController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
        }
        
        let transitionDelegate = SPStorkTransitioningDelegate()
        settingsController.transitioningDelegate = transitionDelegate
        settingsController.modalPresentationStyle = .custom
        settingsController.themesDelegate = self
        transitionDelegate.customHeight = 430
        
        self.present(settingsController, animated: true, completion: nil)
    }
    
}

extension ViewController: ColorDelegate {
    func changeLampColor(newColor: UIColor) {
        pastelView.setColors([newColor, .black])
        starBG.setup(color: newColor)
        currentColor = newColor
        
        let red = String(format: "%03d", Int(newColor.colorComponents!.red*255))
        let green = String(format: "%03d", Int(newColor.colorComponents!.green*255))
        let blue = String(format: "%03d", Int(newColor.colorComponents!.blue*255))
        let RGB = "2-\(red)-\(green)-\(blue)99"
        
        writeValue(value: RGB)
        print(RGB)
    }
    
    func changeLampColor(newColor: UIColor, newBrightness: CGFloat) {
        pastelView.setColors([newColor, .black])
        currentColor = newColor

        let red = String(format: "%03d", Int(newColor.colorComponents!.red*CGFloat(newBrightness)*255))
        let green = String(format: "%03d", Int(newColor.colorComponents!.green*CGFloat(newBrightness)*255))
        let blue = String(format: "%03d", Int(newColor.colorComponents!.blue*CGFloat(newBrightness)*255))
        let RGB = "2-\(red)-\(green)-\(blue)99"
        
        writeValue(value: RGB)
        print(RGB)
    }
    
    func getCurrentColor() -> UIColor {
        return currentColor
    }
    
    func changeBrightness(newBrightness: Float) {
        print(newBrightness)
        
        let red = String(format: "%03d", Int(currentColor.colorComponents!.red*CGFloat(newBrightness)*255))
        let green = String(format: "%03d", Int(currentColor.colorComponents!.green*CGFloat(newBrightness)*255))
        let blue = String(format: "%03d", Int(currentColor.colorComponents!.blue*CGFloat(newBrightness)*255))
        let RGB = "2-\(red)-\(green)-\(blue)99"
        
        writeValue(value: RGB)
    }
}

extension ViewController: ThemesDelegate {
    func changeTheme(themeNumber: Int) {
        if themeNumber == 1 && currentTheme != 1 {
            currentTheme = 1
            starBG.removeFromSuperview()
            initGradientBackground()
            print("Changed theme to Gradient")
            
        } else if themeNumber == 2 && currentTheme != 2 {
            currentTheme = 2
            pastelView.removeFromSuperview()
            view.insertSubview(starBG, at: 0)
            print("Changed theme to Star")
        }
    }
}

extension ViewController: AlarmDelegate {
    func setAlarm(time: Int) {
        // set correct timing
        writeValue(value: String(time))
    }
}

protocol ColorDelegate: class {
    func changeLampColor(newColor: UIColor)
    func changeLampColor(newColor: UIColor, newBrightness: CGFloat)
    func getCurrentColor() -> UIColor
    func changeBrightness(newBrightness: Float)
}

protocol ThemesDelegate: class {
    func changeTheme(themeNumber: Int)
}

protocol AlarmDelegate: class {
    func setAlarm(time: Int)
}
