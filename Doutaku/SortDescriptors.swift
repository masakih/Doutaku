//
//  SortDescriptors.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2018/03/25.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

public struct SortDescriptors {
    
    public enum Descriptor<Root, Value> {
        
        case ascending(KeyPath<Root, Value>)
        
        case descending(KeyPath<Root, Value>)
        
        case ascendingWithComparator(KeyPath<Root, Value>, Comparator)
        
        case descendingWithComparator(KeyPath<Root, Value>, Comparator)
        
        internal func convert() -> NSSortDescriptor {
            
            switch self {
                
            case let .ascending(keyPath):
                return NSSortDescriptor(keyPath: keyPath, ascending: true)
                
            case let .descending(keyPath):
                return NSSortDescriptor(keyPath: keyPath, ascending: false)
                
            case let .ascendingWithComparator(keyPath, comparator):
                return NSSortDescriptor(keyPath: keyPath, ascending: true, comparator: comparator)
                
            case let .descendingWithComparator(keyPath, comparator):
                return NSSortDescriptor(keyPath: keyPath, ascending: false, comparator: comparator)
                
            }
        }
    }
    
    private(set) var descriptors: [NSSortDescriptor]
    
    public init<Root, Value>(_ descriptor: Descriptor<Root, Value>) {
        
        self.descriptors = [descriptor.convert()]
    }
    
    public mutating func append<Root, Value>(_ descriptor: Descriptor<Root, Value>) {
        
        self.descriptors += [descriptor.convert()]
    }
    
    public mutating func push<Root, Value>(_ descriptor: Descriptor<Root, Value>) {
        
        self.descriptors = [descriptor.convert()] + self.descriptors
    }
    
    public func appened<Root, Value>(_ descriptor: Descriptor<Root, Value>) -> SortDescriptors {
        
        var result = self
        
        result.append(descriptor)
        
        return result
    }
    
    public func pushed<Root, Value>(_ descriptor: Descriptor<Root, Value>) -> SortDescriptors {
        
        var result = self
        
        result.push(descriptor)
        
        return result
    }
}
