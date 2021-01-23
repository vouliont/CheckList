//
//  LoginViewController.swift
//  CheckList
//
//  Created by Владислав on 20.01.2021.
//

import UIKit
import Firebase
import FirebaseAuth

fileprivate enum Segues {
    static let registration = "RegistrationVCSegue"
}

final class LoginViewController: KeyboardViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var textFields = LinkedList<UITextField>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
    }

    @IBAction func logInAction(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty && !password.isEmpty else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showError(error.localizedDescription)
            }
        }
    }
    
    private func setupTextFields() {
        textFields.append(emailTextField)
        textFields.append(passwordTextField)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func showError(_ error: String) {
        let alertController = AlertFactory()
            .withTitle("Some error happening")
            .withMessage(error)
            .addAction(title: "Ok")
            .create()
        present(alertController, animated: true)
    }
    
    // MARK: - Navigations
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.registration {
            segue.destination.isModalInPresentation = true
        }
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let node = textFields.node(for: textField), let nextNode = node.next else {
            view.endEditing(true)
            return true
        }
        nextNode.value.becomeFirstResponder()
        return true
    }
}
