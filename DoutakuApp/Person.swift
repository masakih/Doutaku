//
//  Person.swift
//  DoutakuApp
//
//  Created by Hori,Masaki on 2018/03/18.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//
//

import Doutaku

class Person: NSManagedObject {
    
    @NSManaged public var name: String?
    @NSManaged public var identifier: Int
}

extension Person: EntityProvider {}
