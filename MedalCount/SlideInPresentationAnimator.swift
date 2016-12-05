//
//  SlideInPresentationAnimator.swift
//  MedalCount
//
//  Created by ronatory on 04/12/2016.
//  Copyright © 2016 ronatory. All rights reserved.
//

import UIKit

class SlideInPresentationAnimator: NSObject {
  
  // MARK: - Properties
  
  // tell the animation controller the direction from which it should animate the view controller's view
  let direction: PresentationDirection
  
  // tell the animation controller whether to present or dismiss the view controller
  let isPresentation: Bool
  
  // MARK: - Initializers
  init(direction: PresentationDirection, isPresentation: Bool) {
    self.direction = direction
    self.isPresentation = isPresentation
    super.init()
  }
}

// MARK: - UIViewControllerAnimatedTransitioning
// this protocol has two required methods - one to define how long the transition takes
// and one to perform the animations
extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
  // how long should the animatione be
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  // perform the animation
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    // if its a presentation, the method asks the transitionContext for the view controller associated with the .to key
    // aka the view controller you're moving to. If dismissal, it asks the transitionContext for the view controller
    // associated with the .from, aka the view controller you're moving from
    let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
    
    let controller = transitionContext.viewController(forKey: key)!
    
    // if the action is a presentation, your code adds the view controller's view to the view hierarchy
    // this code uses the transitionContext to get the container view
    if isPresentation {
      transitionContext.containerView.addSubview(controller.view)
    }
    
    // calculate the frames you're animating from and to
    // here you ask the transitionContext for the view's frame when it's presented. The rest of the section 
    // tackles the trickier task of calculating the view's frame when it's dismissed. This section sets the frame's origin
    // so it's just outside the visible area based on the presentation direction
    let presentedFrame = transitionContext.finalFrame(for: controller)
    var dismissedFrame = presentedFrame
    switch direction {
    case .left:
      dismissedFrame.origin.x = -presentedFrame.width
    case .right:
      dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
    case .top:
      dismissedFrame.origin.y = -presentedFrame.height
    case .bottom:
      dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
    }
    
    // determine the transition's initial and final frames. when presenting the view controller, it moves from
    // the dismissed frame to the presented frame - vice versa when dismissing
    let initialFrame = isPresentation ? dismissedFrame : presentedFrame
    let finalFrame = isPresentation ? presentedFrame : dismissedFrame
    
    // animate the view from initial to final frame
    // Note: it calls completeTransition(_:) on the transitionContext to show the transition has finished
    let animationDuration = transitionDuration(using: transitionContext)
    controller.view.frame = initialFrame
    UIView.animate(withDuration: animationDuration, animations: {
      controller.view.frame = finalFrame
    }) { finished in
      transitionContext.completeTransition(finished)
    }
  }
}
