//
//  AlarmViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 29/03/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController, AKPickerViewDataSource, AKPickerViewDelegate {

    @IBOutlet weak var hoursPicker: AKPickerView!
    @IBOutlet weak var minutesPicker: AKPickerView!
    
    
    let hours = ["00","01","02","03","04","05","06","07","08","09"] + Array(10...23).map({String($0)})
    let minutes = ["00","01","02","03","04","05","06","07","08","09"] + Array(10...59).map({String($0)})
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTimePickers()
        
    }
    
    @IBAction func turnOnAlarm(_ sender: Any) {
        
    }
    
    @IBAction func turnOffAlarm(_ sender: Any) {
        
    }
    
    func initTimePickers() {
        hoursPicker.delegate = self
        hoursPicker.dataSource = self
        
        minutesPicker.delegate = self
        minutesPicker.dataSource = self
        
        hoursPicker.font = UIFont(name: "HelveticaNeue-Light", size: 25)!
        hoursPicker.highlightedFont = UIFont(name: "HelveticaNeue", size: 30)!
        hoursPicker.highlightedTextColor = .white
        hoursPicker.pickerViewStyle = .wheel
        hoursPicker.maskDisabled = false
        hoursPicker.interitemSpacing = 20
        hoursPicker.selectItem(9, animated: true)
        hoursPicker.reloadData()
        
        minutesPicker.font = UIFont(name: "HelveticaNeue-Light", size: 25)!
        minutesPicker.highlightedFont = UIFont(name: "HelveticaNeue", size: 30)!
        minutesPicker.highlightedTextColor = .white
        minutesPicker.pickerViewStyle = .wheel
        minutesPicker.maskDisabled = false
        minutesPicker.interitemSpacing = 20
        minutesPicker.selectItem(40, animated: true)
        minutesPicker.reloadData()
    }
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        if pickerView.tag == 1 {
            return hours.count
        } else {
            return minutes.count
        }
    }

    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        if pickerView.tag == 1 {
            return hours[item]
        } else {
            return minutes[item]
        }
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
    
        if pickerView.tag == 1 {
            print("Hour picked: \(hours[item])")
        } else {
            print("Minute picked: \(minutes[item])")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // println("\(scrollView.contentOffset.x)")
    }
    
}
