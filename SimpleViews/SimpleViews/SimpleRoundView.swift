//
//  SimpleRoundView.swift
//  SimpleViews
//
//  Created by Nicholas Mata on 7/29/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import UIKit

@IBDesignable
public class SimpleRoundView: UIView {

    @IBInspectable public var cornerRadius : CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
}
