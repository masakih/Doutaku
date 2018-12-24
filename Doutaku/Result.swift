//
//  Result.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2018/06/27.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

internal enum Result<Value, Error> {
    
    case value(Value)
    
    case error(Error)
    
    
    func map<NewValue>(_ transform: (Value) -> NewValue) -> Result<NewValue, Error> {
        
        switch self {
            
        case let .value(val): return .value(transform(val))
            
        case let .error(error): return .error(error)
        }
    }
    
    func mapError<NewError>(_ transform: (Error) -> NewError) -> Result<Value, NewError> {
        
        switch self {
            
        case let .value(val): return .value(val)
            
        case let .error(error): return .error(transform(error))
        }
    }
    
    func flatMap<NewValue>(_ transform: (Value) -> Result<NewValue, Error>) -> Result<NewValue, Error> {
        
        switch self {
            
        case let .value(val): return transform(val)
            
        case let .error(error): return .error(error)
        }
    }
    
    func flatMapError<NewError>(_ transform: (Error) -> Result<Value, NewError>) -> Result<Value, NewError> {
        
        switch self {
            
        case let .value(val): return .value(val)
            
        case let .error(error): return transform(error)
        }
    }
}

extension Result where Error: Swift.Error {
    
    func get() throws -> Value {
        
        switch self {
            
        case let .value(val): return val
            
        case let .error(error): throw error
        }
    }
}

extension Result where Error == Swift.Error {
    
    init(catching body: () throws -> Value) {
        
        do {
            self = .value(try body())
            
        } catch {
            
            self = .error(error)
        }
    }
}

extension Result: Equatable where Value: Equatable, Error: Equatable {}
extension Result: Hashable where Value: Hashable, Error: Hashable {}

extension Result {
    
    func recover(_ f: (Result) -> Result) -> Result {
        
        switch self {
            
        case .value: return self
            
        case .error: return f(self)
        }
    }
}
