//
//  PBPopupController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 14/04/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import ObjectiveC


// For Debug View Hierarchy Name
internal class PBPopupBarView: UIView {
   internal override init(frame: CGRect) {
      super.init(frame: frame)
   }

   required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}

/**
 Available states of PBPopupController.
 */
@objc public enum PBPopupPresentationState: Int {
   /**
    The popup bar is hidden, not presented.
    */
   case hidden
   /**
    The popup bar is in presenting transition, will be shown. State will be closed.
    */
   case presenting
   /**
    The popup bar is in dismissing transition, will be hidden, dismissed.
    */
   case dismissing
   /**
    The popup bar is presented, popup content view is closed, hidden.
    */
   case closed
   /**
    The popup bar is presented, hidden while popup content view is open, shown.
    */
   case open
   /**
    The popup content view is in presenting transition, will be open, shown.
    */
   case opening
   /**
    The popup content view is in dismissing transition, will be closed, hidden.
    */
   case closing
   
}

extension PBPopupPresentationState {
   private static let strings = ["hidden", "presenting", "dismissing", "closed", "open", "opening", "closing"]
   
   private func string() -> NSString {
      return PBPopupPresentationState.strings[self.rawValue] as NSString
   }
   
   /**
    Return an human readable description for the PBPopupController state.
    */
   public var description: NSString {
      get {
         return string()
      }
   }
}

/**
 Available popup content view presentation styles.

 Use the most appropriate style for the current operating system version. Uses fullScreen for iOS 9 and above, otherwise deck.
 */
@objc public enum PBPopupPresentationStyle : Int {
   
   /**
    A presentation style which attempt to recreate the card-like transition found in the iOS 10 Apple Music.
    */
   case deck
   
   /**
    A presentation style in which the presented view covers the screen.
    */
   case fullScreen
   
   /**
    A presentation style in which the presented view covers a part of the screen (height only).
    */
   case custom
   
   /**
    Default presentation style: fullScreen for iOS 9 and above, otherwise deck.
    */
   public static let `default`: PBPopupPresentationStyle = {
      if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10) {
         return .fullScreen
      }
      return .deck
   }()
}

extension PBPopupPresentationStyle {
   /**
    An array of human readable strings for the popup content view presentation styles.
    */
   public static let strings = ["deck", "fullScreen", "custom"]
   
   private func string() -> NSString {
      return PBPopupPresentationStyle.strings[self.rawValue] as NSString
   }
   
   /**
    Return an human readable description for the popup content view presentation style.
    */
   public var description: NSString {
      get {
         return string()
      }
   }
}

@objc public protocol PBPopupControllerDataSource: NSObjectProtocol {
   
   /**
    Returns a custom bottom bar view. The popup bar will be attached to.
    
    - Parameters:
    - popupController:             The popup controller object.
    
    - Returns:
    The view object representing the bottom bar view.
    */
   @objc optional func bottomBarView(for popupController: PBPopupController) -> UIView?
   
   /**
    Returns the default frame for the bottom bar view.
    
    - Parameters:
    - popupController:             The popup controller object.
    - bottomBarView:               The bottom bar view returned by 'bottomBarView(for:)'
    
    - Returns:
    The default frame for the bottom bar view, when the popup is in hidden or closed state. If `bottomBarView` returns nil or is not implemented, this method is not called, and the default system-provided frame is used.
    
    - SeeAlso: bottomBarView(for:)
    */
   @objc optional func popupController(_ popupController: PBPopupController, defaultFrameFor bottomBarView: UIView) -> CGRect

   /**
    Returns the insets for the bottom bar view from bottom of the container controller's view. By default, this is set to the container controller view's safe area insets since iOS 11 or `UIEdgeInsets.zero` otherwise. Currently, only the bottom inset is respected.
    
    The system calculates the position of the popup bar by summing the bottom bar height and the bottom of the insets.
    
    - Parameters:
    - popupController:             The popup controller object.
    - bottomBarView:               The bottom bar view returned by 'bottomBarView(for:)'

    - Returns:
    The insets for the bottom bar view from bottom of the container controller's view. If `bottomBarView` returns nil or is not implemented, this method is not called, and the default system-provided bottom inset is used.
    
    - SeeAlso: bottomBarView(for:)
    */
   @objc optional func popupController(_ popupController: PBPopupController, insetsFor bottomBarView: UIView) -> UIEdgeInsets
}

@objc public protocol PBPopupControllerDelegate: NSObjectProtocol {
   /**
    Called just before the popup bar view is presenting.
    
    - Parameters:
    - popupController:     The popup controller object.
    - popupBar       :     The popup bar object.
    */
   @objc optional func popupController(_ popupController: PBPopupController, willPresent popupBar: PBPopupBar)
   
   /**
    Called just before the popup bar view is dismissing.
    
    - Parameters:
    - popupController:     The popup controller object.
    - popupBar       :     The popup bar object.
    */
   @objc optional func popupController(_ popupController: PBPopupController, willDismiss popupBar: PBPopupBar)
   
   /**
    Called just after the popup bar view is presenting.
    
    - Parameters:
    - popupController:     The popup controller object.
    - popupBar       :     The popup bar object.
    */
   @objc optional func popupController(_ popupController: PBPopupController, didPresent popupBar: PBPopupBar)
   
   /**
    Called just after the popup bar view is dismissing.
    
    - Parameters:
    - popupController:     The popup controller object.
    - popupBar       :     The popup bar object.
    */
   @objc optional func popupController(_ popupController: PBPopupController, didDismiss popupBar: PBPopupBar)
   
   /**
    Called just before the popup content view is about to be open.
    
    - Parameters:
    - popupController:             The popup controller object.
    - popuContentViewController:   The popup content view controller object.
    */
   @objc optional func popupController(_ popupController: PBPopupController, willOpen popupContentViewController: UIViewController)
   
   /**
    Called just before the popup content view is about to be closed.
    
    - Parameters:
    - popupController:             The popup controller object.
    - popuContentViewController:   The popup content view controller object.
    */
   @objc optional func popupController(_ popupController: PBPopupController, willClose popupContentViewController: UIViewController)
   
  /**
    Called just after the popup content view is open.
    
    - Parameters:
    - popupController:             The popup controller object.
    - popuContentViewController:   The popup content view controller object.
    */
   @objc optional func popupController(_ popupController: PBPopupController, didOpen popupContentViewController: UIViewController)
   
   /**
    Called just after the popup content view is closed.
    
    - Parameters:
    - popupController:             The popup controller object.
    - popuContentViewController:   The popup content view controller object.
    */
   @objc optional func popupController(_ popupController: PBPopupController, didClose popupContentViewController: UIViewController)
   
   /**
    Called several times during the interactive presentation.
    
    - Parameters:
    - popupController:             The popup controller object.
    - popuContentViewController:   The popup content view controller object.
    - state:                       The popup presentation state (closed / open).
    - progress:                    The current progress of the interactive presentation
    - location:                    The current location. The y-coordinate of the point on screen.
    
    - Note: The current progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the interactive presentation.
    
    - SeeAlso: `PBPopupPresentationState`.
    */
   @objc optional func popupController(_ popupController: PBPopupController, interactivePresentationFor popupContentViewController: UIViewController, state: PBPopupPresentationState, progress: CGFloat, location: CGFloat)
   
   /**
    Called when the presentation state of the popup controller has changed.
    
    - Parameters:
    - popupController:  The popup controller object.
    - state:            The popup presentation state.
    - previousState:    The previous popup presentation state.
    
    - SeeAlso: `PBPopupPresentationState`.
    */
   @objc optional func popupController(_ popupController: PBPopupController, stateChanged state: PBPopupPresentationState, previousState: PBPopupPresentationState)
   
}

@objc public class PBPopupController: UIViewController {
   
   // MARK: - Public Properties
   
   /**
    The data source of the PBPopupController object.
    
    - SeeAlso: `PBPopupControllerDataSource`.
    */
   @objc weak open var dataSource: PBPopupControllerDataSource?
   
   /**
    The delegate of the PBPopupController object.
    
    - SeeAlso: `PBPopupControllerDelegate`.
    */
   @objc weak open var delegate: PBPopupControllerDelegate?
   
   /**
    The state of the popup presentation. (read-only)
    
    - SeeAlso:
      - `PBPopupPresentationState`.
      - `PBPopupControllerDelegate`.
    */
   @objc public internal(set) var popupPresentationState: PBPopupPresentationState

   
   // MARK: - Private Properties
   
   @objc internal var containerViewController: UIViewController!
   
   internal var popupBarView: PBPopupBarView! = {
      let view = PBPopupBarView()
      view.autoresizingMask = []
      view.autoresizesSubviews = true
      view.preservesSuperviewLayoutMargins = true
      // Important
      view.clipsToBounds = true
      return view
   }()
   
   internal var bottomBarHeight: CGFloat {
      let vc = self.containerViewController!
      if vc.bottomBar.isHidden {
         return 0.0
      }
      if vc is UITabBarController {
         return vc.defaultFrameForBottomBar().height
      }
      else if vc is UINavigationController && (vc.bottomBar == (vc as! UINavigationController).toolbar) {
         let hidden = (vc as! UINavigationController).isToolbarHidden
         return hidden ? 0.0 : vc.defaultFrameForBottomBar().height
      }
      else {
         return vc.bottomBar.frame.height
      }
   }
   
   private var disableInteractiveTransitioning = false
   
   internal var popupPresentationController: PBPopupPresentationController?
   internal var popupPresentationInteractiveController: PBPopupInteractivePresentationController!
   internal var popupDismissalInteractiveController: PBPopupInteractivePresentationController!
   
   private weak var previewingContext: UIViewControllerPreviewing?
   
   // MARK: - Init
   
   internal init(containerViewController controller: UIViewController)
   {
      self.popupPresentationState = .hidden
      super.init(nibName: nil, bundle: nil)
      
      self.containerViewController = controller
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   deinit {
      PBLog("deinit \(self)")
      if let previewingContext = self.previewingContext, let vc = self.containerViewController {
         vc.unregisterForPreviewing(withContext: previewingContext)
         self.containerViewController = nil
      }
   }
   
   internal func pb_popupBar() -> PBPopupBar {
      let rv = PBPopupBar()
      self.popupBarView.frame = CGRect(x: 0, y: 0, width: self.containerViewController.view.bounds.width, height: rv.popupBarHeight)
      rv.frame = CGRect(x: 0, y: 0, width: self.popupBarView.frame.width, height: self.popupBarView.frame.height)
      rv.isHidden = true
      self.popupPresentationState = .hidden
      
      rv.popupTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.popupTapGestureRecognized(tgr:)))
      rv.addGestureRecognizer(rv.popupTapGestureRecognizer)
      // Adding the popupBar to the view now, if not get toolbar items frame will not work in PBPopupBar.
      self.popupBarView.addSubview(rv)
      
      self.containerViewController.popupBar = rv
      rv.popupController = self
      
      return rv
   }
   
   internal func pb_bottomBar() -> UIView! {
      var rv: UIView? = nil
      if self.containerViewController is UITabBarController {
         rv = (self.containerViewController as! UITabBarController).tabBar
      }
      else if self.containerViewController is UINavigationController {
         rv = (self.containerViewController as! UINavigationController).toolbar
      }
      if rv == nil {
         if let view = self.dataSource?.bottomBarView?(for: self) {
            rv = view
         }
         else {
            let y: CGFloat = self.containerViewController.view.frame.size.height
            
            rv = UIView(frame: CGRect(x: 0.0, y: y, width: self.containerViewController.view.frame.size.width, height: 0.0))
            rv!.isHidden = true
            self.containerViewController.view.addSubview(rv!)
            if self.containerViewController.view is UIScrollView {
               PBLog("Attempted to present popup bar:\n \(String(describing: self.containerViewController.popupBar)) \non top of a UIScrollView subclass:\n \(String(describing: self.containerViewController.view)).\nThis is unsupported and may result in unexpected behavior.", error: true)
            }
         }
      }
      
      self.containerViewController.bottomBar = rv
      
      return rv
   }
   
   internal func pb_popupContentView() -> PBPopupContentView! {
      let rv = PBPopupContentView()
      rv.autoresizingMask = []

      rv.clipsToBounds = false

      rv.popupController = self
      //rv.autoresizesSubviews = true // default: true
      //rv.contentView.autoresizesSubviews = true // default: true
      rv.preservesSuperviewLayoutMargins = true // default: false
      rv.contentView.preservesSuperviewLayoutMargins = true  // default: false
      rv.layer.masksToBounds = true
      
      self.containerViewController.popupContentView = rv
      
      return rv
   }
   
   // MARK: - Popup Bar Animation
   
   internal func _presentPopupBarAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil) {
      
      guard let vc = self.containerViewController else
      {
         completionBlock?()
         return
      }
      
      if self.popupPresentationState != .hidden {
         return
      }
      /*
       var coordinator: _PBPopupTransitionCoordinator? = _PBPopupTransitionCoordinator(containerView: self)
       if let aCoordinator = coordinator {
       containerController.popupContentViewController.willTransition(to: containerController.traitCollection, with: aCoordinator)
       }
       if let aCoordinator = coordinator {
       containerController.popupContentViewController.viewWillTransition(to: containerController.view.bounds.size, with: aCoordinator)
       }
       */
      
      if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 9), vc.traitCollection.forceTouchCapability == .available {
         self.previewingContext = vc.registerForPreviewing(with: self, sourceView: vc.popupBar)
      }
      
      var previousState = self.popupPresentationState
      self.popupPresentationState = .presenting
      self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
      self.delegate?.popupController?(self, willPresent: vc.popupBar)
      
      let height = vc.popupBar.popupBarHeight

      vc.popupBar.frame = CGRect(x: 0.0, y: 0.0, width: vc.view.bounds.size.width, height: height)
      
      self.popupBarView.frame = self.popupBarViewFrameForPopupStateHidden()
      
      vc.view.insertSubview(self.popupBarView, belowSubview: vc.bottomBar)
      
      vc.view.layoutIfNeeded()
      
      vc.popupBar.setNeedsLayout()
      vc.popupBar.layoutIfNeeded()
      
      vc.popupBar.isHidden = false
      
      UIView.animate(withDuration: animated ? vc.popupBar.popupBarPresentationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [.curveEaseInOut/*, .layoutSubviews*/], animations: {
         
         self.popupBarView.frame = self.popupBarViewFrameForPopupStateClosed()

         _LNPopupSupportFixInsetsForViewController(vc, true, height)
      }) { (success) in
         previousState = self.popupPresentationState
         self.popupPresentationState = .closed
         self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
         self.delegate?.popupController?(self, didPresent: vc.popupBar)

         self.preparePopupContentViewControllerForPresentation()
         
         completionBlock?()
      }
      
   }

   internal func _dismissPopupBarAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil) {
      
      guard let vc = self.containerViewController else
      {
         completionBlock?()
         return
      }
      
      if self.popupPresentationState == .hidden {
         completionBlock?()
         return
      }

      var previousState = self.popupPresentationState
      self.popupPresentationState = .dismissing
      self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
      self.delegate?.popupController?(self, willDismiss: vc.popupBar)

      let height = vc.popupBar.popupBarHeight

      let contentFrame = self.popupBarViewFrameForPopupStateHidden()
      
      vc.popupBar.ignoreLayoutDuringTransition = true
      UIView.animate(withDuration: animated ? vc.popupBar.popupBarPresentationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [.curveLinear, .layoutSubviews], animations: {
         self.popupBarView.frame = contentFrame
         self.popupBarView.alpha = 0.0
         _LNPopupSupportFixInsetsForViewController(vc, animated ? true : false, -height)
      }) { (success) in
         previousState = self.popupPresentationState
         self.popupPresentationState = .hidden
         self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
         vc.popupBar.removeFromSuperview()
         vc.popupBar = nil
         self.popupBarView.removeFromSuperview()
         self.popupBarView = nil
         self.delegate?.popupController?(self, didDismiss: vc.popupBar)
         vc.popupContentViewController.popupContainerViewController = nil
         vc.popupContentViewController = nil
         completionBlock?()
      }
   }
   
   // MARK: - Gesture recognizers
   
   @objc internal func popupTapGestureRecognized(tgr: UITapGestureRecognizer) {
      let vc = self.containerViewController!
      vc.popupBar.setHighlighted(true, animated: false)
      self._openPopupAnimated(true) {
         vc.popupBar.setHighlighted(false, animated: false)
      }
   }
   
   // MARK: - Popup Content Animation
   
   internal func preparePopupContentViewControllerForPresentation() {
      
      if let vc = self.containerViewController {
         
         self.popupPresentationInteractiveController = PBPopupInteractivePresentationController()
         self.popupPresentationInteractiveController.attachToViewController(popupController: self, withView: self.popupBarView, presenting: true)
         self.popupPresentationInteractiveController.delegate = self
         
         self.popupDismissalInteractiveController = PBPopupInteractivePresentationController()
         self.popupDismissalInteractiveController.attachToViewController(popupController: self, withView: vc.popupContentViewController.view, presenting: false)
         self.popupDismissalInteractiveController.delegate = self
         
         if let popupVC = vc.popupContentViewController {
            popupVC.transitioningDelegate = self
            popupVC.modalPresentationStyle = .custom
            popupVC.modalPresentationCapturesStatusBarAppearance = true
         }
      }
   }
   
   @objc internal func closePopupContent() {
      self._closePopupAnimated(true)
   }
   
   internal func _openPopupAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil) {
      guard let vc = self.containerViewController else
      {
         completionBlock?()
         return
      }
      if vc.popupContentViewController == nil {
         completionBlock?()
         return
      }
      if self.popupPresentationState == .closed {
         self.popupPresentationState = .opening
         self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: .closed)
         self.delegate?.popupController?(self, willOpen: vc.popupContentViewController)
         self.disableInteractiveTransitioning = true
         
         vc.present(vc.popupContentViewController, animated: true) {
            
            if vc.popupContentViewController.view is UIScrollView {
               let scrollView = vc.popupContentViewController.view as! UIScrollView
               self.popupDismissalInteractiveController.contentOffset = scrollView.contentOffset
            }
            
            self.popupPresentationState = .open
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: .opening)
            self.disableInteractiveTransitioning = false
            self.delegate?.popupController?(self, didOpen: vc.popupContentViewController)
            completionBlock?()
         }
      }
   }
   
   internal func _closePopupAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil) {
      guard let vc = self.containerViewController else
      {
         completionBlock?()
         return
      }
      if vc.popupContentViewController == nil {
         completionBlock?()
         return
      }
      if self.popupPresentationState == .closed {
         completionBlock?()
         return
      }
      if self.popupPresentationState == .open {
         
         self.popupPresentationState = .closing
         self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: .open)
         self.delegate?.popupController?(self, willClose: vc.popupContentViewController)

         self.disableInteractiveTransitioning = true
         vc.popupContentViewController.dismiss(animated: animated) {
            self.popupPresentationState = .closed
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: .closing)
            self.disableInteractiveTransitioning = false
            self.delegate?.popupController?(self, didClose: vc.popupContentViewController)
            if vc.popupContentViewController.view is UIScrollView {
               let scrollView = vc.popupContentViewController.view as! UIScrollView
               self.popupDismissalInteractiveController.contentOffset = scrollView.contentOffset
            }
            completionBlock?()
         }
         //}
      }
   }
   
   // MARK: - Frames
   
   internal func popupBarViewFrameForPopupStateHidden() -> CGRect {
      let vc = self.containerViewController!
      
      var frame = self.popupBarViewFrameForPopupStateClosed()

      frame.origin.y += vc.popupBar.popupBarHeight
      frame.size.height = 0.0
      
      PBLog("\(frame)")
      return frame
   }

   internal func popupBarViewFrameForPopupStateClosed() -> CGRect {
      let vc = self.containerViewController!
      
      let defaultFrame = vc.defaultFrameForBottomBar()
      
      let insets = vc.insetsForBottomBar()
      
      var height = vc.popupBar.popupBarHeight
      
      // Unsafe Area
      if self.bottomBarHeight == 0.0 {
         height += insets.bottom
      }
      //

      let frame = CGRect(x: 0.0, y: defaultFrame.origin.y - vc.popupBar.popupBarHeight - insets.bottom, width: vc.view.bounds.width, height: height)
      
      PBLog("\(frame)")
      return frame
   }
}

// MARK: - Custom Animations delegate

extension PBPopupController: UIViewControllerTransitioningDelegate {
   
   /**
    :nodoc:
    */
   public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      
      self.popupPresentationController?.isPresenting = true
      self.popupPresentationController?.popupController = self
      self.popupPresentationController?.popupPresentationStyle = self.containerViewController.popupContentView.popupPresentationStyle
      return self.popupPresentationController
   }
   
   /**
    :nodoc:
    */
   public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      
      self.popupPresentationController?.isPresenting = false
      self.popupPresentationController?.popupController = self
      self.popupPresentationController?.popupPresentationStyle = self.containerViewController.popupContentView.popupPresentationStyle
      return self.popupPresentationController
   }
   
   /**
    :nodoc:
    */
   public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
      
      self.popupPresentationController = PBPopupPresentationController(presentedViewController: presented, presenting: self.containerViewController!)
      return self.popupPresentationController
   }
   
   /**
    :nodoc:
    */
   public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
      
      guard !self.disableInteractiveTransitioning else { return nil }
      return self.popupPresentationInteractiveController
   }
   
   /**
    :nodoc:
    */
   public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
      
      guard !self.disableInteractiveTransitioning else { return nil }
      return self.popupDismissalInteractiveController
   }
}

extension PBPopupController: PBPopupInteractivePresentationDelegate {
   internal func presentInteractive() {
      let vc = self.containerViewController!
      
      vc.popupBar.setHighlighted(true, animated: false)
      vc.present(vc.popupContentViewController, animated: true) {
         vc.popupBar.setHighlighted(false, animated: false)
         if self.popupPresentationState == .opening {
            self.popupPresentationState = .open
            if vc.popupContentViewController.view is UIScrollView {
               let scrollView = vc.popupContentViewController.view as! UIScrollView
               self.popupDismissalInteractiveController.contentOffset = scrollView.contentOffset
            }
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: .opening)
            self.delegate?.popupController?(self, didOpen: vc.popupContentViewController)
         }
      }
   }
   
   internal func dismissInteractive() {
      let vc = self.containerViewController!
      vc.popupContentViewController.setNeedsStatusBarAppearanceUpdate()
      vc.dismiss(animated: true) {
         if self.popupPresentationState == .closing {
            self.popupPresentationState = .closed
            self.delegate?.popupController?(self, didClose: vc.popupContentViewController)
            if vc.popupContentViewController.view is UIScrollView {
               let scrollView = vc.popupContentViewController.view as! UIScrollView
               self.popupDismissalInteractiveController.contentOffset = scrollView.contentOffset
            }
         }
      }
   }
}

// MARK: - UIViewControllerPreviewingDelegate

extension PBPopupController: UIViewControllerPreviewingDelegate {
   
   /**
    :nodoc:
    */
   public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      if let vc = self.containerViewController {
         if let rv = vc.popupBar.previewingDelegate?.previewingViewControllerFor?(vc.popupBar) {

            // Disable interaction if a preview view controller is about to be presented.
//          forceTouchOverride = true
            vc.popupBar.popupTapGestureRecognizer.isEnabled = false
            self.popupPresentationInteractiveController.gesture.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
//             forceTouchOverride = false
               vc.popupBar.popupTapGestureRecognizer.isEnabled = true
               self.popupPresentationInteractiveController.gesture.isEnabled = true
})
            return rv
         }
      }
      return nil
   }
   
   /**
    :nodoc:
    */
   public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
      if let vc = self.containerViewController {
         vc.popupBar.previewingDelegate?.popupBar?(vc.popupBar, commit: viewControllerToCommit)
      }
   }
}
