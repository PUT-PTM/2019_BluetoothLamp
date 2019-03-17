//
//  ColorPickerViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 16.03.2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit
import CULColorPicker

class ColorPickerViewController: UIViewController {
    
    weak var delegate: PopupDelegate?
    
    @IBOutlet weak var colorPicker: ColorPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.delegate = self
    }
    
    @IBAction func onButtonTap()
    {
        delegate?.pickedColor(newColor: colorPicker.selectedColor)
        dismiss(animated: true, completion: nil)
    }
    
}

extension ColorPickerViewController: ColorPickerViewDelegate {
    func colorPickerWillBeginDragging(_ colorPicker: ColorPickerView) {
        
    }
    
    func colorPickerDidSelectColor(_ colorPicker: ColorPickerView) {
        
    }
    
    func colorPickerDidEndDagging(_ colorPicker: ColorPickerView) {
        
    }
    
    
}
protocol PopupDelegate: class {
    func pickedColor(newColor: UIColor)
}
