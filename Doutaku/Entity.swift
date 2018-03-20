//
//  Entity.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2017/03/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import CoreData

public struct Entity<T: NSManagedObject> {
    
    let name: String
}

public protocol EntityProvider {
    
    associatedtype ObjectType: NSManagedObject = Self
    
    static var entityName: String { get }
    static var entity: Entity<ObjectType> { get }
}

public extension EntityProvider {
    
    static var entity: Entity<ObjectType> {
        
        return Entity<ObjectType>(name: entityName)
    }
}

public extension NSManagedObject {
    
    class var entityName: String { return String(describing: self) }
}
