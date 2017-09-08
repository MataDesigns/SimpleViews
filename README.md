# SimpleViews

[![Version](https://img.shields.io/cocoapods/v/SimpleViews.svg?style=flat)](http://cocoapods.org/pods/SimpleViews)
[![License](https://img.shields.io/cocoapods/l/SimpleViews.svg?style=flat)](http://cocoapods.org/pods/SimpleViews)
[![Platform](https://img.shields.io/cocoapods/p/SimpleViews.svg?style=flat)](http://cocoapods.org/pods/SimpleViews)

A framework to simplify complex views and allow for simple animation of views.

- [Usage](#usage)
    - **SimpleTableView -** [What is this?](#simpletableview-what-is), [How do I use it](#simpletableview-how-to)
    - **SimpleAnimation -** [What is this?](#simpleanimation-what-is), [How do I use it](#simpleanimation-how-to)


## Requirements
- iOS 9.0+

## Usage

### SimpleTableView

#### What is this? <a id="simpletableview-what-is"></a> 

This a subclass of UITableView which makes it **SIMPLE** to do things like. 

  * Have a **loading** view before the table is displayed, useful while you're waiting for a network call to return.
  * Have a **failed** view if your network call failed.
  * Have a **empty** view that is shown when the table has no data yet.
  * Have transitions between loading, empty, finished, and failed states.
  
#### How do I use it? <a id="simpletableview-how-to"></a> 

Look at example inside the project for now.


### SimpleAnimation

#### What is this? <a id="simpleanimation-what-is"></a> 

Makes animating views onto the screen and off the screen. **Only tested using storyboards so far**

There are few simple animations currently, these animations have two states in and out.
  
  * fade - Which simply fades a view onto or off the screen.
  * leftToRight 
    * In  - Will animate the view from off screen left to its position specified in storyboard using constraints.
    * Out - Will animate the view from its original position to off screen right.
  * rightToLeft - is LeftToRight but in the opposite direction.
  * slideUp 
    * In  - Will animate the view from off screen bottom to its position specified in storyboard using constraints.
    * Out - Will animate the view from its original position to off screen top.
  * slideDown

#### How do I use it? <a id="simpleanimation-how-to"></a> 

You can perform a SimpleAnimation on any UIView or subclass of UIView aka (UIButton, UITableView, etc..)

Take a look at the example project the IBOutlet errorStackView are animated using SimpleAnimation.

Example Code
``` swift
class ExampleViewController: UIViewController {
  @IBOutlet weak var contentView: UIView!
  
  override func viewDidLoad() {
        super.viewDidLoad()
        // You need to initialize anything that has an in animation, in this case contentView.
        SimpleAnimation.initialize(views: [contentView])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    contentView.perform(animation: .fade, forDuration: 0.7, withState: .in)
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      contentView.perform(animation: .fade, forDuration: 0.7, withState: .out)
  }
      
}
```
