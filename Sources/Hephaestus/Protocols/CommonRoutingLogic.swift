
import Foundation
import UIKit

protocol CommonRoutingLogic: AnyObject {
    var modalControllersQueue: Queue<UIViewController> { get set }
    func presentModallyNext(controller: UIViewController?, from viewController: UIViewController?)
}

extension CommonRoutingLogic {
    func presentModallyNext(controller: UIViewController?, from viewController: UIViewController?) {

        if let controller = controller  {
            modalControllersQueue.push(controller)
        }
        if let controller = modalControllersQueue.pop() {
            UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
        }
    }
}
