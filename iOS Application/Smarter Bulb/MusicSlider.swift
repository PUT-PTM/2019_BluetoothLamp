//
//  MusicSlider.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 11/05/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit

open class MusicSlider: UISlider {
    @IBInspectable open var trackWidth:CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
}
