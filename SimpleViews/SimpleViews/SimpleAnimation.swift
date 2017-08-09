//
//  SimpleViewTransition.swift
//  SimpleViews
//
//  Created by Nicholas Mata on 8/7/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import UIKit

@objc public enum SimpleAnimation: Int {
    case none, fade, leftToRight, rightToLeft, slideUp, slideDown
}

public enum SimpleAnimationState {
    case `in`, out
}
