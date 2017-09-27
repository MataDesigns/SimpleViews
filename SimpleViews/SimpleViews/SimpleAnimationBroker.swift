//
//  SimpleAnimationBroker.swift
//  SimpleViews
//
//  Created by Nicholas Mata on 9/8/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import Foundation

public enum SimpleAnimationBrokerState {
    case initial, `in`, out, finished
}

enum SimpleAnimationBrokerError: Error {
    case invalidLength
}

public class SimpleAnimationBroker {
    
    var views: [UIView]
    var animations: [SimpleAnimation]
    var durations: [Double]
    public var state: SimpleAnimationBrokerState = .initial
    
    private func throwInvalidLength(_ expression: Bool) throws {
        if expression {
            throw SimpleAnimationBrokerError.invalidLength
        }
    }
    
    public init(forViews views: [UIView], withAnimations animations: [SimpleAnimation], forDurations durations: [Double]) throws {
        self.views = views
        self.animations = animations
        self.durations = durations
        
        try throwInvalidLength(views.count != animations.count)
        try throwInvalidLength(views.count != durations.count)
        
        views.forEach { (view) in
            view.alpha = 0.0
            view.isHidden = false
        }
    }
    
    public convenience init(forViews views: [UIView], withAnimations animations: [SimpleAnimation], forDuration duration: Double) throws {
        let durations = Array(repeating: duration, count: views.count)
        try self.init(forViews: views, withAnimations: animations, forDurations: durations)
    }
    
    public convenience init(forViews views: [UIView], withAnimations animation: SimpleAnimation, forDuration durations: [Double]) throws {
        let animations = Array(repeating: animation, count: views.count)
        try self.init(forViews: views, withAnimations: animations, forDurations: durations)
    }
    
    public convenience init(forViews views: [UIView], withAnimations animation: SimpleAnimation, forDuration duration: Double) {
        let animations = Array(repeating: animation, count: views.count)
        let durations = Array(repeating: duration, count: views.count)
        try! self.init(forViews: views, withAnimations: animations, forDurations: durations)
    }
    
    public convenience init(forView view: UIView, withAnimation animation: SimpleAnimation, forDuration duration: Double) {
        try! self.init(forViews: [view], withAnimations: [animation], forDurations: [duration])
    }
    
    public func perform(animationState: SimpleAnimationState, completion: ((Bool) -> Void)? = nil) {
        if self.state == .finished ||
            (animationState == .in && self.state == .in) ||
            (animationState == .out && self.state == .out) {
            print("BROKER WARNING: Trying to perform already fired broker animation.")
            return
        }
        for (i, view) in views.enumerated() {
            view.perform(animation: animations[i], forDuration: durations[i], withState: animationState, completion: completion)
        }
        
        if animationState == .in && state == .out {
            self.state = .finished
        } else if animationState == .out && state == .in {
            self.state = .finished
        } else {
            self.state = animationState == .in ? .in : .out
        }
    }
    
    public func performIn(completion: ((Bool) -> Void)? = nil) {
        perform(animationState: .in, completion: completion)
    }
    
    public func performOut(completion: ((Bool) -> Void)? = nil) {
        perform(animationState: .out, completion: completion)
    }
    
}
