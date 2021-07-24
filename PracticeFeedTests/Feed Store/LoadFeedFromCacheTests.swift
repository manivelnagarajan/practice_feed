//
//  LoadFeedFromCacheTests.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 24/07/21.
//

import Foundation
import PracticeFeed
import XCTest

class LoadFeedFromCacheTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    //MARK: Helpers
    func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    class FeedStoreSpy: FeedStore {
        var insertCompletions: [InsertCompletion] = []
        var deleteCompletions: [DeleteCompletion] = []
        var receivedMessages: [ReceivedMessage] = []
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([LocalFeedImage], Date)
        }
        
        func deleteCachedFeed(completion: @escaping DeleteCompletion) {
            deleteCompletions.append(completion)
            receivedMessages.append(.deleteCacheFeed)
        }
        
        func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
            insertCompletions.append(completion)
            receivedMessages.append(.insert(feed, timestamp))
        }
        
        func completeDeletion(with error: NSError, at index: Int) {
            deleteCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int) {
            deleteCompletions[index](nil)
        }
        
        func completeInsertion(with error: NSError, at index: Int) {
            insertCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int) {
            insertCompletions[index](nil)
        }
    }
}
