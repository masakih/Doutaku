//
//  Person+CoreDataProperties.swift
//  DoutakuApp
//
//  Created by Hori,Masaki on 2018/03/18.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//
//

import Foundation
import CoreData

import Doutaku

extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?
    @NSManaged public var identifier: Int

}

extension Person: EntityProvider {}
