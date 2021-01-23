//
//  ValidationProtocol.swift
//  CheckList
//
//  Created by Владислав on 20.01.2021.
//

import Foundation

protocol ValidationProtocol {
    associatedtype V
    associatedtype E: Error
    
    var value: V { get }
    func isValid() -> (Bool, error: E?)
}
