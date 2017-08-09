//
//  SimpleViewTransition.swift
//  SimpleViews
//
//  Created by Nicholas Mata on 8/7/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import UIKit

@objc public enum SimpleTransition: Int {
    case none, fade, leftToRight, rightToLeft, slideUp, slideDown
}

public enum SimpleTransitionState {
    case `in`, out
}
