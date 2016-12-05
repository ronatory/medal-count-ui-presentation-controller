//
//  SlideInPresentationManager.swift
//  MedalCount
//
//  Created by ronatory on 03/12/2016.
//  Copyright © 2016 ronatory. All rights reserved.
//

import UIKit

/// Represent the presentation's direction
enum PresentationDirection {
  case left
  case top
  case right
  case bottom
}

class SlideInPresentationManager: NSObject {
  var direction = PresentationDirection.left
  // to indicate if the presentation supports compact height
  var disableCompactHeight = false
}

// MARK: - UIViewControllerTransitionDelegate
extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    let presentationController = SlideInPresentationController(presentedViewController: presented, presenting: presenting, direction: direction)
    presentationController.delegate = self
    
    return presentationController
  }
  
  // returns the animation controller for presenting the view controller
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideInPresentationAnimator(direction: direction, isPresentation: true)
  }
  
  // returns the animation controller for dismissing the view controller
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideInPresentationAnimator(direction: direction, isPresentation: false)
  }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    // if traitCollection's verticalSizeClass equals .compact and if compact height is disabled for this presentation
    // in other words if its in landscape
    if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
      // just cover the entire screen
      return .overFullScreen
    } else {
      // stay with the presentationController implementation
      return .none
    }
  }
  
  func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
    // return nil if original view controller should be presented
    guard style == .overFullScreen else { return nil }
    
    // if the presentation style is .overFullScreen it creates and returns a different view controller 
    // the new view controller is a UIViewController with an image that tells the user to rotate the screen to Portrait
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RotateViewController")
  }
}
