//
//  SettingsViewController.swift
//  Smarter Bulb
//
//  Created by Robert Moryson on 29/03/2019.
//  Copyright © 2019 Robert Moryson. All rights reserved.
//

import UIKit
import SPStorkController

class SPStorkSegue: UIStoryboardSegue {
    
    public var transitioningDelegate: SPStorkTransitioningDelegate?
    
    override func perform() {
        transitioningDelegate = transitioningDelegate ?? SPStorkTransitioningDelegate()
        destination.transitioningDelegate = transitioningDelegate
        destination.modalPresentationStyle = .custom
        super.perform()
    }
}
