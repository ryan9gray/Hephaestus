
import Foundation
import UIKit

protocol CommonPresentationLogic {
    
    var displayModule: CommonDisplayLogic? { get }

    func showPreloader()
    func hidePreloader()
    func presentError(error: Error, completion: (() -> Void)?)
    func present(errorString: String, completion: (() -> Void)?)
    func present(errorString: String, cancelTitle: String, completion: (() -> Void)?)
    func present(title: String, actions: [UIAlertAction], completion: (() -> Void)?)
    func presentDestructiveAlert(text: String, destructiveButtonTitle: String, handler: ((Bool) -> Swift.Void)?)
}

extension CommonPresentationLogic {
    //
    func showPreloader() {
        displayModule?.showPreloader()
    }
    
    func hidePreloader() {
        displayModule?.hidePreloader()
    }

    func presentError(error: Error, completion: (() -> Void)? = nil) {
        displayModule?.presentError(error, completion: completion)
    }
    
    func present(errorString: String, completion: (() -> Void)? = nil) {
        displayModule?.present(errorString: errorString, completion: completion)
    }
    
    func present(errorString: String, cancelTitle: String, completion: (() -> Void)? = nil) {
        displayModule?.present(errorString: errorString, cancelTitle: cancelTitle, completion: completion)
    }
    
    func present(title: String, actions: [UIAlertAction], completion: (() -> Void)?) {
        displayModule?.present(title: title, actions: actions, completion: completion)
    }
    
    func present(title: String, text: String, actions: [UIAlertAction], completion: (() -> Void)?) {
        displayModule?.present(title: title, text: text, actions: actions, completion: completion)
    }
    func presentDestructiveAlert(text: String, destructiveButtonTitle: String, handler: ((Bool) -> Swift.Void)? = nil) {
        displayModule?.showAlert(text: text, destructiveButtonTitle: destructiveButtonTitle, handler: handler)
    }
}
