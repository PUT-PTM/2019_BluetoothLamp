//
//  BrightnessViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 12/04/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit
import TactileSlider

class BrightnessViewController: UIViewController {

    @IBOutlet weak var brightnessSlider: TactileSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.insertSubview(blurEffectView, at: 0)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
        
        brightnessSlider.trackBackground = UIColor.gray.withAlphaComponent(0.4)
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}
