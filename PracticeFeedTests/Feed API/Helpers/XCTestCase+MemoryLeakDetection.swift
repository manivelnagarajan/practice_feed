//
//  XCTestCase+MemoryLeakDetection.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 14/02/21.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leak", file: file, line: line)
        }
    }
}
