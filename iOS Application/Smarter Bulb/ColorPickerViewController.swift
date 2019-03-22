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
import HapticButton
import FaveButton

class ColorPickerViewController: UIViewController, FaveButtonDelegate {

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
        
        let colorPickerLabel = UILabel(frame: CGRect(x: 38, y: 54, width: 299, height: 52))
        colorPickerLabel.textAlignment = .left
        colorPickerLabel.text = "Color Picker"
        colorPickerLabel.font = UIFont(name: "AvenirNext-Medium", size: 38)
        self.view.addSubview(colorPickerLabel)
        
        let selectColorLabel = UILabel(frame: CGRect(x: 38, y: 99, width: 299, height: 35))
        selectColorLabel.textAlignment = .left
        selectColorLabel.text = "Select a color"
        selectColorLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.view.addSubview(selectColorLabel)
        
        colorPicker = CULColorPickerView(frame: CGRect(x:38, y:144, width: 300, height: 300))
        self.view.addSubview(colorPicker)
        colorPicker.delegate = self
        
        hexValue = UILabel(frame: CGRect(x: 38, y: 457, width: 92, height: 28))
        hexValue.textAlignment = .center
        hexValue.text = "#FFFFFF"
        hexValue.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.view.addSubview(hexValue)
        
        let faveButton = FaveButton(
            frame: CGRect(x:270, y:447, width: 44, height: 44),
            faveIconNormal: UIImage(named: "heart")
        )
        faveButton.delegate = self
        view.addSubview(faveButton)
        
        
        circleColorPalette = ColorPickerView(frame: CGRect(x:38, y:520, width: 300, height: 195))
        circleColorPalette.colors = [UIColor(hexString: "#c0392b"), UIColor(hexString: "#f1c40f"), UIColor(hexString: "#3498db"), UIColor(hexString: "#9b59b6"), UIColor(hexString: "#3dc1d3"), UIColor(hexString: "#e84118"), UIColor(hexString: "#4cd137")] as! [UIColor]
        self.view.addSubview(circleColorPalette)
        circleColorPalette.layoutDelegate = self
        circleColorPalette.delegate = self
    }
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        
    }
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        return nil
    }
}

extension ColorPickerViewController: CULColorPickerViewDelegate {
    func colorPickerWillBeginDragging(_ colorPicker: CULColorPickerView) { }
    func colorPickerDidSelectColor(_ colorPicker: CULColorPickerView) { }
    func colorPickerDidEndDagging(_ colorPicker: CULColorPickerView) {
        delegate?.pickedColor(newColor: colorPicker.selectedColor)
        hexValue.text = colorPicker.selectedColor.toHexString().uppercased()
    }
}

extension ColorPickerViewController: ColorPickerViewDelegateFlowLayout, ColorPickerViewDelegate {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        let currentColor = colorPickerView.colors[indexPath.item]
        hexValue.text = currentColor.toHexString().uppercased()
        colorPicker.updateSelectedColor(currentColor)
        delegate?.pickedColor(newColor: currentColor)
    }
    
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
    
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        let red, green, blue, alpha: CGFloat
        switch chars.count {
        case 3:
            chars = chars.flatMap { [$0, $0] }
            fallthrough
        case 6:
            chars = ["F","F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            return nil
        }
        self.init(red: red, green: green, blue:  blue, alpha: alpha)
    }
}

protocol PopupDelegate: class {
    func pickedColor(newColor: UIColor)
}
