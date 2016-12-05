//
//  SlideInPresentationController.swift
//  MedalCount
//
//  Created by ronatory on 03/12/2016.
//  Copyright © 2016 ronatory. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {

  // MARK: - Properties
  
  fileprivate var dimmingView: UIView!
  /// Represent the direction of the presentation
  private var direction: PresentationDirection
  
  // to calculating the size of the presented view, you need to return its full frame
  // to do this you'll override the frameOfPresentedViewInContainerView property
  override var frameOfPresentedViewInContainerView: CGRect {
    
    // declare a frame
    var frame: CGRect = .zero
    // give the frame the size calculated
    frame.size = size(forChildContentContainer: presentedViewController,
                      withParentContainerSize: containerView!.bounds.size)
    
    // for .right and .bottom directions, you adjust the origin by moving the x origin (.right) 
    // and y origin (.bottom) 1/3 of the width or height
    switch direction {
    case .right:
      frame.origin.x = containerView!.frame.width*(1.0/3.0)
    case .bottom:
      frame.origin.y = containerView!.frame.height*(1.0/3.0)
    default:
      frame.origin = .zero
    }
    return frame
  }
  
  
  // MARK: - Methods
  
  // Declares an initializer that accepts the presented and presenting view controllers as well as the presentation direction
  init(presentedViewController: UIViewController,
       presenting presentingViewController: UIViewController?,
       direction: PresentationDirection) {
    self.direction = direction
    
    // Calls the designated initializer for UIPresentationController and then passes it to the presented and presenting view controllers
    super.init(presentedViewController: presentedViewController,
               presenting: presentingViewController)
    
    setupDimmingView()
  }
  
  override func presentationTransitionWillBegin() {
    // UIPresentationController has a property named containerView. It holds the view hierarchy of the presentation and presented controllers
    // This section is where you insert the dimmingView into the back of the view hierarchy
    containerView?.insertSubview(dimmingView, at: 0)
    
    // Constrain the dimming view to the edges of the container view so that it fills the entire screen
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
        options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
        options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    
    // UIPresentationController's transitionCoordinator has a method to animate things during
    // the transition. Here you set the dimming view's alpha property to 1.0 along the presentation transition
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 1.0
    })
  }
  
  override func dismissalTransitionWillBegin() {
    // similar to presentationTransitionWillBegin(), you set dimming view's alpha to 0.0 alongside the dismissal transition, which has the effect of fading the dimming view
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 0.0
    })
  }
  
  // responds to layout changes in the presentation controllers containerView
  override func containerViewWillLayoutSubviews() {
    // reset the presented view's frame to fit any changes to the containerView frame
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
  
  // receives the content container and parent view's size, and then it calculates the size for the presented content.
  // In this code, you restrict the presented view to 2/3 of the screen by return 2/3 the width for horizontal and 2/3 the height of vertical presentations
  override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
    switch direction {
    case .left, .right:
      return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
    case .bottom, .top:
      return CGSize(width: parentSize.width, height: parentSize.height*(2.0/3.0))
    }
  }
}

// MARK: - Private
private extension SlideInPresentationController {
  /// Create a dimming view, prepare for Auto Layout, and set its background color
  func setupDimmingView() {
    dimmingView = UIView()
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    dimmingView.alpha = 0.0
    
    // This adds a tap gesture to the dimming view and links it to the action method
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }
  
  /// Make the presented view controller itself scarce when tap the dimmed view
  /// Create a UITapGestureRecognizer handler that dismisses the controller
  /// See also about "dynamic": http://stackoverflow.com/questions/25140778/why-does-adding-dynamic-fix-my-bad-access-issues
  dynamic func handleTap(recognizer: UITapGestureRecognizer) {
    presentingViewController.dismiss(animated:true)
  }
}
