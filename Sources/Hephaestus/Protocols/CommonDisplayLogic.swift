
import Foundation
import UIKit

protocol CommonDisplayLogic: ModalPresentable {

	var activityView: ActivityView? { get set }

    func showPreloader()
    func hidePreloader()
    
    func presentError(_ error: Error, completion: (() -> Void)?)
    func present(errorString: String, completion: (() -> Void)?)
    func present(errorString: String, cancelTitle: String, completion: (() -> Void)?)
    func present(title: String, actions: [UIAlertAction], completion: (() -> Void)?)
    func present(title: String, text: String, actions: [UIAlertAction], completion: (() -> Void)?)
    func showAlert(text: String, destructiveButtonTitle: String, handler: ((Bool) -> Void)?)
    func presentActionSheet(title: String?, message: String?, actions: [UIAlertAction])
}

extension CommonDisplayLogic where Self: UIViewController {

	func showPreloader() {
		activityView?.startAnimating()
	}
	func hidePreloader() {
		activityView?.stopAnimating()
	}

    func presentError(_ error: Error, completion: (() -> Void)? = nil) {
        hidePreloader()
        present(error: error, completion: completion)
    }
    
    func present(errorString: String, completion: (() -> Void)? = nil) {
        hidePreloader()
        present(string: errorString, completion: completion)
    }
    
    func present(errorString: String, cancelTitle: String, completion: (() -> Void)? = nil) {
        hidePreloader()
        present(string: errorString, cancelTitle: cancelTitle, completion: completion)
    }

    func present(title: String, text: String, actions: [UIAlertAction], completion: (() -> Void)?) {
        hidePreloader()
        presentAlert(with: title, message: text, actions: actions, completion: completion)
    }
    
    func showAlert(text: String, destructiveButtonTitle: String, handler: ((Bool) -> Void)?) {
        let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: destructiveButtonTitle, style: .destructive, handler: { (_) in
            if let callback = handler {
                callback(true)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (_) in
            if let callback = handler {
                callback(false)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func presentActionSheet(actions: [UIAlertAction]) {
        presentActionSheet(title: nil, message: nil, actions: actions)
    }

    func presentActionSheet(title: String? = nil, message: String? = nil, actions: [UIAlertAction]) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		alert.modalPresentationStyle = .popover
		actions.forEach(alert.addAction)
		let cancel = UIAlertAction(title: "cancel".localized, style: .cancel)
		alert.addAction(cancel)
		present(alert, animated: true, completion: nil)
	}
}

extension CommonDisplayLogic where Self: UITableViewController {
    
    func showPreloader() {
		activityView?.startAnimating()
        tableView.isScrollEnabled = false
    }
    
    func hidePreloader() {
		activityView?.stopAnimating()
        tableView.isScrollEnabled = true
    }
}
