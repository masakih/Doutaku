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
            
            let sortDescs = SortDescriptors(keyPath: \Person.identifier, ascending: true)
            let persons = try? objects(of: Person.self, sortDescriptors: sortDescs)
            
            return (persons?.first?.identifier ?? 0) + 1
        }
    }
    
    func person(of name: String) -> Person? {
        
        return sync {
            do {
                
                let p = Predicate(\Person.name, equalTo: name)
                let persons = try objects(of: Person.self, sortDescriptors: nil, predicate: p)
                
                return persons.first
                
            } catch {
                print("Error")
                return nil
            }
        }
    }
}
