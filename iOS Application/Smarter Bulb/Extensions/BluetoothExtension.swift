//
//  BluetoothExtension.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 27/03/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import Foundation
import CoreBluetooth

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
