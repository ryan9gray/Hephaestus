
import Foundation
import UIKit

final class BottomConstraintKeyboardBehavior: NSObject {
    private var isKeyboardVisible: Bool = false
    private var yOffset: CGFloat = 0

    weak var sceneView: UIView?
    weak var scrollView: UIScrollView? {
        didSet {
            scrollView?.delegate = self
        }
    }
    weak var bottomConstraint: NSLayoutConstraint?

    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    private func scrollToFocusedField() {
        if let focusedField = sceneView?.currentFirstResponder() as? UIView {
            scrollView?.scrollToSubview(focusedField, animated: false)
        }
    }

    @objc
    func keyboardWillShow(notification: Notification) {
        guard !isKeyboardVisible else { return }

        let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
        let animationDurationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey

        guard
            let info = notification.userInfo,
            let kbFrame: NSValue = info[frameEndUserInfoKey] as? NSValue,
            let animationDuration: TimeInterval = info[animationDurationKey] as? TimeInterval else { return }

        let animationCurveRawNSN = info[curveKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        let keyboardHeight: CGFloat = kbFrame.cgRectValue.size.height

        isKeyboardVisible = true
        bottomConstraint?.constant = -keyboardHeight

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve) { [weak self] in
            self?.sceneView?.layoutIfNeeded()
        }

        if let focusedField = sceneView?.currentFirstResponder() as? UIView {
            scrollView?.scrollToSubview(focusedField, animated: true)
        }
    }

    @objc
    func keyboardWillHide(notification: Notification) {

        let animationDurationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey

        guard
            let info = notification.userInfo,
            let animationDuration: TimeInterval = info[animationDurationKey] as? TimeInterval else { return }

        let animationCurveRawNSN = info[curveKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

        isKeyboardVisible = false
        bottomConstraint?.constant = 0

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve) { [weak self] in
            self?.sceneView?.layoutIfNeeded()
        }
    }
}

extension BottomConstraintKeyboardBehavior: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollingUp: Bool = scrollView.contentOffset.y < yOffset
        yOffset = scrollView.contentOffset.y

        guard
            scrollView.isTracking,
            isScrollingUp
            else { return }

        sceneView?.endEditing(true)
    }
}

fileprivate extension UIScrollView {
    func scrollToSubview(_ subview: UIView, animated: Bool) {
        guard let parentView = subview.superview else { return }
        let maxYOffset: CGFloat = contentSize.height - bounds.height + contentInset.bottom
        var offset: CGPoint = parentView.convert(subview.frame.origin, to: self)

        if offset.y > maxYOffset {
            offset.y = maxYOffset
        }

        setContentOffset(offset, animated: animated)
    }
}

fileprivate extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }

        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }

        return nil
    }
}

