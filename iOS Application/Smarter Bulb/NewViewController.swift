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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.contents = #imageLiteral(resourceName: "powder").cgImage
        
        manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        initUI()
    }
    
    func initUI() {
        initButtons()
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
        
        alarmButton.layer.borderWidth = 1
        alarmButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        musicButton.layer.borderWidth = 1
        musicButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
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
    
    @IBAction func turnOnOffAlarm(_ sender: Any) {
        print("Alarm button pressed.")
        
        if isAlarmSet {
            isAlarmSet = false
            alarmButton.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.08235294118, blue: 0.09019607843, alpha: 1)
        } else {
            isAlarmSet = true
            alarmButton.backgroundColor = #colorLiteral(red: 0.231372549, green: 0.231372549, blue: 0.231372549, alpha: 1)
        }
    }
    
    @IBAction func turnOnOffMusicMode(_ sender: Any) {
        print("Music Mode button pressed.")
        
        if isMusicModeSet {
            isMusicModeSet = false
            musicButton.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.08235294118, blue: 0.09019607843, alpha: 1)
        } else {
            isMusicModeSet = true
            musicButton.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.231372549, blue: 0.2352941176, alpha: 1)
        }
    }
    
}

extension NewViewController: PopupDelegate {
    func pickedColor(newColor: UIColor) {
        //setBackgroundColor(color: newColor)
    }
}

extension NewViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
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
