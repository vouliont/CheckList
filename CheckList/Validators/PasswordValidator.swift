//
//  PasswordValidator.swift
//  CheckList
//
//  Created by Владислав on 20.01.2021.
//

import Foundation

struct PasswordValidator: ValidationProtocol {
    static let minLength = 8
    static let maxLength = 64
    enum ValidationError: Error {
        case tooShort, tooLong
        case notEnoughNumbers
        case notEnoughSmallLetters
        case notEnoughCapitalLetters
    }
    
    private(set) var value: String
    
    func isValid() -> (Bool, error: ValidationError?) {
        if value.count < PasswordValidator.minLength {
            return (false, error: ValidationError.tooShort)
        }
        if value.count > PasswordValidator.maxLength {
            return (false, error: ValidationError.tooLong)
        }
        if !enoughNumbers {
            return (false, error: ValidationError.notEnoughNumbers)
        }
        if !enoughSmallLetters {
            return (false, error: ValidationError.notEnoughSmallLetters)
        }
        if !enoughCapitalLetters {
            return (false, error: ValidationError.notEnoughCapitalLetters)
        }
        return (true, error: nil)
    }
}

extension PasswordValidator {
    private var enoughNumbers: Bool {
        let pattern = "^(?=.*[0-9].*[0-9])"
        return value.range(of: pattern, options: .regularExpression) != nil
    }
    
    private var enoughSmallLetters: Bool {
        let pattern = "^(?=.*[a-z].*[a-z].*[a-z])"
        return value.range(of: pattern, options: .regularExpression) != nil
    }
    
    private var enoughCapitalLetters: Bool {
        let pattern = "^(?=.*[A-Z].*[A-Z].*[A-Z])"
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}
