//
//  AlertFactory.swift
//  CheckList
//
//  Created by Владислав on 21.01.2021.
//

import UIKit

final class AlertFactory {
    
    private var alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
    
    @discardableResult
    func withTitle(_ title: String) -> Self {
        alertController.title = title
        return self
    }
    
    @discardableResult
    func withMessage(_ message: String) -> Self {
        alertController.message = message
        return self
    }
    
    @discardableResult
    func addAction(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        alertController.addAction(UIAlertAction(title: title, style: style, handler: handler))
        return self
    }
    
    func create() -> UIAlertController {
        return alertController
    }
    
}
