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
    
    let tryRemakeStoreFile: Bool
    
    public static let defaultOptions: [AnyHashable: Any] = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    
    /// イニシャライザ
    ///
    /// - Parameters:
    ///   - modelName: モデルファイルの名前
    ///   - fileName: データストアファイルのファイル名。nilの時はモデルファイル名に.storedataを付加したものとなる。
    ///   - options: NSPersistentStoreCoordinatorに対するオプション。デフォルトはdefaultOptions。
    ///   - type: NSPersistentStoreCoordinatorのストアタイプ。デフォルトはNSSQLiteStoreType。
    ///   - tryRemakeStoreFile: モデルファイルが変更されていてマイグレーションに失敗した場合、現在のデータストアファイルを削除して作成し直すかどうか。trueなら作成し直す。デフォルトはfalse。
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

/// 三層式NSManagedObjectContextなどを保持する中枢的struct
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
