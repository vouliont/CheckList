//
//  Node.swift
//  CheckList
//
//  Created by Владислав on 21.01.2021.
//

import Foundation

class Node<Value> {
    var value: Value
    var next: Node<Value>?
    
    init(value: Value, next: Node<Value>? = nil) {
        self.value = value
        self.next = next
    }
}
