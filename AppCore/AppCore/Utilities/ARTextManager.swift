/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility class for showing messages above the AR view.
*/

import Foundation
import ARKit

public enum MessageType {
	case trackingStateEscalation
	case planeEstimation
	case contentPlacement
	case focusSquare
}

public extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "TRACKING LIMITED\nToo much camera movement"
            case .insufficientFeatures:
                return "TRACKING LIMITED\nNot enough surface detail"
            case .initializing:
                return "Initializing AR Session"
            case .relocalizing:
                return "Relocalizing AR Session"
            @unknown default:
                fatalError()
            }
        }
    }
}

// MARK: - Delegate

public protocol ARTextManagerDelegate: AnyObject {
    func textManager(didChangeText changedText : String)
    func textManager(shouldHideText hide : Bool)
    func textManager(shouldHidePanel hide : Bool)
}

public class ARTextManager {
    
    public weak var delegate: ARTextManagerDelegate?
    
    // MARK: - Properties
    
    private var viewController: UIViewController!
    
    // Timer for hiding messages
    private var messageHideTimer: Timer?
    
    // Timers for showing scheduled messages
    private var focusSquareMessageTimer: Timer?
    private var planeEstimationMessageTimer: Timer?
    private var contentPlacementMessageTimer: Timer?
    
    // Timer for tracking state escalation
    private var trackingStateFeedbackEscalationTimer: Timer?
    
    let blurEffectViewTag = 100
    var schedulingMessagesBlocked = false
    var alertController: UIAlertController?
    
    // MARK: - Initialization
    
	public init(viewController: UIViewController) {
		self.viewController = viewController
	}
    
    // MARK: - Message Handling
	
	public func showMessage(_ text: String, autoHide: Bool = true) {
		DispatchQueue.main.async { [unowned self] () in
			// cancel any previous hide timer
			self.messageHideTimer?.invalidate()
			
			// set text
            self.delegate?.textManager(didChangeText: text)
            
			// make sure status is showing
			self.showHideMessage(hide: false, animated: true)
			
			if autoHide {
				// Compute an appropriate amount of time to display the on screen message.
				// According to https://en.wikipedia.org/wiki/Words_per_minute, adults read
				// about 200 words per minute and the average English word is 5 characters
				// long. So 1000 characters per minute / 60 = 15 characters per second.
				// We limit the duration to a range of 1-10 seconds.
				let charCount = text.count
				let displayDuration: TimeInterval = min(10, Double(charCount) / 15.0 + 1.0)
				self.messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration,
				                                        repeats: false,
				                                        block: { [weak self] ( _ ) in
															self?.showHideMessage(hide: true, animated: true)
				})
			}
		}
	}
    
	public func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
		// Do not schedule a new message if a feedback escalation alert is still on screen.
		guard !schedulingMessagesBlocked else {
			return
		}
		
		var timer: Timer?
		switch messageType {
		case .contentPlacement: timer = contentPlacementMessageTimer
		case .focusSquare: timer = focusSquareMessageTimer
		case .planeEstimation: timer = planeEstimationMessageTimer
		case .trackingStateEscalation: timer = trackingStateFeedbackEscalationTimer
		}
		
		if timer != nil {
			timer!.invalidate()
			timer = nil
		}
		timer = Timer.scheduledTimer(withTimeInterval: seconds,
		                             repeats: false,
		                             block: { [weak self] ( _ ) in
										self?.showMessage(text)
										timer?.invalidate()
										timer = nil
		})
		switch messageType {
		case .contentPlacement: contentPlacementMessageTimer = timer
		case .focusSquare: focusSquareMessageTimer = timer
		case .planeEstimation: planeEstimationMessageTimer = timer
		case .trackingStateEscalation: trackingStateFeedbackEscalationTimer = timer
		}
	}
    
    public func cancelScheduledMessage(forType messageType: MessageType) {
        var timer: Timer?
        switch messageType {
        case .contentPlacement: timer = contentPlacementMessageTimer
        case .focusSquare: timer = focusSquareMessageTimer
        case .planeEstimation: timer = planeEstimationMessageTimer
        case .trackingStateEscalation: timer = trackingStateFeedbackEscalationTimer
        }
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    public func cancelAllScheduledMessages() {
        cancelScheduledMessage(forType: .contentPlacement)
        cancelScheduledMessage(forType: .planeEstimation)
        cancelScheduledMessage(forType: .trackingStateEscalation)
        cancelScheduledMessage(forType: .focusSquare)
    }
    
    // MARK: - ARKit
    
	public func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
		showMessage(trackingState.presentationString, autoHide: autoHide)
	}
	
	public func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
		if self.trackingStateFeedbackEscalationTimer != nil {
			self.trackingStateFeedbackEscalationTimer!.invalidate()
			self.trackingStateFeedbackEscalationTimer = nil
		}
		
		self.trackingStateFeedbackEscalationTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { _ in
			self.trackingStateFeedbackEscalationTimer?.invalidate()
			self.trackingStateFeedbackEscalationTimer = nil
			self.schedulingMessagesBlocked = true
			var title = ""
			var message = ""
			switch trackingState {
			case .notAvailable:
				title = "Tracking status: Not available."
				message = "Tracking status has been unavailable for an extended time. Try resetting the session."
			case .limited(let reason):
				title = "Tracking status: Limited."
				message = "Tracking status has been limited for an extended time. "
				switch reason {
				case .excessiveMotion: message += "Try slowing down your movement, or reset the session."
				case .insufficientFeatures: message += "Try pointing at a flat surface, or reset the session."
                
                case .initializing:
                    message += "Initializing AR Session"
                case .relocalizing:
                    message += "Relocalizing AR Session"
                @unknown default:
                    fatalError()
                }
			case .normal: break
			}
			
			let restartAction = UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
				//self.viewController.restartExperience(self)
				self.schedulingMessagesBlocked = false
			})
			let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
				self.schedulingMessagesBlocked = false
			})
			self.showAlert(title: title, message: message, actions: [restartAction, okAction])
		})
    }
    
    // MARK: - Alert View
    
	public func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
		alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		if let actions = actions {
			for action in actions {
				alertController!.addAction(action)
			}
		} else {
			alertController!.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		}
		DispatchQueue.main.async { [unowned self] () in
			self.viewController.present(self.alertController!, animated: true, completion: nil)
		}
	}
	
	public func dismissPresentedAlert() {
		DispatchQueue.main.async { [unowned self] () in
			self.alertController?.dismiss(animated: true, completion: nil)
		}
	}
	
    // MARK: - Background Blur
	
	public func blurBackground() {
		let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = viewController.view.bounds
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		blurEffectView.tag = blurEffectViewTag
		viewController.view.addSubview(blurEffectView)
	}
	
	public func unblurBackground() {
		for view in viewController.view.subviews {
			if let blurView = view as? UIVisualEffectView, blurView.tag == blurEffectViewTag {
				blurView.removeFromSuperview()
			}
		}
	}
	
	// MARK: - Panel Visibility
    
	private func showHideMessage(hide: Bool, animated: Bool) {
		if !animated {
            self.delegate?.textManager(shouldHideText: hide )
			return
		}
		
		UIView.animate(withDuration: 0.2,
		               delay: 0,
		               options: [.allowUserInteraction, .beginFromCurrentState],
		               animations: { [unowned self] () in
                        self.delegate?.textManager(shouldHideText: hide )
                        self.delegate?.textManager(shouldHidePanel: hide)
		}, completion: nil)
	}

}
