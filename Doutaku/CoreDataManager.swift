//
//  CoreDataManager.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2017/02/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

public enum CoreDataManagerType {
    
    case reader
    case editor
}

public enum CoreDataError: Error {
    
    case saveLocationIsUnuseable
    case couldNotCreateModel
    case couldNotCreateCoordinator(String)
    case couldNotSave(String)
}


/// CoreDataにかかるオブジェクトを保持すべきプロトコル
public protocol CoreDataProvider {
    
    init(type: CoreDataManagerType)
    
    static var core: CoreDataCore { get }
    
    /// use for ONLY CocoaBindings
    var context: NSManagedObjectContext { get }
    
    func save(errorHandler: @escaping (Error) -> Void)
}

/// CoreDataに対するアクセス手段を提供するプロトコル
public protocol CoreDataAccessor: CoreDataProvider {
    
    func sync(execute: () -> Void)
    func sync<T>(execute: () -> T) -> T
    func async(execute: @escaping () -> Void)
    
    func insertNewObject<T>(for entity: Entity<T>) -> T?
    func delete(_ object: NSManagedObject)
    func object<T>(of entity: Entity<T>, with objectId: NSManagedObjectID) -> T?
    func objects<T>(of entity: Entity<T>, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?) throws -> [T]
    
    /// NSManagedObectを自身が管理するNSManagedObjectに変換する
    ///
    /// - Parameter object: 変換するNSManagedObject
    /// - Returns: 自身が管理するNSManagedObject。自身の管理下に該当オブジェクトがなければnilを返す。
    func exchange<T: NSManagedObject>(_ object: T) -> T?
}

///
public protocol CoreDataManager: CoreDataAccessor {
    
    static var `default`: Self { get }
    
    static func oneTimeEditor() -> Self
}

public func presentOnMainThread(_ error: Error) {
    
    if Thread.isMainThread {
        
        NSApp.presentError(error)
        
    } else {
        
        DispatchQueue.main.sync {
            
            _ = NSApp.presentError(error)
        }
    }
}

// MARK: - Extension
public extension CoreDataProvider {
    
    static func context(for type: CoreDataManagerType) -> NSManagedObjectContext {
        
        switch type {
        case .reader: return core.readerContext
            
        case .editor: return core.editorContext()
        }
    }
    
    func save(errorHandler: @escaping (Error) -> Void = presentOnMainThread) {
        
        // parentを辿ってsaveしていく
        func propagateSaveAsync(_ context: NSManagedObjectContext) {
            
            guard let parent = context.parent else {
                
                return
            }
            
            parent.perform {
                
                do {
                    
                    try parent.save()
                    
                    propagateSaveAsync(parent)
                    
                } catch {
                    
                    errorHandler(error)
                }
            }
        }
        
        context.performAndWait {
            
            guard context.commitEditing() else {
                
                errorHandler(CoreDataError.couldNotSave("Unable to commit editing before saveing"))
                return
            }
            
            do {
                
                try context.save()
                
                // save reader and writer context async.
                // non throw exceptions.
                propagateSaveAsync(context)
                
            } catch let error as NSError {
                
                errorHandler(CoreDataError.couldNotSave(error.localizedDescription))
            }
        }
    }
}

public extension CoreDataAccessor {
    
    func sync(execute work: () -> Void) {
        
        self.context.performAndWait(work)
    }
    
    func sync<T>(execute work: () -> T) -> T {
        
        var value: T!
        sync {
            value = work()
        }
        return value
    }
    
    func async(execute work: @escaping () -> Void) {
        
        self.context.perform(work)
    }
    
    func insertNewObject<T>(for entity: Entity<T>) -> T? {
        
        return NSEntityDescription.insertNewObject(forEntityName: entity.name, into: context) as? T
    }
    
    func delete(_ object: NSManagedObject) {
        
        context.delete(object)
    }
    
    func object<T>(of entity: Entity<T>, with objectId: NSManagedObjectID) -> T? {
        
        return context.object(with: objectId) as? T
    }
    
    func objects<T>(of entity: Entity<T>, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) throws -> [T] {
        
        let req = NSFetchRequest<T>(entityName: entity.name)
        req.sortDescriptors = sortDescriptors
        req.predicate = predicate
        
        var result: [T]?
        var caughtError: Error?
        sync {
            do {
                
                result = try self.context.fetch(req)
            } catch {
                
                caughtError = error
            }
        }
        if let error = caughtError {
            
            throw error
        }
        
        return result ?? []
    }
    
    func exchange<T: NSManagedObject>(_ obj: T) -> T? {
        
        var result: NSManagedObject?
        sync {
            result = self.context.object(with: obj.objectID)
        }
        return result as? T
    }
}

public extension CoreDataManager {
    
    static func oneTimeEditor() -> Self {
        
        return Self.init(type: .editor)
    }
}
