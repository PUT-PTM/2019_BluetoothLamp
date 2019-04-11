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

    weak var delegate: ColorDelegate?
    
    @IBOutlet weak var colorPicker: CULColorPickerView!
    @IBOutlet weak var circleColorPalette: ColorPickerView!
    @IBOutlet weak var hexValue: UILabel!
    @IBOutlet weak var faveButton: FaveButton!
    
    var colorsArray = [UIColor(hexString: "#00deff"), UIColor(hexString: "#ff272b"), UIColor(hexString: "#0e43ff"), UIColor(hexString: "#14ff50"), UIColor(hexString: "#ffc0a7"), UIColor(hexString: "#ff7d1d"), UIColor(hexString: "#ff1439"), UIColor(hexString: "#ffffff")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colorPicker.delegate = self
        faveButton.delegate = self

        circleColorPalette.colors = colorsArray as! [UIColor]
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
        circleColorPalette = ColorPickerView(frame: CGRect(x:37, y:396, width: 300, height: 71))
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
        delegate?.changeLampColor(newColor: colorPicker.selectedColor)
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
        delegate?.changeLampColor(newColor: currentColor)
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
