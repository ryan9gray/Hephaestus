
import Foundation
import UIKit

protocol ModalPresentable: AnyObject {
    var modallyControllerRoutingLogic: CommonRoutingLogic? { get }
    func displayAlertMessage(withTitle title: String, message: String, actions: [UIAlertAction])
    func presentAlert(with title: String, message: String, actions: [UIAlertAction], completion: (() -> Void)?)
    func present(string: String?, cancelTitle: String, completion: (() -> Void)?)
    func present(error: Error, cancelTitle: String, completion: (() -> Void)?)
    func presentAlert(with title: String, message: String, actions: [UIAlertAction])
    func presentAlert(with title: String?, message: String?, cancelTitle: String?)
    func configureAlert(with title: String, message: String, actions: [UIAlertAction]) -> UIAlertController
}

extension ModalPresentable where Self: UIViewController {
    func displayAlertMessage(withTitle title: String, message: String, actions: [UIAlertAction]) {
        let alertController = configureAlert(with: title, message: message, actions: actions)
        presentAlertModally(alertController: alertController)
    }

    func presentAlert(
        with title: String,
        message: String = "",
        actions: [UIAlertAction] = [],
        completion: (() -> Void)? = nil
    ) {
        let alertController = configureAlert(with: title, message: message, actions: actions)
        present(alertController, animated: true, completion: completion)
    }
    
	func present(string: String?, cancelTitle: String = "close".localized, completion: (() -> Void)? = nil) {
        let okAction = UIAlertAction(title: cancelTitle, style: .default) { _ in
            completion?()
        }
        let alertController = configureAlert(with: "", message: string ?? "", actions: [okAction])
        presentAlertModally(alertController: alertController)
    }
    
	func present(error: Error, cancelTitle: String = "close".localized, completion: (() -> Void)? = nil) {
        if let err = error as? URLError, err.code.rawValue == -1009 {
            return
        }
        present(string: error.localizedDescription, cancelTitle: cancelTitle, completion: completion)
    }
    
    func presentAlert(with title: String, message: String = "", actions: [UIAlertAction] = []) {
        let alertController = configureAlert(with: title, message: message, actions: actions)
        presentAlertModally(alertController: alertController)
    }

    func presentAlert(with title: String? = nil, message: String? = nil, cancelTitle: String? = nil) {
        let okAction = UIAlertAction(title: cancelTitle ?? "Ok", style: .default, handler: nil)
        let alertController = configureAlert(with: title ?? "", message: message ?? "", actions: [okAction])
        presentAlertModally(alertController: alertController)
    }
    
    func configureAlert(with title: String, message: String = "", actions: [UIAlertAction] = []) -> UIAlertController {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        return alertController
    }
    
    func presentAlertModally(alertController: UIViewController?) {
        modallyControllerRoutingLogic?.presentModallyNext(controller: alertController, from: self)
    }
}
