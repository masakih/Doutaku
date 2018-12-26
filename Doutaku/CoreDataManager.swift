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
    
    case couldNotSave(String)
}

/// CoreDataにかかるオブジェクトを保持すべきプロトコル
public protocol CoreDataProvider {
    
    init(type: CoreDataManagerType)
    
    static var core: CoreDataCore { get }
    
    /// use for ONLY CocoaBindings
    var context: NSManagedObjectContext { get }
    
    
    /// 追加編集削除されたデータを保存する
    ///
    /// - Parameter errorHandler: 保存中にエラーが発生された時に呼ばれる
    ///    ErrorはCoreDataError.couldNotSaveあるいはシステムが提供するNSError
    func save(errorHandler: @escaping (Error) -> Void)
}

/// CoreDataに対するアクセス手段を提供するプロトコル
public protocol CoreDataAccessor: CoreDataProvider {
    
    /// NSManagedObjectContextが提供するスレッド上でexcuteを実行する
    func sync<T>(execute: () -> T) -> T
    func async(execute: @escaping () -> Void)
    
    /// 新しいNSManagedObjectを作成する
    ///
    /// - Parameter type: クラスを特定するためのEntity type
    /// - Returns: 生成が成功すればそのオブジェクトを、失敗すればnilを返す
    func insertNewObject<ResultType: Entity>(for type: ResultType.Type) -> ResultType?
    
    /// NSManagedObjectを削除する
    ///
    /// - Parameter object: 削除するNSManagedObject
    func delete(_ object: NSManagedObject)
   
    /// NSManagedObjectを取得する
    ///
    /// - Parameters:
    ///   - type: 取得するクラスを特定するためのEnetity type
    ///   - sortDescriptors: 戻り値のソート順。nilを指定した場合の順序は不定。
    ///   - predicate: 取得するオブジェクトを制限するための条件。nilが指定されると全てのオブジェクトを返す。
    /// - Returns: 条件に合致するオブジェクトの配列
    /// - Throws: システムが提供するCoreDataのNSError
    func objects<ResultType: Entity>(of type: ResultType.Type, sortDescriptors: SortDescriptors?, predicate: Predicate?) throws -> [ResultType]
    
    /// URL RepresentationからNSManagedObjectを取り出す
    ///
    /// - Parameters:
    ///   - type: クラスを特定するためのEntity type
    ///   - forURIRepresentation: URL representation
    /// - Returns: URL repretationが示すNSManagedObject
    func object<ResultType: Entity>(of type: ResultType.Type, forURIRepresentation: URL) -> ResultType?
    
    /// NSManagedObectを自身が管理するNSManagedObjectに変換する
    ///
    /// - Parameter object: 変換するNSManagedObject
    /// - Returns: 自身が管理するNSManagedObject。自身の管理下に該当オブジェクトがなければnilを返す。
    func exchange<ResultType: NSManagedObject>(_ object: ResultType) -> ResultType?
}

///
public protocol CoreDataManager: CoreDataAccessor {
    
    /// CoreDataManagerが保持し続けるオブジェクト
    /// 通常はCoreDataManagerType.readerであるオブジェクトを返す
    static var `default`: Self { get }
    
    /// データ編集用のオブジェクト
    ///
    /// - Returns: データ編集用のオブジェクト
    static func oneTimeEditor() -> Self
}

/// メインスレッド上でNSApp.presentError(_:)を実行するデフォルトのエラーハンドラー
///
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
            
            parent.performAndWait {
                
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
    
    func sync<T>(execute work: () -> T) -> T {
        
        var value: T!
        self.context.performAndWait {
            
            value = work()
        }
        
        return value
    }
    
    func async(execute work: @escaping () -> Void) {
        
        self.context.perform(work)
    }
    
    func insertNewObject<ResultType: Entity>(for type: ResultType.Type) -> ResultType? {
        
        return NSEntityDescription.insertNewObject(forEntityName: type.entityName, into: context) as? ResultType
    }
    
    func delete(_ object: NSManagedObject) {
        
        context.delete(object)
    }
    
    func objects<ResultType: Entity>(of type: ResultType.Type, sortDescriptors: SortDescriptors? = nil, predicate: Predicate? = nil) throws -> [ResultType] {
        
        let req = NSFetchRequest<ResultType>(entityName: type.entityName)
        req.sortDescriptors = sortDescriptors?.sortDescriptors
        req.predicate = predicate?.predicate
        
        
        let result: Result<[ResultType], Error> = sync { Result(catching: { try self.context.fetch(req) }) }
        
        switch result {
            
        case let .value(r): return r
            
        case let .error(error): throw error
        }
    }
    
    func object<ResultType: Entity>(of type: ResultType.Type, forURIRepresentation uri: URL) -> ResultType? {
        
        guard let oID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else { return nil }
        
        return sync { self.context.object(with: oID) as? ResultType }
    }
    
    func exchange<ResultType: NSManagedObject>(_ obj: ResultType) -> ResultType? {
        
        return sync { self.context.object(with: obj.objectID) as? ResultType }
    }
}

public extension CoreDataManager {
    
    static func oneTimeEditor() -> Self {
        
        return Self.init(type: .editor)
    }
}
