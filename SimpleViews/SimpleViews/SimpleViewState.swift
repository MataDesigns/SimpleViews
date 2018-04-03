//
//  SimpleViewState.swift
//  SimpleViews
//
//  Created by Nicholas Mata on 8/7/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import Foundation

@objc public enum SimpleViewState: Int {
    case loading, empty, finished, failed
    
    static let all = [loading, empty, finished, failed]
}
