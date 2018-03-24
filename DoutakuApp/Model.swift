//
//  Model.swift
//  DoutakuApp
//
//  Created by Hori,Masaki on 2018/03/18.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Doutaku

struct Model: CoreDataManager {
    
    static let core = CoreDataCore(CoreDataConfiguration("Model"))
    
    static let `default` = Model(type: .reader)
    
    let context: NSManagedObjectContext
    
    init(type: CoreDataManagerType) {
        
        context = Model.context(for: type)
    }
}

extension Model {
    
    func nextIdentifier() -> Int {
                
        return sync {
            
            let sortDesc = NSSortDescriptor(key: #keyPath(Person.identifier), ascending: false)
            let persons = try? objects(of: Person.entity, sortDescriptors: [sortDesc])
            
            return (persons?.first?.identifier ?? 0) + 1
        }
    }
}
