//
//  Helpers.swift
//  EasyTranslator
//
//  Created by Khawar Shahzad on 10/3/24.
//
import UIKit
import Toast

extension UIApplication {
    
    class func rootViewController() -> UIViewController? {
        UIApplication.shared.keyWindow?.rootViewController
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class Helpers {
}

extension Helpers {
    public static func showToast(message: String?, imageName: String? = nil) {
        if let message = message {
            var image: UIImage?
            if let imageName = imageName {
                image = UIImage(named: imageName)
            }
            UIApplication.rootViewController()?.view.makeToast(message,
                                                               duration: 3.0,
                                                               position: .bottom,
                                                               image: image)
        }
    }
}

extension String {
    func containsOnlyWhiteSpaces() -> Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
