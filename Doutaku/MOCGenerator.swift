//
//  MOCGenerator.swift
//  Doutaku
//
//  Created by Hori,Masaki on 2017/03/21.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

/// 内部エラー
enum InnerError: Error {
    
    case saveLocationIsUnuseable
    case modelFileNotFound
    case couldNotCreateModel
    case couldNotCreateCoordinator(String)
}

/// 三層式のNSManagedObjectContextを生成する
final class MOCGenerator {
    
    let config: CoreDataConfiguration
    
    init(_ config: CoreDataConfiguration) {
        
        self.config = config
    }
    
    func genarate() throws -> (model: NSManagedObjectModel, coordinator: NSPersistentStoreCoordinator, moc: NSManagedObjectContext) {
        
        let model = try createModel()
        let coordinator = try createCoordinator(model)
        let moc = createContext(coordinator)
        
        return (model, coordinator, moc)
    }
    
    private func removeDataFile() {
        
        ["", "-wal", "-shm"]
            .map { config.fileName + $0 }
            .map(ApplicationDirecrories.support.appendingPathComponent)
            .forEach(removeFile)
    }
    
    private func removeFile(at url: URL) {
        
        do {
            
            try FileManager.default.removeItem(at: url)
            
        } catch {
            
            print("Could not remove file for URL (\(url))")
        }
    }
    
    // MARK: - NSManagedObjectContext and ...
    private func createModel() throws -> NSManagedObjectModel {
        
        guard let modelURL = Bundle.main.url(forResource: config.modelName, withExtension: "momd") else {
            
            throw InnerError.modelFileNotFound
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            
            throw InnerError.couldNotCreateModel
        }
        
        return model
    }
    
    private func isMigrationError(_ error: NSError) -> Bool {
        
        if error.domain != NSCocoaErrorDomain { return false }
        
        return [
            NSPersistentStoreIncompatibleVersionHashError,
            NSMigrationError,
            NSMigrationConstraintViolationError,
            NSMigrationCancelledError,
            NSMigrationMissingSourceModelError,
            NSMigrationMissingMappingModelError,
            NSMigrationManagerSourceStoreError,
            NSMigrationManagerDestinationStoreError,
            NSEntityMigrationPolicyError
        ].contains(error.code)
    }
    
    private func createCoordinator(_ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        
        if !checkDirectory(ApplicationDirecrories.support, create: true) {
            
            throw InnerError.saveLocationIsUnuseable
        }
        
        let r = Result(catching: { try makeCoordinator(model) }).recover { result in
            
            switch result {
                
            case .value: return result
                
            case let .error(error as NSError):
                
                // Data Modelが更新されていたらストアファイルを削除してもう一度
                if config.tryRemakeStoreFile, isMigrationError(error) {
                    
                    removeDataFile()
                    
                    return Result(catching: { try makeCoordinator(model) })
                }
                
                return result
            }
        }
        
        switch r {
            
        case let .value(result): return result
        
        case let .error(error): throw InnerError.couldNotCreateCoordinator(error.localizedDescription)
            
        }
    }
    
    private func makeCoordinator(_ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url = ApplicationDirecrories.support.appendingPathComponent(config.fileName)
        try coordinator.addPersistentStore(ofType: config.type,
                                           configurationName: nil,
                                           at: url,
                                           options: config.options)
        
        return coordinator
    }
    
    private func createContext(_ coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = coordinator
        moc.undoManager = nil
        
        return moc
    }
}
