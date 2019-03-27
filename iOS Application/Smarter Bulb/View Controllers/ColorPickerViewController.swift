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
    var faveButton: FaveButton!
    var colorsArray = [UIColor(hexString: "#00deff"), UIColor(hexString: "#ff272b"), UIColor(hexString: "#0e43ff"), UIColor(hexString: "#14ff50"), UIColor(hexString: "#ffc0a7"), UIColor(hexString: "#ff7d1d"), UIColor(hexString: "#ff1439"), UIColor(hexString: "#ffffff")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.2039215686, blue: 0.2117647059, alpha: 1)
        
        let colorPickerLabel = UILabel(frame: CGRect(x: 38, y: 54, width: 299, height: 52))
        colorPickerLabel.textAlignment = .left
        colorPickerLabel.text = "Color Picker"
        colorPickerLabel.textColor = .white
        colorPickerLabel.font = UIFont(name: "AvenirNext-Medium", size: 38)
        self.view.addSubview(colorPickerLabel)
        
        let selectColorLabel = UILabel(frame: CGRect(x: 38, y: 99, width: 299, height: 35))
        selectColorLabel.textAlignment = .left
        selectColorLabel.text = "Select a color"
        selectColorLabel.textColor = .white
        selectColorLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.view.addSubview(selectColorLabel)
        
        colorPicker = CULColorPickerView(frame: CGRect(x:38, y:144, width: 300, height: 300))
        self.view.addSubview(colorPicker)
        colorPicker.delegate = self
        
        hexValue = UILabel(frame: CGRect(x: 38, y: 457, width: 92, height: 28))
        hexValue.textAlignment = .center
        hexValue.textColor = .white
        hexValue.text = "#FFFFFF"
        hexValue.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.view.addSubview(hexValue)
        
        faveButton = FaveButton(
            frame: CGRect(x:300, y:447, width: 44, height: 44),
            faveIconNormal: UIImage(named: "heart")
        )
        faveButton.delegate = self
        view.addSubview(faveButton)
        
        
        circleColorPalette = ColorPickerView(frame: CGRect(x:38, y:520, width: 300, height: 195))
        circleColorPalette.colors = colorsArray as! [UIColor]
        circleColorPalette.tag = 1
        view.addSubview(circleColorPalette)
        
        circleColorPalette.layoutDelegate = self
        circleColorPalette.delegate = self
        
    }
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        
        if faveButton.isSelected, !colorsArray.contains(UIColor(hexString: hexValue.text!)){
            colorsArray.append(UIColor(hexString: hexValue.text!))
        } else {
            colorsArray.remove(object: UIColor(hexString: hexValue.text!))
        }
        
        if let viewWithTag = self.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
            print("Deleted colorPicker subview")
        } else {
            print("Error while deleting colorPicker subview")
        }
        
        var circleColorPalette: ColorPickerView!
        circleColorPalette = ColorPickerView(frame: CGRect(x:38, y:520, width: 300, height: 195))
        circleColorPalette.tag = 1
        
        circleColorPalette.colors = colorsArray as! [UIColor]
        view.addSubview(circleColorPalette)
        circleColorPalette.layoutDelegate = self
        circleColorPalette.delegate = self
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
        if colorsArray.contains(UIColor(hexString: hexValue.text!)) {
            faveButton.setSelected(selected: true, animated: false)
        } else {
            faveButton.setSelected(selected: false, animated: false)
        }
    }
}

extension ColorPickerViewController: ColorPickerViewDelegateFlowLayout, ColorPickerViewDelegate {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        let currentColor = colorPickerView.colors[indexPath.item]
        hexValue.text = currentColor.toHexString().uppercased()
        colorPicker.updateSelectedColor(currentColor)
        delegate?.pickedColor(newColor: currentColor)
        if colorsArray.contains(UIColor(hexString: hexValue.text!)) {
            faveButton.setSelected(selected: true, animated: false)
        } else {
            faveButton.setSelected(selected: false, animated: false)
        }
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

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = index(of: object) else {return}
        remove(at: index)
    }
}

protocol PopupDelegate: class {
    func pickedColor(newColor: UIColor)
}