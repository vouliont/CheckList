//
//  LinkedList.swift
//  CheckList
//
//  Created by Владислав on 21.01.2021.
//

import Foundation

public struct LinkedList<Value: Equatable> {
    private(set) var head: Node<Value>?
    private(set) var tail: Node<Value>?
    
    init() {}
    
    var isEmpty: Bool {
        self.head == nil
    }
    
    var count: Int {
        if head == nil {
            return 0
        }
        var currentNode = self.head
        var nodeCount = 0
        
        while currentNode != nil {
            nodeCount += 1
            currentNode = currentNode!.next
        }
        return nodeCount
    }
    
    @discardableResult
    mutating func push(_ value: Value) -> Node<Value> {
        self.head = Node(value: value, next: self.head)
        if self.tail == nil {
            self.tail = self.head
        }
        
        return self.head!
    }
    
    @discardableResult
    mutating func append(_ value: Value) -> Node<Value> {
        guard !isEmpty else {
            return push(value)
        }
        
        self.tail!.next = Node(value: value)
        self.tail = self.tail!.next
        
        return self.tail!
    }
    
    @discardableResult
    mutating func insert(_ value: Value, at index: Int) -> Node<Value>? {
        if index == 0 {
            push(value)
            return self.head
        }
        
        guard let prevNode = self[index - 1] else {
            return nil
        }
        
        if prevNode === self.tail {
            append(value)
            return self.tail
        }
        
        prevNode.next = Node(value: value, next: prevNode.next)
        return prevNode.next
    }
    
    @discardableResult
    mutating func insert(_ value: Value, after node: Node<Value>) -> Node<Value>? {
        guard exist(node) else {
            return nil
        }
        
        if node === self.tail {
            append(value)
            return self.tail
        }
        
        node.next = Node(value: value, next: node.next)
        return node.next
    }
    
    @discardableResult
    mutating func pop() -> Node<Value>? {
        defer {
            self.head = self.head?.next
            if self.isEmpty {
                self.tail = nil
            }
        }
        return self.head
    }
    
    @discardableResult
    mutating func removeLast() -> Node<Value>? {
        guard !self.isEmpty else {
            return nil
        }
        if head!.next == nil {
            return self.pop()
        }
        
        var prevNode = self.head
        while prevNode!.next !== self.tail {
            prevNode = prevNode!.next
        }
        
        prevNode!.next = nil
        let nodeToBeRemoved = self.tail
        self.tail = prevNode
        return nodeToBeRemoved
    }
    
    @discardableResult
    mutating func remove(after node: Node<Value>) -> Node<Value>? {
        guard exist(node) else {
            return nil
        }
        
        defer {
            if node.next === self.tail {
                self.tail = node
            }
            node.next = node.next?.next
        }
        
        return node.next
    }
    
    func exist(_ node: Node<Value>) -> Bool {
        var currentNode = self.head
        while currentNode != nil && currentNode !== node {
            currentNode = currentNode!.next
        }
        return currentNode === node
    }
    
    func node(for value: Value) -> Node<Value>? {
        var currentNode = self.head
        while currentNode != nil && value != currentNode!.value {
            currentNode = currentNode!.next
        }
        return currentNode
    }
    
    mutating func clear() {
        head = nil
        tail = nil
    }

    subscript(index: Int) -> Node<Value>? {
        guard index >= 0 else { return nil }

        var currentNode = head
        var currentIndex = 0

        while currentNode != nil && currentIndex < index {
            currentNode = currentNode!.next
            currentIndex += 1
        }

        return currentNode
    }
}
