
import Foundation
import UIKit

final class ScrollViewInsetKeyboardBehavior {
    var defaultInsets: UIEdgeInsets = .zero
    var scrollView: UIScrollView {
        didSet {
            defaultInsets = scrollView.contentInset
            configureScrollView()
        }
    }

    var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .onDrag {
        didSet {
            configureScrollView()
        }
    }

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    func addKeyboardNotifications() {
        configureScrollView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardSizeChanged),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc func keyboardSizeChanged(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
            return
        }

        let frameInView = scrollView.convert(frame, from: nil)
        let bottomInset = max(scrollView.bounds.maxY - frameInView.minY, 0)

        var insets: UIEdgeInsets = defaultInsets
        insets.bottom = max(insets.bottom, bottomInset)

        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    private func configureScrollView() {
        scrollView.keyboardDismissMode = keyboardDismissMode
    }
}
