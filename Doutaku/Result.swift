//
//  Result.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2018/06/27.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

internal enum Result<Value> {
    
    case value(Value)
    
    case error(Error)
}

extension Result {
    
    init(_ f: () throws -> Value) {
        
        do {
            self = .value(try f())
            
        } catch {
            
            self = .error(error)
        }
    }
    
    func recover(_ f: (Result) -> Result) -> Result {
        
        switch self {
            
        case .value: return self
            
        case .error: return f(self)
        }
    }
}
