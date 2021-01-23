//
//  RegistrationViewController.swift
//  CheckList
//
//  Created by Владислав on 21.01.2021.
//

import UIKit
import Firebase
import FirebaseAuth

final class RegistrationViewController: KeyboardViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyePasswordButton: UIButton!
    
    private var textFields = LinkedList<UITextField>()
    private var passwordVisible = false {
        didSet {
            guard isViewLoaded else { return }
            passwordTextField.isSecureTextEntry = !passwordVisible
            eyePasswordButton.setImage(passwordVisible ? #imageLiteral(resourceName: "openedEye") : #imageLiteral(resourceName: "closedEye"), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTextFields()
    }
    
    private func setupTextFields() {
        textFields.append(emailTextField)
        textFields.append(passwordTextField)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        passwordTextField.rightView = UIView(frame: eyePasswordButton.bounds)
        passwordTextField.rightViewMode = .always
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func togglePasswordVisibilityAction(_ sender: UIButton) {
        passwordVisible = !passwordVisible
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        let emailValidation = EmailValidator(value: email).isValid()
        if !emailValidation.0 {
            showError("Invalid email")
            return
        }
        let passwordValidation = PasswordValidator(value: password).isValid()
        if !passwordValidation.0 {
            switch passwordValidation.error {
            case .tooShort:
                showError("Password min length is \(PasswordValidator.minLength)")
            case .tooLong:
                showError("Password max length is \(PasswordValidator.maxLength)")
            case .notEnoughNumbers:
                showError("Password must have at least 2 digits")
            case .notEnoughSmallLetters:
                showError("Password must have at least 3 small letters")
            case .notEnoughCapitalLetters:
                showError("Password must have at least 3 capital letters")
            default:
                showError("Something went wrong")
            }
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.dismiss(animated: true)
        }
    }
    
    private func showError(_ error: String) {
        let alertController = AlertFactory()
            .withTitle("Some error happening")
            .withMessage(error)
            .addAction(title: "Ok")
            .create()
        present(alertController, animated: true)
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let node = textFields.node(for: textField), let nextNode = node.next else {
            view.endEditing(true)
            return true
        }
        nextNode.value.becomeFirstResponder()
        return true
    }
}
