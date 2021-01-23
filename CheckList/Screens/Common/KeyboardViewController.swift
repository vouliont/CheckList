//
//  KeyboardViewController.swift
//  CheckList
//
//  Created by Владислав on 20.01.2021.
//

import UIKit

class KeyboardViewController: UIViewController {
    
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillToggle(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillToggle(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillToggle(_ notification: Notification) {
        guard let keyboardBounds = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let screenHeight = UIScreen.main.bounds.height
        let keyboardHeight = keyboardBounds.origin.y >= screenHeight ? 0 : keyboardBounds.height
        let duration: TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        UIView.animate(withDuration: duration) {
            self.keyboardHeightConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }

}
