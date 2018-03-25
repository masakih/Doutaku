//
//  DoutakuTests.swift
//  DoutakuTests
//
//  Created by Hori,Masaki on 2018/03/18.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import XCTest

import Doutaku
@testable import DoutakuApp


class DoutakuTests: XCTestCase {
    
    let testName = "NameTest"
    let testId = 100_000
    
    
    func removeTestData() {
        
        let model = Model.oneTimeEditor()
        
        model.sync {
            
            let p = Predicate(\Person.name, equalTo: testName)
            
            do {
                let persons = try model.objects(of: Person.entity, sortDescriptors: nil, predicate: p)
                
                persons.forEach(model.delete)
                
            } catch {
                XCTFail("Caught Exception. \(error)")
            }
        }
        model.save()
    }
    
    override func setUp() {
        super.setUp()
        
        removeTestData()
    }
    
    override func tearDown() {
        
       removeTestData()
        
        super.tearDown()
    }
    
    func testThisTest() {
        
        let p = Predicate(\Person.name, equalTo: testName)
        let person = try? Model.default.objects(of: Person.entity, predicate: p)
        
        XCTAssertNotNil(person)
        
        XCTAssertTrue(person!.isEmpty)
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
            
            let p = Predicate(\Person.name, equalTo: testName)
            
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
    
    func testAsync() {
        
        let ex = expectation(description: "testAsync")
        
        let model = Model.oneTimeEditor()
        
        model.async {
            
            let person = model.insertNewObject(for: Person.entity)
            person?.name = self.testName
            person?.identifier = self.testId
            
            model.save()
            
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        let model2 = Model.oneTimeEditor()
        let person2 = model2.person(of: testName)
        XCTAssertNotNil(person2)
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
    
    func testURIRepresentation() {
        
        let model = Model.oneTimeEditor()
        
        let uri = model.sync { () -> URL in
            
            let person = model.insertNewObject(for: Person.entity)
            person?.name = testName
            person?.identifier = testId
            
            guard let uri = person?.objectID.uriRepresentation() else {
                
                XCTFail("Could not get uriRepresentation")
                fatalError("Could not get uriRepresentation")
            }
            
            model.save()
            
            return uri
        }
        
        let model2 = Model.oneTimeEditor()
        let person2 = model2.object(of: Person.entity, forURIRepresentation: uri)
        XCTAssertNotNil(person2)
        
    }
    
}
