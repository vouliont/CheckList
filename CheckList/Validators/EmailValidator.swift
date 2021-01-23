//
//  EmailValidator.swift
//  CheckList
//
//  Created by Владислав on 20.01.2021.
//

import Foundation

struct EmailValidator: ValidationProtocol {
    private(set) var value: String
    func isValid() -> (Bool, error: Error?) {
        let pattern = "^([a-zA-Z0-9_\\-\\.]+)@([a-zA-Z0-9_\\-\\.]+)\\.([a-zA-Z]{2,5})$"
        let isValid = value.range(of: pattern, options: .regularExpression) != nil
        return (isValid, error: nil)
    }
}
