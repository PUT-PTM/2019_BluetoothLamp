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
        self.view.backgroundColor = #colorLiteral(red: 0.1082720235, green: 0.1083889827, blue: 0.1082901582, alpha: 1)
        
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

protocol PopupDelegate: class {
    func pickedColor(newColor: UIColor)
}
