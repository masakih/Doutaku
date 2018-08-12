//
//  AppDelegate.swift
//  DoutakuApp
//
//  Created by Hori,Masaki on 2018/03/18.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet private weak var window: NSWindow!
    @IBOutlet private weak var nameField: NSTextField!
    @IBOutlet private var personController: NSArrayController!
    
    @objc private let managedObjectContext = Model.default.context
    
    @IBAction private func add(_: Any) {
        
        let name = nameField.stringValue
        nameField.stringValue = ""
        
        let model = Model.oneTimeEditor()
        defer { model.save() }
        
        model.sync {
            let person = model.insertNewObject(for: Person.self)
            
            person?.name = name
            person?.identifier = model.nextIdentifier()
        }
    }
    
    @IBAction private func remove(_: Any) {
        
        guard let selections = personController.selectedObjects as? [Person] else { return }
        
        let currentIndex = personController.selectionIndex
        
        let model = Model.oneTimeEditor()
        defer { model.save() }
        
        model.sync {
            selections
                .compactMap(model.exchange)
                .forEach(model.delete)
        }
        
        personController.setSelectionIndex(currentIndex - 1)
    }
}
