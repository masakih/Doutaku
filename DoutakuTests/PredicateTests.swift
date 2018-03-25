//
//  PredicateTests.swift
//  DoutakuTests
//
//  Created by Hori,Masaki on 2018/03/25.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import XCTest

import Doutaku
@testable import DoutakuApp

class PredicateTestClass: NSObject {
    
    @objc let integer: Int
    
    @objc let float: Float
    
    @objc let double: Double
    
    @objc let string: String
    
    init(_ integer: Int, _ float: Float, _ double: Double, _ string: String) {
        
        self.integer = integer
        self.float = float
        self.double = double
        self.string = string
    }
}

class PredicateTests: XCTestCase {
    
    let array = [
        PredicateTestClass(0, 0, 0, ""),
        PredicateTestClass(1, 1, 1, "hoge")
        ]
    
    func testLessThan() {
        
        let predicate = Predicate(\PredicateTestClass.integer, lessThan: 1)
        XCTAssertTrue(array.filtered(using: predicate).count == 1)
        
        let predicate2 = Predicate(\PredicateTestClass.integer, lessThan: 0)
        XCTAssertTrue(array.filtered(using: predicate2).count == 0)
        
        let predicate3 = Predicate(\PredicateTestClass.float, lessThan: 1)
        XCTAssertTrue(array.filtered(using: predicate3).count == 1)
        
        let predicate4 = Predicate(\PredicateTestClass.float, lessThan: 0)
        XCTAssertTrue(array.filtered(using: predicate4).count == 0)
        
        let predicate5 = Predicate(\PredicateTestClass.double, lessThan: 1)
        XCTAssertTrue(array.filtered(using: predicate5).count == 1)
        
        let predicate6 = Predicate(\PredicateTestClass.double, lessThan: 0)
        XCTAssertTrue(array.filtered(using: predicate6).count == 0)
    }
    
    func testLessThanEqual() {
        
        let predicate = Predicate(\PredicateTestClass.integer, lessThanOrEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate).count == 2)
        
        let predicate2 = Predicate(\PredicateTestClass.integer, lessThanOrEqualTo: 0)
        XCTAssertTrue(array.filtered(using: predicate2).count == 1)
        
        let predicate3 = Predicate(\PredicateTestClass.float, lessThanOrEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate3).count == 2)
        
        let predicate4 = Predicate(\PredicateTestClass.float, lessThanOrEqualTo: 0)
        XCTAssertTrue(array.filtered(using: predicate4).count == 1)
        
        let predicate5 = Predicate(\PredicateTestClass.double, lessThanOrEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate5).count == 2)
        
        let predicate6 = Predicate(\PredicateTestClass.double, lessThanOrEqualTo: 0)
        XCTAssertTrue(array.filtered(using: predicate6).count == 1)
    }
    
    func testGreaterThan() {
        
        let predicate = Predicate(\PredicateTestClass.integer, greaterThan: 1)
        XCTAssertTrue(array.filtered(using: predicate).count == 0)
        
        let predicate2 = Predicate(\PredicateTestClass.integer, greaterThan: 0)
        XCTAssertTrue(array.filtered(using: predicate2).count == 1)
        
        let predicate3 = Predicate(\PredicateTestClass.float, greaterThan: 1)
        XCTAssertTrue(array.filtered(using: predicate3).count == 0)
        
        let predicate4 = Predicate(\PredicateTestClass.float, greaterThan: 0)
        XCTAssertTrue(array.filtered(using: predicate4).count == 1)
        
        let predicate5 = Predicate(\PredicateTestClass.double, greaterThan: 1)
        XCTAssertTrue(array.filtered(using: predicate5).count == 0)
        
        let predicate6 = Predicate(\PredicateTestClass.double, greaterThan: 0)
        XCTAssertTrue(array.filtered(using: predicate6).count == 1)
    }
    
    func testGreaterThanEqual() {
        
        let predicate = Predicate(\PredicateTestClass.integer, greaterThanOrEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate).count == 1)
        
        let predicate2 = Predicate(\PredicateTestClass.integer, greaterThanOrEqualTo: 0)
        XCTAssertTrue(array.filtered(using: predicate2).count == 2)
        
        let predicate3 = Predicate(\PredicateTestClass.float, greaterThanOrEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate3).count == 1)
        
        let predicate4 = Predicate(\PredicateTestClass.float, greaterThanOrEqualTo: 0)
        XCTAssertTrue(array.filtered(using: predicate4).count == 2)
        
        let predicate5 = Predicate(\PredicateTestClass.double, greaterThanOrEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate5).count == 1)
        
        let predicate6 = Predicate(\PredicateTestClass.double, greaterThanOrEqualTo: 0)
        XCTAssertTrue(array.filtered(using: predicate6).count == 2)
    }
    
    func testEqualTo() {
        
        let value = "hoge"
        
        let original = NSPredicate(format: "%K == %@", #keyPath(PredicateTestClass.string), value)
        
        let predicate0 = Predicate(\PredicateTestClass.string, equalTo: value)
        XCTAssertTrue(original == predicate0)
        XCTAssertTrue(array.filtered(using: predicate0).count == 1)
        
        let predicate01 = Predicate(\PredicateTestClass.string, equalTo: "hoge")
        XCTAssertTrue(array.filtered(using: predicate01).count == 1)
        
        let predicate02 = Predicate(\PredicateTestClass.string, equalTo: "hoGe")
        XCTAssertTrue(array.filtered(using: predicate02).count == 0)
        
        let predicate03 = Predicate(\PredicateTestClass.string, equalTo: "hoGe", options: .caseInsensitive)
        XCTAssertTrue(array.filtered(using: predicate03).count == 1)
        
        let predicate04 = Predicate(\PredicateTestClass.string, equalTo: "höGe", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertTrue(array.filtered(using: predicate04).count == 1)
        
        let predicate1 = Predicate(\PredicateTestClass.integer, equalTo: 1)
        XCTAssertTrue(array.filtered(using: predicate1).count == 1)
        
        let predicate2 = Predicate(\PredicateTestClass.integer, equalTo: 3)
        XCTAssertTrue(array.filtered(using: predicate2).count == 0)
        
        let predicate3 = Predicate(\PredicateTestClass.float, equalTo: 1)
        XCTAssertTrue(array.filtered(using: predicate3).count == 1)
        
        let predicate4 = Predicate(\PredicateTestClass.float, equalTo: 0.000001)
        XCTAssertTrue(array.filtered(using: predicate4).count == 0)
        
        let predicate5 = Predicate(\PredicateTestClass.double, equalTo: 1)
        XCTAssertTrue(array.filtered(using: predicate5).count == 1)
        
        let predicate6 = Predicate(\PredicateTestClass.double, equalTo: 0.000001)
        XCTAssertTrue(array.filtered(using: predicate6).count == 0)
    }
    
    func testNotEqualTo() {
        
        let predicate00 = Predicate(\PredicateTestClass.string, notEqualTo: "value")
        XCTAssertTrue(array.filtered(using: predicate00).count == 2)
        
        let predicate01 = Predicate(\PredicateTestClass.string, notEqualTo: "hoge")
        XCTAssertTrue(array.filtered(using: predicate01).count == 1)
        
        let predicate02 = Predicate(\PredicateTestClass.string, notEqualTo: "hoGe")
        XCTAssertTrue(array.filtered(using: predicate02).count == 2)
        
        let predicate03 = Predicate(\PredicateTestClass.string, notEqualTo: "hoGe", options: .caseInsensitive)
        XCTAssertTrue(array.filtered(using: predicate03).count == 1)
        
        let predicate04 = Predicate(\PredicateTestClass.string, notEqualTo: "höGe", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertTrue(array.filtered(using: predicate04).count == 1)
        
        let predicate1 = Predicate(\PredicateTestClass.integer, notEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate1).count == 1)
        
        let predicate2 = Predicate(\PredicateTestClass.integer, notEqualTo: 3)
        XCTAssertTrue(array.filtered(using: predicate2).count == 2)
        
        let predicate3 = Predicate(\PredicateTestClass.float, notEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate3).count == 1)
        
        let predicate4 = Predicate(\PredicateTestClass.float, notEqualTo: 0.000001)
        XCTAssertTrue(array.filtered(using: predicate4).count == 2)
        
        let predicate5 = Predicate(\PredicateTestClass.double, notEqualTo: 1)
        XCTAssertTrue(array.filtered(using: predicate5).count == 1)
        
        let predicate6 = Predicate(\PredicateTestClass.double, notEqualTo: 0.000001)
        XCTAssertTrue(array.filtered(using: predicate6).count == 2)
    }
    
    func testMatch() {
        
        let predicate00 = Predicate(\PredicateTestClass.string, matches: "value")
        XCTAssertTrue(array.filtered(using: predicate00).count == 0)
        
        let predicate01 = Predicate(\PredicateTestClass.string, matches: "ho.e")
        XCTAssertTrue(array.filtered(using: predicate01).count == 1)
        
        let predicate02 = Predicate(\PredicateTestClass.string, matches: "ho[gG]e")
        XCTAssertTrue(array.filtered(using: predicate02).count == 1)
        
        let predicate03 = Predicate(\PredicateTestClass.string, matches: "\\w*")
        XCTAssertTrue(array.filtered(using: predicate03).count == 2)
        
        let predicate04 = Predicate(\PredicateTestClass.string, matches: "\\w+")
        XCTAssertTrue(array.filtered(using: predicate04).count == 1)
    }
    
    func testLike() {
        
        let predicate00 = Predicate(\PredicateTestClass.string, like: "value")
        XCTAssertTrue(array.filtered(using: predicate00).count == 0)
        
        let predicate01 = Predicate(\PredicateTestClass.string, like: "ho*")
        XCTAssertTrue(array.filtered(using: predicate01).count == 1)
        
        let predicate02 = Predicate(\PredicateTestClass.string, like: "*Ge")
        XCTAssertTrue(array.filtered(using: predicate02).count == 0)
        
        let predicate03 = Predicate(\PredicateTestClass.string, like: "?oGe", options: .caseInsensitive)
        XCTAssertTrue(array.filtered(using: predicate03).count == 1)
        
        let predicate04 = Predicate(\PredicateTestClass.string, like: "*öG*", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertTrue(array.filtered(using: predicate04).count == 1)
    }
    
    func testBeginesWith() {
        
        let predicate00 = Predicate(\PredicateTestClass.string, beginsWith: "value")
        XCTAssertTrue(array.filtered(using: predicate00).count == 0)
        
        let predicate01 = Predicate(\PredicateTestClass.string, beginsWith: "hoge")
        XCTAssertTrue(array.filtered(using: predicate01).count == 1)
        
        let predicate02 = Predicate(\PredicateTestClass.string, beginsWith: "hO")
        XCTAssertTrue(array.filtered(using: predicate02).count == 0)
        
        let predicate03 = Predicate(\PredicateTestClass.string, beginsWith: "hO", options: .caseInsensitive)
        XCTAssertTrue(array.filtered(using: predicate03).count == 1)
        
        let predicate04 = Predicate(\PredicateTestClass.string, beginsWith: "hö", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertTrue(array.filtered(using: predicate04).count == 1)
    }
    
    func testEndsWith() {
        
        let predicate00 = Predicate(\PredicateTestClass.string, endsWith: "value")
        XCTAssertTrue(array.filtered(using: predicate00).count == 0)
        
        let predicate01 = Predicate(\PredicateTestClass.string, endsWith: "hoge")
        XCTAssertTrue(array.filtered(using: predicate01).count == 1)
        
        let predicate02 = Predicate(\PredicateTestClass.string, endsWith: "Ge")
        XCTAssertTrue(array.filtered(using: predicate02).count == 0)
        
        let predicate03 = Predicate(\PredicateTestClass.string, endsWith: "Ge", options: .caseInsensitive)
        XCTAssertTrue(array.filtered(using: predicate03).count == 1)
        
        let predicate04 = Predicate(\PredicateTestClass.string, endsWith: "öGe", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertTrue(array.filtered(using: predicate04).count == 1)
    }
    
    func testContains() {
        
        let predicate00 = Predicate(\PredicateTestClass.string, contains: "value")
        XCTAssertTrue(array.filtered(using: predicate00).count == 0)
        
        let predicate01 = Predicate(\PredicateTestClass.string, contains: "hoge")
        XCTAssertTrue(array.filtered(using: predicate01).count == 1)
        
        let predicate02 = Predicate(\PredicateTestClass.string, contains: "Ge")
        XCTAssertTrue(array.filtered(using: predicate02).count == 0)
        
        let predicate03 = Predicate(\PredicateTestClass.string, contains: "Ge", options: .caseInsensitive)
        XCTAssertTrue(array.filtered(using: predicate03).count == 1)
        
        let predicate04 = Predicate(\PredicateTestClass.string, contains: "öGe", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertTrue(array.filtered(using: predicate04).count == 1)
    }
    
    func testIn() {
        
        let predicate00 = Predicate(\PredicateTestClass.string, in: ["value"])
        XCTAssertTrue(array.filtered(using: predicate00).count == 0)
        
        let predicate01 = Predicate(\PredicateTestClass.string, in: ["hoge"])
        XCTAssertTrue(array.filtered(using: predicate01).count == 1)
        
        let predicate02 = Predicate(\PredicateTestClass.string, in: ["hoge", "fuga"])
        XCTAssertTrue(array.filtered(using: predicate02).count == 1)
        
        let predicate0 = Predicate(\PredicateTestClass.integer, in: [5, 6, 7])
        XCTAssertTrue(array.filtered(using: predicate0).count == 0)
        
        let predicate1 = Predicate(\PredicateTestClass.integer, in: [0])
        XCTAssertTrue(array.filtered(using: predicate1).count == 1)
        
        let predicate2 = Predicate(\PredicateTestClass.integer, in: [0, 1, 2, 3])
        XCTAssertTrue(array.filtered(using: predicate2).count == 2)
    }
    
    func testBetween() {
        
        let predicate0 = Predicate(\PredicateTestClass.integer, between: 0, and: 5)
        XCTAssertTrue(array.filtered(using: predicate0).count == 2)
        
        let predicate1 = Predicate(\PredicateTestClass.integer, between: 1, and: 5)
        XCTAssertTrue(array.filtered(using: predicate1).count == 1)
        
        let predicate2 = Predicate(\PredicateTestClass.integer, between: 2, and: 5)
        XCTAssertTrue(array.filtered(using: predicate2).count == 0)
    }
    
    func testAnd() {
        
        let predicate0 = Predicate(\PredicateTestClass.integer, equalTo: 1)
        let predicate1 = Predicate(\PredicateTestClass.string, equalTo: "hoge")
        let predicate2 = predicate0.and(predicate1)
        XCTAssertTrue(array.filtered(using: predicate2).count == 1)
        
        let predicate3 = Predicate(\PredicateTestClass.integer, equalTo: 1)
        let predicate4 = Predicate(\PredicateTestClass.string, equalTo: "")
        let predicate5 = predicate3.and(predicate4)
        XCTAssertTrue(array.filtered(using: predicate5).count == 0)
        
        let predicate6 = Predicate(\PredicateTestClass.integer, equalTo: 4)
        let predicate7 = Predicate(\PredicateTestClass.string, equalTo: "")
        let predicate8 = predicate6.and(predicate7)
        XCTAssertTrue(array.filtered(using: predicate8).count == 0)
    }
    
    func testOr() {
        
        let predicate0 = Predicate(\PredicateTestClass.integer, equalTo: 1)
        let predicate1 = Predicate(\PredicateTestClass.string, equalTo: "hoge")
        let predicate2 = predicate0.or(predicate1)
        XCTAssertTrue(array.filtered(using: predicate2).count == 1)
        
        let predicate3 = Predicate(\PredicateTestClass.integer, equalTo: 1)
        let predicate4 = Predicate(\PredicateTestClass.string, equalTo: "")
        let predicate5 = predicate3.or(predicate4)
        XCTAssertTrue(array.filtered(using: predicate5).count == 2)
        
        let predicate6 = Predicate(\PredicateTestClass.integer, equalTo: 4)
        let predicate7 = Predicate(\PredicateTestClass.string, equalTo: "")
        let predicate8 = predicate6.or(predicate7)
        XCTAssertTrue(array.filtered(using: predicate8).count == 1)
        
        let predicate9 = Predicate(\PredicateTestClass.integer, equalTo: 4)
        let predicate10 = Predicate(\PredicateTestClass.string, equalTo: "hhh")
        let predicate11 = predicate9.or(predicate10)
        XCTAssertTrue(array.filtered(using: predicate11).count == 0)
    }
    
    func testNegate() {
        
        let predicate01 = Predicate(\PredicateTestClass.string, equalTo: "höGe", options: [.caseInsensitive, .diacriticInsensitive])
        let predicate02 = predicate01.negate()
        XCTAssertTrue(array.filtered(using: predicate02).count == 1)
        
        let predicate03 = Predicate(\PredicateTestClass.string, equalTo: "asdf")
        let predicate04 = predicate03.negate()
        XCTAssertTrue(array.filtered(using: predicate04).count == 2)
        
        let predicate1 = Predicate(\PredicateTestClass.integer, equalTo: 1)
        let predicate2 = predicate1.negate()
        XCTAssertTrue(array.filtered(using: predicate2).count == 1)
        
        let predicate3 = Predicate(\PredicateTestClass.integer, equalTo: 10)
        let predicate4 = predicate3.negate()
        XCTAssertTrue(array.filtered(using: predicate4).count == 2)
    }
}
