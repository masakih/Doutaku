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

    
    func testInitialize() {
        
        _ = SortDescriptors(.ascending(\SortDescriptorsTestClass.integer))
        
        _ = SortDescriptors(.descending(\SortDescriptorsTestClass.string))
        
        _ = SortDescriptors(.ascendingWithComparator(\SortDescriptorsTestClass.float, { _, _ in .orderedSame }))
        
        _ = SortDescriptors(.descendingWithComparator(\SortDescriptorsTestClass.double, { _, _ in .orderedDescending }))
    }
    
    

}
