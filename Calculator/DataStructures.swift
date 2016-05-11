//
//  DataStructures.swift
//  Calculator
//
//  Created by Dino Lupo on 06/05/16.
//  Copyright © 2016 Dino Lupo. All rights reserved.
//

import Foundation

struct Stack<Element> {
    var items = [Element]()
    mutating func push(item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
    func isEmpty() -> Bool {
        return items.count == 0
    }
}

class QueueItem<Element> {
    let value: Element!
    var next: QueueItem?
    
    init(_ newValue: Element?) {
        self.value = newValue
    }
    
}


public class Queue<Element> : SequenceType {
    private var head: QueueItem<Element>
    private var tail: QueueItem<Element>
    
    private var count: Int
    
    public init() {
        tail = QueueItem(nil)
        head = tail
        count = 0
        
    }
    
    public func enqueue(value: Element) {
        tail.next = QueueItem(value)
        tail = tail.next!
        count += 1
    }
    
    public func dequeue() -> Element? {
        if let newHead = head.next {
           head = newHead
           count -= 1
           return newHead.value
        } else {
            return nil
        }
        
    }
    
    public func isEmpty() -> Bool {
        return head === tail
    }
    
    public func size() -> Int {
        return count
    }
    
    // implementation of the SequenceType protocol
    public func generate() -> AnyGenerator<Element> {
        var last = head
        var lastIteration = 0
        
        let anyGenerator = AnyGenerator<Element>() {
            guard lastIteration<self.count else {
                return nil
            }
            lastIteration += 1
            let next = last.next?.value
            last = last.next!
            return next
        }
        
        return anyGenerator;

    }
    
}