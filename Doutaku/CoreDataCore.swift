//
//  CoreDataCore.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2017/02/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

public struct CoreDataConfiguration {
    
    let modelName: String
    let fileName: String
    let options: [AnyHashable: Any]
    let type: String
    
    // try remake data file, if model file modified.
    let tryRemakeStoreFile: Bool
    
    public static let defaultOptions: [AnyHashable: Any] = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    
    public init(_ modelName: String,
                fileName: String? = nil,
                options: [AnyHashable: Any] = defaultOptions,
                type: String = NSSQLiteStoreType,
                tryRemakeStoreFile: Bool = false) {
        
        self.modelName = modelName
        self.fileName = fileName ?? "\(modelName).storedata"
        self.options = options
        self.type = type
        self.tryRemakeStoreFile = tryRemakeStoreFile
    }
}

public struct CoreDataCore {
    
    let writerContext: NSManagedObjectContext
    let readerContext: NSManagedObjectContext
    private let model: NSManagedObjectModel
    private let coordinator: NSPersistentStoreCoordinator
    
    public init(_ config: CoreDataConfiguration) {
        
        do {
            
            (model, coordinator, writerContext) = try MOCGenerator(config).genarate()
            
            readerContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            readerContext.parent = writerContext
            readerContext.undoManager = nil
            
        } catch {
            
            NSApplication.shared.presentError(error)
            fatalError("CoreDataCore: can not initialize. \(error)")
        }
    }
    
    func editorContext() -> NSManagedObjectContext {
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = readerContext
        moc.undoManager = nil
        
        return moc
    }
}