//
//  SettingsViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 29/03/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    weak var themesDelegate: ThemesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func changeToGradientTheme(_ sender: Any) {
        themesDelegate?.changeTheme(themeNumber: 1)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeToStarsTheme(_ sender: Any) {
        themesDelegate?.changeTheme(themeNumber: 2)
        dismiss(animated: true, completion: nil)
    }
    
}
