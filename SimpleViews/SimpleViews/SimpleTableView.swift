//
//  SimpleTableView.swift
//  SimpleViews
//
//  Created by Nicholas Mata on 7/29/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import UIKit

@objc public protocol SimpleTableViewDelegate {
    
    /// The view that should be displayed for the state of the SimpleTableView.
    ///
    /// - Parameter:
    ///   - simpleTableView: The SimpleTableView object requesting this information.
    ///   - state: The state for which we would like the view for.
    /// - Returns: The view that should be displayed when in this state.
    func simpleTableView(_ simpleTableView:SimpleTableView, viewFor state:SimpleViewState) -> UIView
    
    /// The animation for given state.
    ///
    /// - Parameter:
    ///   - simpleTableView: The SimpleTableView object requesting this information.
    ///   - state: The state for which we would like the animation for.
    /// - Returns: The animation that should be performed when view is entering or leaving this state.
    func simpleTableView(_ simpleTableView:SimpleTableView, animationFor state:SimpleViewState) -> SimpleAnimation
    
    
    /// Optional: Whether an animation from one state to another should be animated
    ///
    /// - Parameters:
    ///   - simpleTableView: The SimpleTableView object requesting this information.
    ///   - oldState: The old state of the SimpleTableView
    ///   - state: The current state of the SimpleTableView
    /// - Returns: Whether animation should occur.
    @objc optional func simpleTableView(_ simpleTableView:SimpleTableView, shouldAnimateFromState oldState:SimpleViewState, to state:SimpleViewState) -> Bool
    
    /// Optional: The duration for an both an in and out animation. Without this default for all animations is 0.7 this can be changed using tableView.defaultDuration.
    ///
    /// - Parameters:
    ///   - simpleTableView: The SimpleTableView object requesting this information.
    ///   - state: The state for which we would like the animation duration for.
    /// - Returns: The animation duration for that state.
    @objc optional func simpleTableView(_ simpleTableView:SimpleTableView, animationDuration state:SimpleViewState) -> Double
    
    /// Optional: The out animation when leaving a specific state. If function not implemented default out animation for
    /// simpleTableView(_ simpleTableView: SimpleTableView, animationFor state: SimpleViewState) -> SimpleAnimation will be used.
    ///
    /// - Parameters:
    ///   - simpleTableView: The SimpleTableView object requesting this information.
    ///   - state: The state for which we would like the out animation for.
    /// - Returns: The out animation that should be performed when view is leaving this state.
    @objc optional func simpleTableView(_ simpleTableView:SimpleTableView, outAnimationFor state:SimpleViewState) -> SimpleAnimation
    
    /// Optional: Notification for whenever SimpleTableView state is changed.
    ///
    /// - Parameters:
    ///   - simpleTableView: The SimpleTableView that is notifying the change.
    ///   - oldState: The old state of the SimpleTableView.
    ///   - state: The new state of the SimpleTableView.
    @objc optional func simpleTableView(_ simpleTableView:SimpleTableView, stateChangedFrom oldState:SimpleViewState, to state:SimpleViewState)
}

public class SimpleTableView: UITableView {
    
    /// Current state of the TableView.
    public var state: SimpleViewState = .loading {
        didSet {
            // In order to perform animations simpleDelegate must be set.
            guard let simpleDelegate = self.simpleDelegate else {
                return
            }
            
            // Whether animation should happen.
            let shouldAnimate = simpleDelegate.simpleTableView?(self, shouldAnimateFromState: oldValue, to: state)
            if !(shouldAnimate ?? true) {
                return
            }
            
            DispatchQueue.global(qos: .background).sync {
                // Notify delegate that the state did change.
                simpleDelegate.simpleTableView?(self, stateChangedFrom: oldValue, to: state)
            }
            
            // Get view for previous state.
            let previousView = simpleDelegate.simpleTableView(self, viewFor: oldValue)
            // Get out animation for previous state.
            var outAnimation = simpleDelegate.simpleTableView?(self, outAnimationFor: oldValue)
            if (outAnimation == nil) {
                // Get out animation for previous state based on in animation.
                outAnimation = simpleDelegate.simpleTableView(self, animationFor: oldValue)
            }
            // Get out animation duration for current state.
            let outDuration = simpleDelegate.simpleTableView?(self, animationDuration: oldValue)
            // Get view for current state.
            let view = simpleDelegate.simpleTableView(self, viewFor: state)
            // Only perform animation if views are different.
            if previousView != view {
                // Perform out animation for previous state.
                previousView.perform(animation: outAnimation!, forDuration: outDuration ?? defaultDuration, withState: .out) {
                    (completed) in
                    
                    // Get in animation for current state.
                    let inAnimation = simpleDelegate.simpleTableView(self, animationFor: self.state)
                    // Get in animation duration for current state.
                    let inDuration = simpleDelegate.simpleTableView?(self, animationDuration: self.state)
                    // Perform in animation for current state.
                    view.perform(animation: inAnimation, forDuration: inDuration ?? self.defaultDuration, withState: .in)
                }
            }
        }
    }
    
    /// The default animation duration for all state transitions.
    /// - Remark:
    /// Implement simpleTableView(_ simpleTableView: SimpleTableView, animationDuration state: SimpleViewState) -> Double on simpleDelegate if you need different durations for different states.
    public var defaultDuration: Double = 0.7
    
    /// Whether or not data has been fetched.
    public var fetched: Bool = false
    
    /// Delegate used for activiting states.
    public var simpleDelegate: SimpleTableViewDelegate?
    
    /// The total number of rows in all sections of the TableView.
    private var totalRows: Int {
        get{
            var totalRows = 0
            for i in 0 ..< (self.dataSource?.numberOfSections?(in: self) ?? 1) {
                let rowsInSection = self.dataSource?.tableView(self, numberOfRowsInSection: i) ?? 0
                totalRows += rowsInSection
            }
            return totalRows
        }
    }
    
    /// Will hide views but the view for the current state.
    /// simpleDelegate must be set before calling this or nothing will happen.
    public func initialize() {
        guard let simpleDelegate = self.simpleDelegate else {
            print("SimpleTableView: WARNING! Trying to initialize before simpleDelegate is set.")
            return
        }
        
        
        for state in SimpleViewState.all {
            if(state != self.state) {
                let view = simpleDelegate.simpleTableView(self, viewFor: state)
                initialize(view: view)
            }
        }
        
        let initialView = simpleDelegate.simpleTableView(self, viewFor: state)
        initialView.alpha = 0.0
        let initialAnimation = simpleDelegate.simpleTableView(self, animationFor: state)
        initialView.perform(animation: initialAnimation, withState: .in)
    }
    
    private func initialize(view: UIView) {
        view.isHidden = true
        view.alpha = 0.0
    }
    
    public override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        self.updateState()
        super.deleteRows(at: indexPaths, with: animation)
    }
    
    public override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        self.updateState()
        super.insertRows(at: indexPaths, with: animation)
    }
    
    public override func reloadData() {
        self.updateState()
        super.reloadData()
    }
    
    func updateState() {
        if state != .failed {
            if fetched {
                // Set states based off row count.
                switch totalRows {
                case let rows where rows > 0:
                    state = .finished
                case 0:
                    state = .empty
                default:
                    state = .loading
                }
            } else {
                state = .loading
            }
        }
    }
}
