//
//  SortDescriptors.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2018/03/25.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

private func convertComparator<Value>(_ original: @escaping (Value, Value) -> ComparisonResult) -> (Any, Any) -> ComparisonResult {
    
    return { lhs, rhs in
        
        guard let lhs = lhs as? Value else { return .orderedDescending }
        guard let rhs = rhs as? Value else { return .orderedAscending }
        
        return original(lhs, rhs)
    }
}

public struct SortDescriptors {
    
    internal private(set) var sortDescriptors: [NSSortDescriptor]
    
    public init<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool) {
        
        self.sortDescriptors = [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
    }
    
    public init<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool, comparator: @escaping (Value, Value) -> ComparisonResult) {
        
        self.sortDescriptors = [NSSortDescriptor(keyPath: keyPath, ascending: ascending, comparator: convertComparator(comparator))]
    }
    
    public mutating func append<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool) {
        
        self.sortDescriptors += [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
    }
    
    public mutating func append<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool, comparator: @escaping (Value, Value) -> ComparisonResult) {
        
        self.sortDescriptors += [NSSortDescriptor(keyPath: keyPath, ascending: ascending, comparator: convertComparator(comparator))]
    }
    
    public mutating func push<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool) {
        
        self.sortDescriptors = [NSSortDescriptor(keyPath: keyPath, ascending: ascending)] + self.sortDescriptors
    }
    
    public mutating func push<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool, comparator: @escaping (Value, Value) -> ComparisonResult) {
        
        self.sortDescriptors = [NSSortDescriptor(keyPath: keyPath, ascending: ascending, comparator: convertComparator(comparator))] + self.sortDescriptors
    }
    
    public func appended<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool) -> SortDescriptors {
        
        var result = self
        
        result.append(keyPath: keyPath, ascending: ascending)
        
        return result
    }
    
    public func appended<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool, comparator: @escaping (Value, Value) -> ComparisonResult) -> SortDescriptors {
        
        var result = self
        
        result.append(keyPath: keyPath, ascending: ascending, comparator: comparator)
        
        return result
    }
    
    public func pushed<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool) -> SortDescriptors {
        
        var result = self
        
        result.push(keyPath: keyPath, ascending: ascending)
        
        return result
    }
    
    public func pushed<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool, comparator: @escaping (Value, Value) -> ComparisonResult) -> SortDescriptors {
        
        var result = self
        
        result.push(keyPath: keyPath, ascending: ascending, comparator: comparator)
        
        return result
    }
    
    public func union(_ other: SortDescriptors) -> SortDescriptors {
        
        var new = self
        new.sortDescriptors += other.sortDescriptors
        
        return new
    }
}

extension SortDescriptors: Equatable {
    
    public static func == (lhs: SortDescriptors, rhs: SortDescriptors) -> Bool {
        
        return lhs.sortDescriptors == rhs.sortDescriptors
    }
    
    public static func == (lhs: [NSSortDescriptor], rhs: SortDescriptors) -> Bool {
        
        return lhs == rhs.sortDescriptors
    }
    
    public static func == (lhs: SortDescriptors, rhs: [NSSortDescriptor]) -> Bool {
        
        return lhs.sortDescriptors == rhs
    }
}

extension Array {
    
    public func sorted(using sortDescriptors: SortDescriptors) -> Array {
        
        let array = self as NSArray
        
        // swiftlint:disable:next force_cast
        return array.sortedArray(using: sortDescriptors.sortDescriptors) as! Array
    }
}
