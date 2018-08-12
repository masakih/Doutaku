//
//  Entity.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2017/03/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import CoreData

/// CoreData EntityのEntity名とClassを紐づけるprotocol
public protocol Entity where Self: NSManagedObject {
    
    static var entityName: String { get }
}

/// クラス名と同じEntity名を返す
public extension Entity {
    
    static var entityName: String { return String(describing: self) }
}
