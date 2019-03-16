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

class ViewController: UIViewController {
    
    @IBOutlet weak var wave: UIView!
    @IBOutlet weak var smartBulbLabel: UILabel!
    @IBOutlet weak var informationAboutLamp: UILabel!
    @IBOutlet weak var changeMode1: HapticButton!
    @IBOutlet weak var changeMode2: HapticButton!
    @IBOutlet weak var changeMode3: HapticButton!
    @IBOutlet weak var quickChoice1: HapticButton!
    @IBOutlet weak var quickChoice2: HapticButton!
    @IBOutlet weak var quickChoice3: HapticButton!
    
    
    var manager: CBCentralManager!
    var myBluetoothPeripheral: CBPeripheral!
    var myCharacteristic: CBCharacteristic!
    var isMyPeripheralConected = false
    
    var backgroundGradient: GradientView!
    var isBulbTurnedOn = false
    var notchy: NotchyAlert!
    
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
        backgroundGradient = GradientView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        
        initUI()
    }
    
    func initUI() {
        wave.addSubview(waveView)
        
        initGradientBackground()
        initButtons()
    }
    
    func initGradientBackground() {
        setBackgroundColor(Color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        self.backgroundGradient.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundGradient, at: 0)
    }
    
    func initButtons() {
        
        changeMode1.mode = .image(image: #imageLiteral(resourceName: "bulb"))
        changeMode1.addBlurView(style: .extraLight)
        changeMode1.layer.borderWidth = 1
        changeMode1.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        changeMode1.onPressed = {
            if self.isBulbTurnedOn {
                print("Lamp is turned off")
                self.writeValue(value: "off")
                self.waveView.stopWave()
                self.setBackgroundColor(Color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                self.changeMode1.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                self.isBulbTurnedOn = false
            } else if self.isMyPeripheralConected {
                print("Lamp is turned on")
                self.writeValue(value: "on")
                self.waveView.startWave()
                self.setBackgroundColor(Color: #colorLiteral(red: 0.9450980392, green: 0.768627451, blue: 0.05882352941, alpha: 1))
                self.changeMode1.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                self.isBulbTurnedOn = true
            } else {
                self.notchy = NotchyAlert(title: "You are not connected", description: nil, image: nil)
                self.notchy.presentNotchy(in: self.view, duration: 3)
            }
        }
        
        changeMode2.mode = .image(image: #imageLiteral(resourceName: "palete"))
        changeMode2.addBlurView(style: .extraLight)
        changeMode2.layer.borderWidth = 1
        changeMode2.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        changeMode2.onPressed = {
            print("2 blur button pressed.")
            self.setBackgroundColor(Color: #colorLiteral(red: 0.7529411765, green: 0.2235294118, blue: 0.168627451, alpha: 1))
        }
        
        changeMode3.mode = .image(image: #imageLiteral(resourceName: "nature"))
        changeMode3.addBlurView(style: .extraLight)
        changeMode3.layer.borderWidth = 1
        changeMode3.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        changeMode3.onPressed = {
            print("3 blur button pressed.")
            self.setBackgroundColor(Color: #colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.4431372549, alpha: 1))
        }
        
        quickChoice1.mode = .label(text: "")
        quickChoice1.textLabel.attributedText = addIconWithTextToLabel(image: "alarm_clock_off", text: "   Alarm")
        quickChoice1.textLabel.textAlignment = .left
        quickChoice1.textLabel.textColor = .gray
        quickChoice1.layer.borderWidth = 1
        quickChoice1.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        quickChoice1.addBlurView(style: .regular)
        quickChoice1.onPressed = {
            print("1 choice button pressed.")
            self.setBackgroundColor(Color: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
            
            self.quickChoice1.backgroundColor = .red
            self.quickChoice1.textLabel.textColor = .white
            self.quickChoice1.textLabel.attributedText = self.addIconWithTextToLabel(image: "alarm_clock_on", text: "   Alarm")
            
        }
        quickChoice1.layer.cornerRadius = 20
        
        quickChoice2.mode = .label(text: "")
        quickChoice2.textLabel.attributedText = addIconWithTextToLabel(image: "alarm_clock_off", text: "   Option 2")
        quickChoice2.textLabel.textAlignment = .left
        quickChoice2.textLabel.textColor = .gray
        quickChoice2.layer.borderWidth = 1
        quickChoice2.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        quickChoice2.addBlurView(style: .regular)
        quickChoice2.onPressed = {
            print("2 choice button pressed.")
            self.setBackgroundColor(Color: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
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
            self.setBackgroundColor(Color: #colorLiteral(red: 0.09411764706, green: 0.1725490196, blue: 0.3803921569, alpha: 1))
        }
        quickChoice3.layer.cornerRadius = 20
    }
    
    func setBackgroundColor(Color: UIColor) {
        backgroundGradient.gradient = PercentageGradient(baseColor: Color, angle: .vertical, percentage: 0.2)
        
        if Color.isDarkColor {
            informationAboutLamp.textColor = .white
            smartBulbLabel.textColor = .lightGray
        } else {
            informationAboutLamp.textColor = .black
            smartBulbLabel.textColor = .darkGray
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
    
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModeCollectionViewCell", for: indexPath) as! ModeCollectionViewCell
        
        cell.button.mode = .image(image: #imageLiteral(resourceName: "bulb"))
        cell.button.textLabel.textColor = .white
        cell.button.addBlurView(style: .extraLight)
        cell.button.layer.borderWidth = 1
        cell.button.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        cell.button.onPressed = {
            print("1 blur button pressed.")
            self.setBackgroundColor(Color: #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1))
        }
        return cell
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

