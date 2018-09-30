
import UIKit

let keyboardAnimationDuration: Double = 0.25
let keyboardDefaulthHeight: CGFloat = 300

@objc
public class ToolbarPresenter: NSObject {
    static public let shared = ToolbarPresenter()

    public var height = keyboardDefaulthHeight
    public typealias KeyboardCallback = (KeyboardOptions) -> ()
    public typealias GestureCallback = (CGFloat) -> ()
    private var callbacksKeyboard: [KeyboardEvent : KeyboardCallback] = [:]
    private var callbacksGesture: [GestureEvent : GestureCallback] = [:]
    private var keyboardOptions: KeyboardOptions?
    private var scrollView: UIScrollView? {
        didSet {
            scrollView?.keyboardDismissMode = .interactive
            scrollView?.addGestureRecognizer(panGesture)
        }
    }
    private lazy var panGesture: UIPanGestureRecognizer = { [unowned self] in
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer))
        recognizer.delegate = self
        return recognizer
    }()

    deinit {
        stop()
    }
}

// MARK: - Nested Types
extension ToolbarPresenter {
    public struct KeyboardOptions {
        public let belongsToCurrentApp: Bool
        public let startFrame: CGRect
        public let endFrame: CGRect
        public let curve: UIViewAnimationCurve
        public let duration: Double
    }

    public struct GestureOptions {
        public let height: CGFloat
        public let duration: Double
    }

    public enum KeyboardEvent {
        case willShow
        case didShow
        case willHide
        case didHide
        case willChangeFrame
        case didChangeFrame

        var notification: NSNotification.Name {
            switch self {
            case .willShow:
                return .UIKeyboardWillShow
            case .didShow:
                return .UIKeyboardDidShow
            case .willHide:
                return .UIKeyboardWillHide
            case .didHide:
                return .UIKeyboardDidHide
            case .willChangeFrame:
                return .UIKeyboardWillChangeFrame
            case .didChangeFrame:
                return .UIKeyboardDidChangeFrame
            }
        }

        var selector: Selector {
            switch self {
            case .willShow:
                return #selector(ToolbarPresenter.keyboardWillShow(note:))
            case .didShow:
                return #selector(ToolbarPresenter.keyboardDidShow(note:))
            case .willHide:
                return #selector(ToolbarPresenter.keyboardWillHide(note:))
            case .didHide:
                return #selector(ToolbarPresenter.keyboardDidHide(note:))
            case .willChangeFrame:
                return #selector(ToolbarPresenter.keyboardWillChangeFrame(note:))
            case .didChangeFrame:
                return #selector(ToolbarPresenter.keyboardDidChangeFrame(note:))
            }
        }
    }

    public enum GestureEvent {
        case changed
        case ended
    }
}

// MARK: - Public
extension ToolbarPresenter {
    @discardableResult
    public func on(keyboard: KeyboardEvent, do callback: KeyboardCallback?) -> Self {
        callbacksKeyboard[keyboard] = callback
        return self
    }

    @discardableResult
    public func on(gesture: GestureEvent, do callback: GestureCallback?) -> Self {
        callbacksGesture[gesture] = callback
        return self
    }
    
    public func toolbar(scrollView: UIScrollView) -> Self {
        self.scrollView = scrollView
        return self
    }
    
    public func start() {
        let center = NotificationCenter.`default`
        
        for event in callbacksKeyboard.keys {
            center.addObserver(self, selector: event.selector, name: event.notification, object: nil)
        }
    }
    
    public func stop() {
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    public func clear() {
        callbacksKeyboard.removeAll()
        callbacksGesture.removeAll()
    }
}

// MARK: - Private
extension ToolbarPresenter {
    private func keyboardOptions(fromNotificationDictionary userInfo: [AnyHashable : Any]?) -> KeyboardOptions {
        var currentApp = true
        if #available(iOS 9.0, *) {
            if let value = (userInfo?[UIKeyboardIsLocalUserInfoKey] as? NSNumber)?.boolValue {
                currentApp = value
            }
        }
        var endFrame = CGRect()
        if let value = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            endFrame = value
            if height == keyboardDefaulthHeight {
                height = value.height
            }
        }
        var startFrame = CGRect()
        if let value = (userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            startFrame = value
        }
        var curve = UIViewAnimationCurve.linear
        if let index = (userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue, index < 5,
            let value = UIViewAnimationCurve(rawValue:index) {
            curve = value
        }
        var duration: Double = 0.0
        if let value = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            duration = value
        }
        return KeyboardOptions(belongsToCurrentApp: currentApp, startFrame: startFrame, endFrame: endFrame, curve: curve, duration: duration)
    }
}

// MARK: - UIKit notification handling
extension ToolbarPresenter {
    @objc internal func keyboardWillShow(note: Notification) {
        callbacksKeyboard[.willShow]?(keyboardOptions(fromNotificationDictionary: note.userInfo))
    }
    @objc internal func keyboardDidShow(note: Notification) {
        callbacksKeyboard[.didShow]?(keyboardOptions(fromNotificationDictionary: note.userInfo))
    }
    
    @objc internal func keyboardWillHide(note: Notification) {
        callbacksKeyboard[.willHide]?(keyboardOptions(fromNotificationDictionary: note.userInfo))
    }
    @objc internal func keyboardDidHide(note: Notification) {
        callbacksKeyboard[.didHide]?(keyboardOptions(fromNotificationDictionary: note.userInfo))
    }
    
    @objc internal func keyboardWillChangeFrame(note: Notification) {
        let event = keyboardOptions(fromNotificationDictionary: note.userInfo)
        callbacksKeyboard[.willChangeFrame]?(event)
        keyboardOptions = event
    }
    @objc internal func keyboardDidChangeFrame(note: Notification) {
        let event = keyboardOptions(fromNotificationDictionary: note.userInfo)
        callbacksKeyboard[.didChangeFrame]?(event)
        keyboardOptions = event
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ToolbarPresenter: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return scrollView?.keyboardDismissMode == .interactive
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer === panGesture
    }
}

// MARK: - Handle PanGestureRecognizer
extension ToolbarPresenter {
    @objc func handlePanGestureRecognizer(recognizer: UIPanGestureRecognizer) {
        var useWindowCoordinates = false
        var window: UIWindow?
        var bounds: CGRect = .zero

        let sharedApplicationSelector = NSSelectorFromString("sharedApplication")
        if let applicationClass = NSClassFromString("UIApplication"), applicationClass.responds(to: sharedApplicationSelector) {
            if let application = UIApplication.perform(sharedApplicationSelector).takeUnretainedValue() as? UIApplication, let appWindow = application.windows.first {
                window = appWindow
                bounds = appWindow.bounds
            }
        } else {
            useWindowCoordinates = false
            bounds = UIScreen.main.bounds
        }

        guard let view = recognizer.view else { return }

        let location = recognizer.location(in: view)
        let absoluteLocation = useWindowCoordinates ? view.convert(location, to: window) : view.convert(location, to: UIScreen.main.coordinateSpace)

        switch recognizer.state {
        case .changed:
            guard let options = keyboardOptions else { return }
            var frame = options.endFrame
            frame.origin.y = max(absoluteLocation.y, bounds.height - frame.height)
            let height = bounds.height - frame.origin.y
            callbacksGesture[.changed]?(height)
        case .ended:
            callbacksGesture[.ended]?(0)
        default:
            break
        }
    }
}

extension UIViewAnimationOptions {
    init(curve: UIViewAnimationCurve) {
        switch curve {
        case .easeIn:
            self = [.curveEaseIn]
        case .easeOut:
            self = [.curveEaseOut]
        case .easeInOut:
            self = [.curveEaseInOut]
        case .linear:
            self = [.curveLinear]
        }
    }
}
