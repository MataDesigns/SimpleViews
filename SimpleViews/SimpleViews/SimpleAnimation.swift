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

extension UIView {
    /// Animates a view using center.
    ///
    /// - Parameters:
    ///   - view: The view you would like to animate.
    ///   - duration: The duration of the animation.
    ///   - fromCenter: The point you want to animate the view from.
    ///   - toCenter: The point you want to animate the view to
    ///   - options: Animation options like curveEaseIn
    ///   - isIn: Whether the animation is a in or out. Basically at end of animation should the view be hidden or displayed.
    public func animate(for duration: TimeInterval, fromCenter: CGPoint, toCenter: CGPoint, options: UIViewAnimationOptions, isIn: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        let originalCenter = self.center;
        self.center = fromCenter
        self.alpha = 1
        
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.center = toCenter
        }, completion: { (completed) in
            self.isHidden = !isIn
            self.center = originalCenter
            completion?(completed)
        })
    }
    
    /// Performs a SimpleAnimation on a view with state.
    ///
    /// - Parameters:
    ///   - animation: The SimpleAnimation that should be performed on this view.
    ///   - duration: The duration of the animation.
    ///   - state: The SimpleAnimationState of the SimpleAnimation either in or out.
    ///   - completion: A block called when animation is completed.
    public func perform(animation: SimpleAnimation, forDuration duration: Double = 0.7, withState state: SimpleAnimationState, completion: ((Bool) -> Swift.Void)? = nil) {
        
        // Since we are animating this view make sure it
        // is NOT hidden, or user won't be able to view animation.
        self.isHidden = false
        
        // Whether the transition is a in or out.
        let isIn = state == .in
        // TODO: Possibly allow this to be set from delegate.
        let animationOptions = (isIn ? UIViewAnimationOptions.curveEaseIn : UIViewAnimationOptions.curveEaseOut)

        // Screen Dimensions
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        // Original center of the view is used in calculating animate.
        let originalCenter = self.center;
        
        // The points to animate center of the view from and to.
        var _from: CGPoint?
        var _to: CGPoint?
        
        // Select the appropiate transition.
        switch animation {
        case .fade:
            // Make the view appear and disappear aka change alpha
            UIView.animate(withDuration: duration, delay: 0.0, options: animationOptions, animations: {
                self.alpha = isIn ? 1 : 0
            }, completion: { (completed) in
                self.isHidden = !isIn
            })
        case .leftToRight:
            // Make view animate coming in from the left of the screen and exiting to the right.
            _from = isIn ? CGPoint(x: -self.bounds.width, y: originalCenter.y) : originalCenter
            _to   = isIn ? originalCenter : CGPoint(x: screenWidth+self.bounds.width, y: originalCenter.y)
        case .rightToLeft:
            // Make view animate coming in from the right of the screen and exiting to the left.
            _from = isIn ? CGPoint(x: screenWidth+self.bounds.width, y: originalCenter.y) : originalCenter
            _to   = isIn ? originalCenter : CGPoint(x: -self.bounds.width, y: originalCenter.y)
        case .slideUp:
            // Make view animate coming in from the bottom of the screen and exiting to the top.
            _from = isIn ? CGPoint(x: originalCenter.x, y: screenHeight+self.center.y) : originalCenter
            _to   = isIn ? originalCenter : CGPoint(x: originalCenter.x, y: -self.bounds.height)
        case .slideDown:
            // Make view animate coming in from the top of the screen and exiting to the bottom.
            _from = isIn ? CGPoint(x: originalCenter.x, y: -self.bounds.height) : originalCenter
            _to   = isIn ? originalCenter : CGPoint(x: originalCenter.x, y: screenHeight+self.center.y)
        case .none:
            // No animation just simple display or hide view.
            self.alpha = isIn ? 1 : 0
            self.isHidden = !isIn
        }
        
        // Make sure we have both a _from and _to since required to animate.
        guard let from = _from, let to = _to else {
            return
        }
        
        // Animate the view.
        self.animate(for: duration, fromCenter: from, toCenter: to, options: animationOptions, isIn: isIn, completion: completion)
    }
}
