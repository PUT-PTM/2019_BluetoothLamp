//
//  NewColorPickerViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 20.03.2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit
import CULColorPicker
import IGColorPicker

class NewColorPickerViewController: UIViewController {

    weak var delegate: PopupDelegate?
    var colorPicker: CULColorPickerView!
    var circleColorPalette: ColorPickerView!
    var hexValue: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = .white
        
        let colorPickerLabel = UILabel(frame: CGRect(x: 39, y: 54, width: 299, height: 52))
        colorPickerLabel.textAlignment = .left
        colorPickerLabel.text = "Color Picker"
        colorPickerLabel.font = UIFont(name: "AvenirNext-Medium", size: 38)
        self.view.addSubview(colorPickerLabel)
        
        let selectColorLabel = UILabel(frame: CGRect(x: 39, y: 99, width: 299, height: 35))
        selectColorLabel.textAlignment = .left
        selectColorLabel.text = "Select a color"
        selectColorLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.view.addSubview(selectColorLabel)
        
        colorPicker = CULColorPickerView(frame: CGRect(x:38, y:144, width: 300, height: 300))
        self.view.addSubview(colorPicker)
        colorPicker.delegate = self
        
        hexValue = UILabel(frame: CGRect(x: 39, y: 457, width: 92, height: 28))
        hexValue.textAlignment = .center
        hexValue.text = "#FFFFFF"
        hexValue.font = UIFont.systemFont(ofSize: 17)
        self.view.addSubview(hexValue)
        
        let button = UIButton(frame: CGRect(x: 209, y: 457, width: 92, height: 28))
        button.backgroundColor = .green
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        
        circleColorPalette = ColorPickerView(frame: CGRect(x:38, y:520, width: 300, height: 195))
        self.view.addSubview(circleColorPalette)
        circleColorPalette.layoutDelegate = self
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
}

extension NewColorPickerViewController: CULColorPickerViewDelegate {
    func colorPickerWillBeginDragging(_ colorPicker: CULColorPickerView) { }
    func colorPickerDidSelectColor(_ colorPicker: CULColorPickerView) { }
    func colorPickerDidEndDagging(_ colorPicker: CULColorPickerView) {
        delegate?.pickedColor(newColor: colorPicker.selectedColor)
        hexValue.text = colorPicker.selectedColor.toHexString().uppercased()
    }
}

extension NewColorPickerViewController: ColorPickerViewDelegateFlowLayout {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
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
