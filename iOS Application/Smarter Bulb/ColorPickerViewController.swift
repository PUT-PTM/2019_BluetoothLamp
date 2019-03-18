//
//  ColorPickerViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 16.03.2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit
import CULColorPicker
import IGColorPicker

class ColorPickerViewController: UIViewController {
    
    weak var delegate: PopupDelegate?
    @IBOutlet weak var hexValue: UILabel!
    
    @IBOutlet weak var colorPicker: CULColorPickerView!
    @IBOutlet weak var circleColorPalette: CULColorPickerView!
    
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

extension ColorPickerViewController: CULColorPickerViewDelegate {
    func colorPickerWillBeginDragging(_ colorPicker: CULColorPickerView) { }
    func colorPickerDidSelectColor(_ colorPicker: CULColorPickerView) { }
    func colorPickerDidEndDagging(_ colorPicker: CULColorPickerView) {
        hexValue.text = colorPicker.selectedColor.toHexString().uppercased()
    }
}

extension ColorPickerViewController: ColorPickerViewDelegateFlowLayout {
    
    
    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}

protocol PopupDelegate: class {
    func pickedColor(newColor: UIColor)
}
