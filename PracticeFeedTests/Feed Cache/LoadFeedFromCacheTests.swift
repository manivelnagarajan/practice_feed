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
    
    func test_load_requestsCacheRetrievel() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        let exp = expectation(description: "waiting for load completion")
        var receivedError: Error? = nil
        sut.load { result in
            switch result {
            case .failure(let error):
                receivedError = error
                exp.fulfill()
            default:
                XCTFail("Expected failure but received \(result)")
            }
        }
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        var receivedImages : [FeedImage]?
        let exp = expectation(description: "waiting for load completion")
        sut.load { result in
            switch result {
            case .success(let images):
                receivedImages = images
                exp.fulfill()
            default:
                XCTFail("Expected Empty cache but received \(result)")
            }
        }
        store.completeRetrievalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedImages, [])
    }
    
    //MARK: Helpers
    func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 1, userInfo: nil)
    }
}
