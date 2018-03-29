//
//  SortDescriptorsTests.swift
//  DoutakuTests
//
//  Created by Hori,Masaki on 2018/03/25.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import XCTest

import Doutaku


class SortDescriptorsTestClass: NSObject {
    
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

class SortDescriptorsTests: XCTestCase {
    
    let array = [
        SortDescriptorsTestClass(0, 0, 0, ""),
        SortDescriptorsTestClass(1, 1, 1, "hoge"),
        SortDescriptorsTestClass(2, 0, 0, "iiii"),
        SortDescriptorsTestClass(3, 1, 1, "aaa")
    ]
    
    func testInitialize() {
        
        _ = SortDescriptors(keyPath: \SortDescriptorsTestClass.integer, ascending: true)
        
        _ = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: false)
        
        _ = SortDescriptors(keyPath: \SortDescriptorsTestClass.float,ascending: true, comparator: { (lhs: Float, rhs: Float) -> ComparisonResult in .orderedSame })
        
        _ = SortDescriptors(keyPath: \SortDescriptorsTestClass.double, ascending: false, comparator: { _, _ in .orderedDescending })
        
        _ = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: true, comparator: { lhs, rhs in lhs.compare(rhs) })
    }
    
    func testCreate() {
        
        let s00 = SortDescriptors(keyPath: \SortDescriptorsTestClass.integer, ascending: true)
        let ns00 = NSSortDescriptor(key: #keyPath(SortDescriptorsTestClass.integer), ascending: true)
        XCTAssertTrue(s00 == [ns00])
        
        let s01 = s00.pushed(keyPath: \SortDescriptorsTestClass.float, ascending: false)
        let ns01 = NSSortDescriptor(key: #keyPath(SortDescriptorsTestClass.float), ascending: false)
        XCTAssertTrue(s01 == [ns01, ns00])
        
        let s02 = s00.appended(keyPath: \SortDescriptorsTestClass.double, ascending: false)
        let ns02 = NSSortDescriptor(key: #keyPath(SortDescriptorsTestClass.double), ascending: false)
        XCTAssertTrue(s02 == [ns00, ns02])
    }
    
    func testSort() {
        
        let s00 = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: true)
        let new00 = array.sorted(using: s00)
        XCTAssertEqual(new00.first?.string, "")
        XCTAssertEqual(new00.last?.string, "iiii")
        
        let s01 = SortDescriptors(keyPath: \SortDescriptorsTestClass.integer, ascending: false)
        let new01 = array.sorted(using: s01)
        XCTAssertEqual(new01.first?.integer, 3)
        XCTAssertEqual(new01.last?.integer, 0)
        
        let s02 = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: true, comparator: { lhs, rhs in lhs.compare(rhs) })
        let new02 = array.sorted(using: s02)
        XCTAssertEqual(new02.first?.string, "")
        XCTAssertEqual(new02.last?.string, "iiii")
        
        let s03 = s00.pushed(keyPath: \SortDescriptorsTestClass.float, ascending: true) { (lhs, rhs) -> ComparisonResult in
            if lhs > rhs { return .orderedAscending }
            else if lhs == rhs { return .orderedSame }
            else { return .orderedDescending }
        }
        let new03 = array.sorted(using: s03)
        XCTAssertEqual(new03.first?.string, "aaa")
        XCTAssertEqual(new03.last?.string, "iiii")
        
        let s04 = s00.appended(keyPath: \SortDescriptorsTestClass.double, ascending: true) { (lhs, rhs) -> ComparisonResult in
            if lhs > rhs { return .orderedAscending }
            else if lhs == rhs { return .orderedSame }
            else { return .orderedDescending }
        }
        let new04 = array.sorted(using: s04)
        XCTAssertEqual(new04.first?.string, "")
        XCTAssertEqual(new04.last?.string, "iiii")
    }
    
    func testUnion() {
        
        let s00 = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: true)
        let s01 = SortDescriptors(keyPath: \SortDescriptorsTestClass.float, ascending: true)
        let s02 = s00.union(s01)
        
        let ns00 = NSSortDescriptor(keyPath: \SortDescriptorsTestClass.string, ascending: true)
        let ns01 = NSSortDescriptor(keyPath: \SortDescriptorsTestClass.float, ascending: true)
        
        XCTAssertTrue(s02 == [ns00, ns01])
    }
    
    func testGetKeyPath() {
        
        let s00 = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: true)
        XCTAssertEqual(s00.keyPaths.first, \SortDescriptorsTestClass.string)
        
        let s01 = SortDescriptors(keyPath: \SortDescriptorsTestClass.float, ascending: true)
        XCTAssertEqual(s01.keyPaths.first, \SortDescriptorsTestClass.float)
    }
    
    func testEquatable() {
        
        let s00 = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: true)
        let s01 = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: true)
        
        XCTAssertTrue(s00 == s01)
        
        let s02 = SortDescriptors(keyPath: \SortDescriptorsTestClass.string, ascending: false)
        XCTAssertFalse(s00 == s02)
        
        let s03 = SortDescriptors(keyPath: \SortDescriptorsTestClass.integer, ascending: true)
        XCTAssertFalse(s00 == s03)
        
        let ns00 = NSSortDescriptor(keyPath: \SortDescriptorsTestClass.string, ascending: true)
        XCTAssertTrue(s00 == [ns00])
        XCTAssertTrue([ns00] == s00)
        
        let ns01 = NSSortDescriptor(keyPath: \SortDescriptorsTestClass.integer, ascending: true)
        XCTAssertFalse(s00 == [ns01])
        XCTAssertFalse([ns01] == s00)
        
        let ns02 = NSSortDescriptor(keyPath: \SortDescriptorsTestClass.string, ascending: false)
        XCTAssertFalse(s00 == [ns02])
        XCTAssertFalse([ns02] == s00)
        
    }
}
