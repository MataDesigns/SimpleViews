//
//  SimpleTableView.swift
//  SimpleViews
//
//  Created by Nicholas Mata on 7/29/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import UIKit

@objc public protocol SimpleViewDelegate {
    func view(forState state: SimpleViewState) -> UIView
    func transition(forState state: SimpleViewState) -> SimpleTransition
    @objc optional func transitionOut(forState state: SimpleViewState) -> SimpleTransition
    @objc optional func changed(from oldState: SimpleViewState, to state: SimpleViewState)
}

public class SimpleTableView: UITableView {
    
    /// Current state of the TableView.
    public var state: SimpleViewState = .loading {
        didSet {
            DispatchQueue.global(qos: .background).sync {
                // Notify delegate that the state did change.
                self.simpleDelegate?.changed?(from: oldValue, to: state)
            }
            
            // In order to perform transitions simpleDelegate must be set.
            guard let simpleDelegate = self.simpleDelegate else {
                return
            }
            // Get view for previous state.
            let previousView = simpleDelegate.view(forState: oldValue)
            // Get out transition for previous state.
            var outTransition = simpleDelegate.transitionOut?(forState: oldValue)
            if (outTransition == nil) {
                // Get out transition for previous state based of in transition.
                outTransition = simpleDelegate.transition(forState: oldValue)
            }
            // Get view for current state.
            let view = simpleDelegate.view(forState: state)
            // Only perform transition if views are different.
            if previousView != view {
                // Perform out transition for previous state.
                perform(transition: outTransition!, forView: previousView, transitionState: .out)
                // Get in transition for current state.
                let inTransition = simpleDelegate.transition(forState: state)
                // Perform in transition for current state.
                perform(transition: inTransition, forView: view, transitionState: .in)
            }
        }
    }
    
    /// Whether or not data has been fetched.
    public var fetched: Bool = false
    
    /// Delegate used for activiting states.
    public var simpleDelegate: SimpleViewDelegate?
    
    /// The total number of rows in all sections of the TableView.
    private var totalRows: Int {
        get{
            var totalRows = 0
            for i in 0 ..< (self.dataSource?.numberOfSections?(in: self) ?? 0) {
                let rowsInSection = self.dataSource?.tableView(self, numberOfRowsInSection: i) ?? 0
                totalRows += rowsInSection
            }
            return totalRows
        }
    }
    
    
    private func perform(transition: SimpleTransition, forView view:UIView, transitionState: SimpleTransitionState) {
        if (view.alpha == 0 && view.isHidden) {
            view.isHidden = false
        }
        
        let isIn = transitionState == .in
        let transitionOptions = (isIn ? UIViewAnimationOptions.curveEaseIn : UIViewAnimationOptions.curveEaseOut)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let originalCenter = view.center;
        
        
        switch transition {
        case .fade:
            UIView.animate(withDuration: 0.7, delay: 0.0, options: transitionOptions, animations: {
                view.alpha = isIn ? 1 : 0
            }, completion: { (completed) in
                view.isHidden = !isIn
            })
        case .leftToRight:
            view.center = isIn ? CGPoint(x: -view.bounds.width, y: originalCenter.y) : originalCenter
            UIView.animate(withDuration: 0.7, delay: 0.0, options: transitionOptions, animations: {
                view.isHidden = false
                view.alpha = 1
                view.center = isIn ? originalCenter : CGPoint(x: screenWidth+view.bounds.width, y: originalCenter.y)
            }, completion: { (completed) in
                view.isHidden = !isIn
            })
        case .rightToLeft:
            view.center = isIn ? CGPoint(x: screenWidth+view.bounds.width, y: originalCenter.y) : originalCenter
            UIView.animate(withDuration: 0.7, delay: 0.0, options: transitionOptions, animations: {
                view.isHidden = false
                view.alpha = 1
                view.center = isIn ? originalCenter : CGPoint(x: -view.bounds.width, y: originalCenter.y)
            }, completion: { (completed) in
                view.isHidden = !isIn
            })
        case .slideUp:
            view.center = isIn ? CGPoint(x: originalCenter.x, y: screenHeight+view.center.y) : originalCenter
            UIView.animate(withDuration: 0.7, delay: 0.0, options: transitionOptions, animations: {
                view.isHidden = false
                view.alpha = 1
                view.center = isIn ? originalCenter : CGPoint(x: originalCenter.x, y: -view.bounds.height)
            }, completion: { (completed) in
                view.isHidden = !isIn
            })
        case .slideDown:
            view.center = isIn ? CGPoint(x: originalCenter.x, y: -view.bounds.height) : originalCenter
            UIView.animate(withDuration: 0.7, delay: 0.0, options: transitionOptions, animations: {
                view.isHidden = false
                view.alpha = 1
                view.center = isIn ? originalCenter : CGPoint(x: originalCenter.x, y: screenHeight+view.center.y)
            }, completion: { (completed) in
                view.isHidden = !isIn
            })
        case .none:
            view.isHidden = !isIn
            break
        }
        
    }
    
    public func initialize() {
        guard let simpleDelegate = self.simpleDelegate else {
            print("SimpleTableView: WARNING! Trying to initialize before simpleDelegate is set.")
            return
        }
        
        // Hide empty view
        let emptyView = simpleDelegate.view(forState: .empty)
        emptyView.isHidden = true
        emptyView.alpha = 0.0
        
        // Hide content/finished view
        let contentView = simpleDelegate.view(forState: .finished)
        contentView.isHidden = true
        contentView.alpha = 0.0
        
        // Perform in transition for loading view.
        let loadingView = simpleDelegate.view(forState: .loading)
        let loadingTransition = simpleDelegate.transition(forState: .loading)
        perform(transition: loadingTransition, forView: loadingView, transitionState: .in)

    }
    
    public override func reloadData() {
        if fetched {
            // Set states based off rows.
            switch totalRows {
            case let rows where rows > 1:
                state = .finished
            case 0:
                state = .empty
            default:
                state = .loading
            }
        } else {
            state = .loading
        }
        
        super.reloadData()
    }
}
