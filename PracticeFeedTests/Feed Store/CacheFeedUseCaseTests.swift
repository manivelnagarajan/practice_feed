//
//  CacheFeedUseCaseTests.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 02/07/21.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCacheCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }
}
