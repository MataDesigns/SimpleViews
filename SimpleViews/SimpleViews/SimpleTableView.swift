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
    func simpleTableView(_ simpleTableView: SimpleTableView, viewFor state: SimpleViewState) -> UIView
    
    /// The animation for given state.
    ///
    /// - Parameter:
    ///   - simpleTableView: The SimpleTableView object requesting this information.
    ///   - state: The state for which we would like the animation for.
    /// - Returns: The animation that should be performed when view is entering or leaving this state.
    func simpleTableView(_ simpleTableView: SimpleTableView, animationFor state: SimpleViewState) -> SimpleAnimation
    
    /// Optional: The out animation when leaving a specific state. If function not implemented default out animation for
    /// simpleTableView(_ simpleTableView: SimpleTableView, animationFor state: SimpleViewState) -> SimpleAnimation will be used.
    ///
    /// - Parameters:
    ///   - simpleTableView: The SimpleTableView object requesting this information.
    ///   - state: The state for which we would like the out animation for.
    /// - Returns: The out animation that should be performed when view is leaving this state.
    @objc optional func simpleTableView(_ simpleTableView: SimpleTableView, outAnimationFor state: SimpleViewState) -> SimpleAnimation
    
    /// Optional: Notification for whenever SimpleTableView state is changed.
    ///
    /// - Parameters:
    ///   - simpleTableView: The SimpleTableView that is notifying the change.
    ///   - oldState: The old state of the SimpleTableView.
    ///   - state: The new state of the SimpleTableView.
    @objc optional func simpleTableView(_ simpleTableView: SimpleTableView, stateChangedFrom oldState: SimpleViewState, to state: SimpleViewState)
}

public class SimpleTableView: UITableView {
    
    /// Current state of the TableView.
    public var state: SimpleViewState = .loading {
        didSet {
            DispatchQueue.global(qos: .background).sync {
                // Notify delegate that the state did change.
                self.simpleDelegate?.simpleTableView?(self, stateChangedFrom: oldValue, to: state)
            }
            
            // In order to perform animations simpleDelegate must be set.
            guard let simpleDelegate = self.simpleDelegate else {
                return
            }
            // Get view for previous state.
            let previousView = simpleDelegate.simpleTableView(self, viewFor: oldValue)
            // Get out animation for previous state.
            var outAnimation = simpleDelegate.simpleTableView?(self, outAnimationFor: oldValue)
            if (outAnimation == nil) {
                // Get out animation for previous state based on in animation.
                outAnimation = simpleDelegate.simpleTableView(self, animationFor: oldValue)
            }
            // Get view for current state.
            let view = simpleDelegate.simpleTableView(self, viewFor: state)
            // Only perform animation if views are different.
            if previousView != view {
                // Perform out animation for previous state.
                previousView.perform(animation: outAnimation!, withState: .out)
                // Get in animation for current state.
                let inAnimation = simpleDelegate.simpleTableView(self, animationFor: state)
                // Perform in animation for current state.
                view.perform(animation: inAnimation, withState: .in)
            }
        }
    }
    
    /// Whether or not data has been fetched.
    public var fetched: Bool = false
    
    /// Delegate used for activiting states.
    public var simpleDelegate: SimpleTableViewDelegate?
    
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
    
    /// Will hide views but the view for the current state.
    /// simpleDelegate must be set before calling this or nothing will happen.
    public func initialize() {
        guard let simpleDelegate = self.simpleDelegate else {
            print("SimpleTableView: WARNING! Trying to initialize before simpleDelegate is set.")
            return
        }
        
        for state in iterateEnum(SimpleViewState.self) {
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
    
    private func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
    
    public override func reloadData() {
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
        
        super.reloadData()
    }
}
