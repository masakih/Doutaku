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
        
        _ = SortDescriptors(.ascending(\SortDescriptorsTestClass.integer))
        
        _ = SortDescriptors(.descending(\SortDescriptorsTestClass.string))
        
        _ = SortDescriptors(.ascendingWithComparator(\SortDescriptorsTestClass.float, { (lhs: Float, rhs: Float) -> ComparisonResult in .orderedSame }))
        
        _ = SortDescriptors(.descendingWithComparator(\SortDescriptorsTestClass.double, { _, _ in .orderedDescending }))
        
        _ = SortDescriptors(.ascendingWithComparator(\SortDescriptorsTestClass.string, { lhs, rhs in lhs.compare(rhs) }))
    }
    
    func testCreate() {
        
        let s00 = SortDescriptors(.ascending(\SortDescriptorsTestClass.integer))
        let ns00 = NSSortDescriptor(key: #keyPath(SortDescriptorsTestClass.integer), ascending: true)
        XCTAssertTrue(s00 == [ns00])
        
        let s01 = s00.pushed(.descending(\SortDescriptorsTestClass.float))
        let ns01 = NSSortDescriptor(key: #keyPath(SortDescriptorsTestClass.float), ascending: false)
        XCTAssertTrue(s01 == [ns01, ns00])
        
        let s02 = s00.appended(.descending(\SortDescriptorsTestClass.double))
        let ns02 = NSSortDescriptor(key: #keyPath(SortDescriptorsTestClass.double), ascending: false)
        XCTAssertTrue(s02 == [ns00, ns02])
    }
    
    func testSort() {
        
        let s00 = SortDescriptors(.ascending(\SortDescriptorsTestClass.string))
        let new00 = array.sorted(using: s00)
        XCTAssertEqual(new00.first?.string, "")
        XCTAssertEqual(new00.last?.string, "iiii")
        
        let s01 = SortDescriptors(.descending(\SortDescriptorsTestClass.integer))
        let new01 = array.sorted(using: s01)
        XCTAssertEqual(new01.first?.integer, 3)
        XCTAssertEqual(new01.last?.integer, 0)
        
        let s02 = SortDescriptors(.ascendingWithComparator(\SortDescriptorsTestClass.string, { lhs, rhs in lhs.compare(rhs) }))
        let new02 = array.sorted(using: s02)
        XCTAssertEqual(new02.first?.string, "")
        XCTAssertEqual(new02.last?.string, "iiii")
    }
    
    func testEquatable() {
        
        let s00 = SortDescriptors(.ascending(\SortDescriptorsTestClass.string))
        let s01 = SortDescriptors(.ascending(\SortDescriptorsTestClass.string))
        
        XCTAssertTrue(s00 == s01)
        
        let s02 = SortDescriptors(.descending(\SortDescriptorsTestClass.string))
        XCTAssertFalse(s00 == s02)
        
        let s03 = SortDescriptors(.ascending(\SortDescriptorsTestClass.integer))
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
