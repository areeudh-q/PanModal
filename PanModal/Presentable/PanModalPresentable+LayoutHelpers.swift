//
//  PanModalPresentable+LayoutHelpers.swift
//  PanModal
//
//  Copyright © 2018 Tiny Speck, Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/**
 ⚠️ [Internal Only] ⚠️
 Helper extensions that handle layout in the PanModalPresentationController
 */
extension PanModalPresentable where Self: UIViewController {

    /**
     Cast the presentation controller to PanModalPresentationController
     so we can access PanModalPresentationController properties and methods
     */
    var presentedVC: PanModalPresentationController? {
        presentationController as? PanModalPresentationController
    }
  
    /**
     Length of the top layout guide of the presenting view controller.
     Gives us the safe area inset from the top.
     */
    var leadingLayoutOffset: CGFloat {
        guard let rootVC: UIViewController = rootViewController else {
            return 0
        }
        if #available(iOS 11.0, *) {
            return rootVC.view.safeAreaInsets.left
        }
        return 16.0
    }

    /**
     Length of the top layout guide of the presenting view controller.
     Gives us the safe area inset from the top.
     */
    var topLayoutOffset: CGFloat {
        guard let rootVC: UIViewController = rootViewController else {
            return 0
        }
        if #available(iOS 11.0, *) {
            return rootVC.view.safeAreaInsets.top
        }
        return rootVC.topLayoutGuide.length
    }

    /**
     Length of the bottom layout guide of the presenting view controller.
     Gives us the safe area inset from the bottom.
     */
    var bottomLayoutOffset: CGFloat {
        guard let rootVC = rootViewController else {
            return 0
        }
        if #available(iOS 11.0, *) {
            return rootVC.view.safeAreaInsets.bottom
        }
        return rootVC.bottomLayoutGuide.length
    }

    /**
     Returns the short form Y position

     - Note: If voiceover is on, the `longFormYPos` is returned.
     We do not support short form when voiceover is on as it would make it difficult for user to navigate.
     */
    var shortFormPosition: CGFloat {
        guard !UIAccessibility.isVoiceOverRunning else {
            return longFormPosition
        }
        if self.orientation == .vertical {
            let shortFormPosition = topMargin(from: shortForm) + verticalOffset
            // shortForm shouldn't exceed longForm
            return max(shortFormPosition, longFormPosition)
        }
        let shortFormPosition = trailingMargin(from: shortForm) + horizontalOffset
        // shortForm shouldn't exceed longForm
        return max(shortFormPosition, longFormPosition)
    }

    /**
     Returns the long form Y position

     - Note: We cap this value to the max possible height
     to ensure content is not rendered outside of the view bounds
     */
    var longFormPosition: CGFloat {
      if self.orientation == .vertical {
          return max(topMargin(from: longForm), topMargin(from: .maxHeight)) + verticalOffset
      }
      return max(trailingMargin(from: longForm), trailingMargin(from: .maxHeight)) + horizontalOffset
    }

    /**
     Use the container view for relative positioning as this view's frame
     is adjusted in PanModalPresentationController
     */
    var bottomYPos: CGFloat {
        guard let container = presentedVC?.containerView else {
            return view.bounds.height
        }
        return container.bounds.size.height - verticalOffset
    }
  
    /**
     Use the container view for relative positioning as this view's frame
     is adjusted in PanModalPresentationController
     */
    var bottomXPos: CGFloat {
        guard let container = presentedVC?.containerView else {
            return view.bounds.width
        }
        return container.bounds.size.width - verticalOffset
    }

    /**
     Converts a given pan modal height value into a y position value
     calculated from top of view
     */
    func topMargin(from: PanModalHeight) -> CGFloat {
        switch from {
        case .maxHeight:
            return 0.0
        case .maxHeightWithTopInset(let inset):
            return inset
        case .contentHeight(let height):
            return bottomYPos - (height + bottomLayoutOffset)
        case .contentHeightIgnoringSafeArea(let height):
            return bottomYPos - height
        case .intrinsicHeight:
            view.layoutIfNeeded()
            let targetSize = CGSize(
                width: (presentedVC?.containerView?.bounds ?? UIScreen.main.bounds).width,
                height: UIView.layoutFittingCompressedSize.height
            )
            let intrinsicHeight = view.systemLayoutSizeFitting(targetSize).height
            return bottomYPos - (intrinsicHeight + bottomLayoutOffset)
        }
    }
  
    func trailingMargin(from: PanModalHeight) -> CGFloat {
        switch from {
        case .maxHeight:
            return 0.0
        case .maxHeightWithTopInset(let inset):
            return inset
        case .contentHeight(let width):
            return bottomXPos - (width + bottomLayoutOffset)
        case .contentHeightIgnoringSafeArea(let width):
            return bottomXPos - width
        case .intrinsicHeight:
            view.layoutIfNeeded()
            let targetSize: CGSize = CGSize(
                width: (presentedVC?.containerView?.bounds ?? UIScreen.main.bounds).width,
                height: UIView.layoutFittingCompressedSize.height
            )
            let intrinsicWidth = view.systemLayoutSizeFitting(targetSize).width
            return bottomXPos - (intrinsicWidth + bottomLayoutOffset)
        }
    }

    private var rootViewController: UIViewController? {
        guard let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication else {
            return nil
        }
        return application.keyWindow?.rootViewController
    }

}
#endif
