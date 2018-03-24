//
//  DoutakuTests.swift
//  DoutakuTests
//
//  Created by Hori,Masaki on 2018/03/18.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import XCTest
@testable import DoutakuApp


class DoutakuTests: XCTestCase {
    
    let testName = "NameTest"
    let testId = 100_000
    
    override func setUp() {
        super.setUp()
        
        
        let model = Model.oneTimeEditor()
        
        model.sync {
            
            let p = NSPredicate(format: "%K == %@", "name", testName)
            
            do {
                let persons = try model.objects(of: Person.entity, sortDescriptors: nil, predicate: p)
                
                persons.forEach(model.delete)
                
            } catch {
                XCTFail("Caught Exception. \(error)")
            }
        }
        model.save()
    }
    
    override func tearDown() {
        
        let model = Model.oneTimeEditor()
        
        model.sync {
            
            let p = NSPredicate(format: "%K == %@", "name", testName)
            
            do {
                let persons = try model.objects(of: Person.entity, sortDescriptors: nil, predicate: p)
                
                persons.forEach(model.delete)
                
            } catch {
                XCTFail("Caught Exception. \(error)")
            }
        }
        model.save()
        
        super.tearDown()
    }
    
    func testInsertAndFetch() {
        
        let model = Model.oneTimeEditor()
        
        model.sync {
            let person = model.insertNewObject(for: Person.entity)
            person?.name = testName
            person?.identifier = testId
        }
        model.save()
        
        let model2 = Model.oneTimeEditor()
        model2.sync {
            
            let p = NSPredicate(format: "%K == %@", "name", testName)
            
            do {
                let persons = try model2.objects(of: Person.entity, sortDescriptors: nil, predicate: p)
                
                XCTAssertFalse(persons.isEmpty)
                
                guard let person = persons.first else {
                    
                    XCTFail("Can not get Person from person's array")
                    return
                }
                
                guard let name = person.name else {
                    
                    XCTFail("Person Name is nil")
                    return
                }
                
                XCTAssertEqual(name, testName)
                
                XCTAssertEqual(person.identifier, testId)
            
            } catch {
                XCTFail("Caught Exception. \(error)")
            }
        }
    }
    
    func testSync() {
        
        let model = Model.oneTimeEditor()
        
        model.sync {
            let person = model.insertNewObject(for: Person.entity)
            person?.name = testName
            person?.identifier = testId
        }
        model.save()
        
        guard let name = Model.default.person(of: testName)?.name else {
            
            XCTFail("Can not get Person by name)")
            return
        }
        
        XCTAssertTrue(name == testName)
        
    }
    
    func testExcahnge() {
        
        let model = Model.oneTimeEditor()
        
        model.sync {
            let person = model.insertNewObject(for: Person.entity)
            person?.name = testName
            person?.identifier = testId
        }
        model.save()
        
        guard let person = Model.default.person(of: testName) else {
            
            XCTFail("Can not get Person by name)")
            return
        }
        
        let model2 = Model.oneTimeEditor()
        let person2 = model2.exchange(person)
        XCTAssertNotNil(person2)
    }
    
}
