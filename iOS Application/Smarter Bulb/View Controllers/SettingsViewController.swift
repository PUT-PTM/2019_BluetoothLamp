//
//  SettingsViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 29/03/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var themePicker: UIPickerView!
    
    weak var themesDelegate: ThemesDelegate?
    let themes = ["Gradient", "Stars"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.themePicker.delegate = self
        self.themePicker.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themes.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        return NSAttributedString(string: themes[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let themeNumber = themePicker.selectedRow(inComponent: 0) + 1
        themesDelegate?.changeTheme(themeNumber: themeNumber)
    }
}
