//
//  ViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 06/03/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit
import CoreBluetooth
import HapticButton
import Slope
import NotchyAlert
import SPStorkController
import Cards

class ViewController: UIViewController {
    
    @IBOutlet weak var wave: UIView!
    @IBOutlet weak var smartBulbLabel: UILabel!
    @IBOutlet weak var informationAboutLamp: UILabel!
    @IBOutlet weak var turnOnOffButton: HapticButton!
    @IBOutlet weak var showPaletteButton: HapticButton!
    @IBOutlet weak var changeBrightnessButton: HapticButton!
    @IBOutlet weak var quickChoice1: HapticButton!
    @IBOutlet weak var quickChoice2: HapticButton!
    @IBOutlet weak var quickChoice3: HapticButton!
    
    @IBOutlet weak var natureMode: CardHighlight!
    
    var manager: CBCentralManager!
    var myBluetoothPeripheral: CBPeripheral!
    var myCharacteristic: CBCharacteristic!
    var isMyPeripheralConected = false
    
    var backgroundGradient: GradientView!
    var isBulbTurnedOn = false
    var notchy: NotchyAlert!
    var currentColor: UIColor!
    var isAlarmSet = false
    
    private lazy var waveView: LCWaveView = {
        let waveView = LCWaveView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200), color: .white)
        waveView.waveRate = 2
        waveView.waveSpeed = 1
        waveView.waveHeight = 7
        return waveView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        backgroundGradient = GradientView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180))
        
        initUI()
    }
    
    func initUI() {
        wave.addSubview(waveView)
        
        initGradientBackground()
        initButtons()
    }
    
    func initGradientBackground() {
        setBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        self.backgroundGradient.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundGradient, at: 0)
    }
    
    func initButtons() {
        
        turnOnOffButton.mode = .image(image: #imageLiteral(resourceName: "bulb"))
        turnOnOffButton.addBlurView(style: .extraLight)
        turnOnOffButton.layer.borderWidth = 1
        turnOnOffButton.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        showPaletteButton.mode = .image(image: #imageLiteral(resourceName: "palete"))
        showPaletteButton.addBlurView(style: .extraLight)
        showPaletteButton.layer.borderWidth = 1
        showPaletteButton.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        changeBrightnessButton.mode = .image(image: #imageLiteral(resourceName: "sun"))
        changeBrightnessButton.addBlurView(style: .extraLight)
        changeBrightnessButton.layer.borderWidth = 1
        changeBrightnessButton.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        quickChoice1.mode = .label(text: "")
        quickChoice1.textLabel.attributedText = addIconWithTextToLabel(image: "alarm_clock_off", text: "   Alarm")
        quickChoice1.textLabel.textAlignment = .left
        quickChoice1.textLabel.textColor = .gray
        quickChoice1.layer.borderWidth = 1
        quickChoice1.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        quickChoice1.addBlurView(style: .regular)
        quickChoice1.layer.cornerRadius = 20
        
        quickChoice2.mode = .label(text: "")
        quickChoice2.textLabel.attributedText = addIconWithTextToLabel(image: "alarm_clock_off", text: "   Music")
        quickChoice2.textLabel.textAlignment = .left
        quickChoice2.textLabel.textColor = .gray
        quickChoice2.layer.borderWidth = 1
        quickChoice2.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        quickChoice2.addBlurView(style: .regular)
        quickChoice2.onPressed = {
            print("2 choice button pressed.")
            self.setBackgroundColor(color: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
        }
        quickChoice2.layer.cornerRadius = 20
        
        quickChoice3.mode = .label(text: "")
        quickChoice3.textLabel.attributedText = addIconWithTextToLabel(image: "alarm_clock_off", text: "   Option 3")
        quickChoice3.textLabel.textAlignment = .left
        quickChoice3.textLabel.textColor = .gray
        quickChoice3.layer.borderWidth = 1
        quickChoice3.layer.borderColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        quickChoice3.addBlurView(style: .regular)
        quickChoice3.onPressed = {
            print("3 choice button pressed.")
            self.setBackgroundColor(color: #colorLiteral(red: 0.09411764706, green: 0.1725490196, blue: 0.3803921569, alpha: 1))
        }
        quickChoice3.layer.cornerRadius = 20
    }
    
    func setBackgroundColor(color: UIColor) {
        currentColor = color
        
        backgroundGradient.gradient = PercentageGradient(baseColor: color, angle: .vertical, percentage: 0.2)
        
        if color.isDarkColor {
            informationAboutLamp.textColor = .white
            smartBulbLabel.textColor = .lightGray
        } else {
            informationAboutLamp.textColor = .black
            smartBulbLabel.textColor = .darkGray
        }
        
        updateButtonsColor(newColor: color)
    }
    func updateButtonsColor(newColor: UIColor) {
        if isAlarmSet {
            if newColor != #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
                quickChoice1.backgroundColor = newColor
            } else {
                quickChoice1.backgroundColor = .lightGray
            }
            if currentColor.isDarkColor {
                quickChoice1.textLabel.textColor = .white
                quickChoice1.textLabel.attributedText = addIconWithTextToLabel(image: "alarm_clock_on", text: "   Alarm")
            } else {
                quickChoice1.textLabel.textColor = .darkGray
                quickChoice1.textLabel.attributedText = addIconWithTextToLabel(image: "alarm_clock_off", text: "   Alarm")
            }
        } else {
            quickChoice1.backgroundColor = .white
            quickChoice1.textLabel.textColor = .gray
            quickChoice1.textLabel.attributedText = addIconWithTextToLabel(image: "alarm_clock_off", text: "   Alarm")
        }
    }
    
    func addIconWithTextToLabel(image: String, text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: image)
        attachment.bounds = CGRect(x: 0, y: -5, width: 25, height: 25)
        let attachmentString = NSAttributedString(attachment: attachment)
        let myString = NSMutableAttributedString(string: "  ")
        myString.append(attachmentString)
        let textAfterIcon = NSMutableAttributedString(string: text)
        myString.append(textAfterIcon)
        
        return myString
    }
    
    @IBAction func changeMode1(_ sender: Any) {
        if isBulbTurnedOn {
            print("Lamp is turned off")
            writeValue(value: "off")
            waveView.stopWave()
            setBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            turnOnOffButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            isBulbTurnedOn = false
        } else {
            print("Lamp is turned on")
            writeValue(value: "on")
            waveView.startWave()
            setBackgroundColor(color: #colorLiteral(red: 0.9686274529, green: 0.8475579686, blue: 0.07893051368, alpha: 1))
            turnOnOffButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            isBulbTurnedOn = true
        }
        
        /*else {
            notchy = NotchyAlert(title: "You are not connected", description: nil, image: nil)
            notchy.presentNotchy(in: self.view, duration: 3)
        } */
    }
    
    @IBAction func changeMode2(_ sender: Any) {
        //let storyboard = UIStoryboard(name: "ColorPickerViewController", bundle: nil)
        //let vc = storyboard.instantiateViewController(withIdentifier: "ColorPickerViewController") as! ColorPickerViewController
        //vc.delegate = self
        //vc.modalPresentationStyle = .overCurrentContext
        //vc.modalTransitionStyle = .crossDissolve
        //present(vc, animated: true)
        
        let controller = ColorPickerViewController()
        let transitionDelegate = SPStorkTransitioningDelegate()
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func changeMode3(_ sender: Any) {
        print("3 blur button pressed.")
        setBackgroundColor(color: #colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.4431372549, alpha: 1))
    }
    
    @IBAction func quickChoice1(_ sender: Any) {
        print("Alarm choice button pressed.")
        
        if isAlarmSet {
            isAlarmSet = false
        } else {
            isAlarmSet = true
        }
        updateButtonsColor(newColor: currentColor)
        
    }
    

}


extension ViewController: PopupDelegate {
    func pickedColor(newColor: UIColor) {
        setBackgroundColor(color: newColor)
    }
}


extension ViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Bluetooth
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var msg: String
        
        switch central.state {
        case .poweredOff:
            msg = "Bluetooth is Off"
            informationAboutLamp.text = "Turn on bluetooth"
        case .poweredOn:
            msg = "Bluetooth is On"
            manager.scanForPeripherals(withServices: nil, options: nil)
            informationAboutLamp.text = "Looking for lamp"
        case .unsupported:
            msg = "Not Supported"
            informationAboutLamp.text = "Your device is not supported"
        default:
            msg = ""
        }
        
        print("STATE: " + msg)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "BT05" {
            //lblPeripheralName.isHidden = false
            //lblPeripheralName.text = peripheral.name ?? "Default"

            self.myBluetoothPeripheral = peripheral     //save peripheral
            self.myBluetoothPeripheral.delegate = self
            
            manager.stopScan()                          //stop scanning for peripherals
            
            manager.connect(myBluetoothPeripheral, options: nil) //connect to my peripheral
            informationAboutLamp.text = "Connected"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isMyPeripheralConected = true //when connected change to true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isMyPeripheralConected = false //and to false when disconnected
        if myBluetoothPeripheral != nil{
            if myBluetoothPeripheral.delegate != nil {
                myBluetoothPeripheral.delegate = nil
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripheral = peripheral.services as [CBService]! { //get the services of the perifereal
            for service in servicePeripheral {
                
                //Then look for the characteristics of the services
                print(service.uuid.uuidString)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characterArray = service.characteristics as [CBCharacteristic]! {
            for cc in characterArray {
                print(cc.uuid.uuidString)
                if(cc.uuid.uuidString == "FFE1") { //properties: read, write

                    myCharacteristic = cc //saved it to send data in another function.
                    
                    //peripheral.readValue(for: cc) //to read the value of the characteristic
                }
            }
        }
    }
    
    /*
     func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
     
        print(characteristic.uuid.uuidString)
        if (characteristic.uuid.uuidString == "FFE1") {
        let readValue = characteristic.value
        let value = (readValue! as NSData).bytes.bindMemory(to: Int.self, capacity: readValue!.count).pointee //used to read an Int value
        print (value)
        }
     }
     */
    
    func writeValue(value: String) {
        if isMyPeripheralConected { //check if myPeripheral is connected to send data
            let dataToSend: Data = value.data(using: String.Encoding.utf8)!
            myBluetoothPeripheral.writeValue(dataToSend, for: myCharacteristic, type: CBCharacteristicWriteType.withoutResponse)    //Writing the data to the peripheral
        } else {
            print("Not connected")
        }
    }
}

extension UIColor {
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50 ? true : false
    }
}

