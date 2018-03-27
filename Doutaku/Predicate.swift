//
//  Predicate.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2018/03/25.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

public struct Predicate {
    
    internal let predicate: NSPredicate
    
    internal init(predicate: NSPredicate) {
        
        self.predicate = predicate
    }
    
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, type: NSComparisonPredicate.Operator, value: Value, options: NSComparisonPredicate.Options = []) {
        
        let left = NSExpression(forKeyPath: keyPath)
        let right = NSExpression(forConstantValue: value)
        
        self.predicate = NSComparisonPredicate(leftExpression: left,
                                               rightExpression: right,
                                               modifier: .direct,
                                               type: type,
                                               options: options)
    }
    
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, lessThan: Value) {
        
        self.init(keyPath, type: .lessThan, value: lessThan)
    }
    
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, lessThanOrEqualTo: Value) {
        
        self.init(keyPath, type: .lessThanOrEqualTo, value: lessThanOrEqualTo)
    }
    
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, greaterThan: Value) {
        
        self.init(keyPath, type: .greaterThan, value: greaterThan)
    }
    
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, greaterThanOrEqualTo: Value) {
        
        self.init(keyPath, type: .greaterThanOrEqualTo, value: greaterThanOrEqualTo)
    }
    
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, equalTo: Value, options: NSComparisonPredicate.Options = []) {
        
        self.init(keyPath, type: .equalTo, value: equalTo, options: options)
    }
    
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, notEqualTo: Value, options: NSComparisonPredicate.Options = []) {
        
        self.init(keyPath, type: .notEqualTo, value: notEqualTo, options: options)
    }
    
    ///
    public init<Root: NSObject>(_ keyPath: KeyPath<Root, String>, matches: String, options: NSComparisonPredicate.Options = []) {
        
        self.init(keyPath, type: .matches, value: matches, options: options)
    }
    
    public init<Root: NSObject>(_ keyPath: KeyPath<Root, String>, like: String, options: NSComparisonPredicate.Options = []) {
        
        self.init(keyPath, type: .like, value: like, options: options)
    }
    
    public init<Root: NSObject>(_ keyPath: KeyPath<Root, String>, beginsWith: String, options: NSComparisonPredicate.Options = []) {
        
        self.init(keyPath, type: .beginsWith, value: beginsWith, options: options)
    }
    
    public init<Root: NSObject>(_ keyPath: KeyPath<Root, String>, endsWith: String, options: NSComparisonPredicate.Options = []) {
        
        self.init(keyPath, type: .endsWith, value: endsWith, options: options)
    }
    
    public init<Root: NSObject>(_ keyPath: KeyPath<Root, String>, contains: String, options: NSComparisonPredicate.Options = []) {
        
        self.init(keyPath, type: .contains, value: contains, options: options)
    }
    
    ///
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, `in` values: [Value], options: NSComparisonPredicate.Options = []) {
        
        let left = NSExpression(forKeyPath: keyPath)
        let right = NSExpression(forAggregate: values.map(NSExpression.init(forConstantValue:)))
        
        self.predicate = NSComparisonPredicate(leftExpression: left,
                                               rightExpression: right,
                                               modifier: .direct,
                                               type: .in)
    }
    
    public init<Root: NSObject, Value>(_ keyPath: KeyPath<Root, Value>, between left: Value, and right: Value) {
        
        let fitst = Predicate(keyPath, greaterThanOrEqualTo: left)
        let second = Predicate(keyPath, lessThanOrEqualTo: right)
        
        self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fitst.predicate, second.predicate])
    }
    
    ///
    public init<Root, Value>(isNil keyPath: KeyPath<Root, Value>) {
        
        let left = NSExpression(forKeyPath: keyPath)
        let right = NSExpression(forConstantValue: nil)
        
        self.predicate = NSComparisonPredicate(leftExpression: left,
                                               rightExpression: right,
                                               modifier: .direct,
                                               type: .equalTo)
    }
    
    public init<Root, Value>(isNotNil keyPath: KeyPath<Root, Value>) {
        
        let left = NSExpression(forKeyPath: keyPath)
        let right = NSExpression(forConstantValue: nil)
        
        self.predicate = NSComparisonPredicate(leftExpression: left,
                                               rightExpression: right,
                                               modifier: .direct,
                                               type: .notEqualTo)
    }
    
    public init<Root, Value>(`true` keyPath: KeyPath<Root, Value>) {
        
        let left = NSExpression(forKeyPath: keyPath)
        let right = NSExpression(forConstantValue: true)
        
        self.predicate = NSComparisonPredicate(leftExpression: left,
                                               rightExpression: right,
                                               modifier: .direct,
                                               type: .equalTo)
    }
    
    public init<Root, Value>(`false` keyPath: KeyPath<Root, Value>) {
        
        let left = NSExpression(forKeyPath: keyPath)
        let right = NSExpression(forConstantValue: true)
        
        self.predicate = NSComparisonPredicate(leftExpression: left,
                                               rightExpression: right,
                                               modifier: .direct,
                                               type: .notEqualTo)
    }
    
}

extension Predicate {
    
    public func and(_ other: Predicate) -> Predicate {
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate, other.predicate])
        
        return Predicate(predicate: predicate)
    }
    
    public func or(_ other: Predicate) -> Predicate {
        
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [self.predicate, other.predicate])
        
        return Predicate(predicate: predicate)
    }
    
    public func negate() -> Predicate {
        
        let predicate = NSCompoundPredicate(notPredicateWithSubpredicate: self.predicate)
        
        return Predicate(predicate: predicate)
    }
}

extension Predicate: Equatable {
    
    public static func == (lhs: Predicate, rhs: Predicate) -> Bool {
        
        return lhs.predicate == rhs.predicate
    }
    
    public static func == (lhs: Predicate, rhs: NSPredicate) -> Bool {
        
        return lhs.predicate == rhs
    }
    
    public static func == (lhs: NSPredicate, rhs: Predicate) -> Bool {
        
        return lhs == rhs.predicate
    }
}

extension Predicate {
    
    public func evaluate(with object: NSObject?) -> Bool {
        
        return predicate.evaluate(with: object)
    }
}

extension Predicate: CustomStringConvertible {
    
    public var description: String {
        
        return predicate.description
    }
}

extension Array where Element: NSObject {
    
    public func filtered(using predicate: Predicate) -> Array {
        
        return self.filter(predicate.evaluate)
    }
}
