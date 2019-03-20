//
//  ColorPickerViewDelegate.swift
//  ColorPicker
//
//  Created by Matsuoka Yoshiteru on 2018/10/20.
//  Copyright © 2018年 culumn. All rights reserved.
//

import Foundation

public protocol CULColorPickerViewDelegate: class {
    func colorPickerWillBeginDragging(_ colorPicker: CULColorPickerView)
    func colorPickerDidSelectColor(_ colorPicker: CULColorPickerView)
    func colorPickerDidEndDagging(_ colorPicker: CULColorPickerView)
}