//
//  CacheFeedUseCaseTests.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 02/07/21.
//

import XCTest
import PracticeFeed

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
}

class FeedStore {
    var deleteCacheCallCount = 0
    var insertCacheCallCount = 0
    typealias DeleteCompletion = (Error?) -> ()
    var deleteCompletions: [DeleteCompletion] = []
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        deleteCacheCallCount += 1
        deleteCompletions.append(completion)
    }
    
    func insert(_ items: [FeedItem]) {
        insertCacheCallCount += 1
    }
    
    func completeWithError(_ error: NSError, at index: Int) {
        deleteCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int) {
        deleteCompletions[index](nil)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save([uniqueItem()])
        XCTAssertEqual(store.deleteCacheCallCount, 1)
    }
    
    func test_save_doesNotRequestsInsertion_whenDeletionError() {
        let (sut, store) = makeSUT()
        sut.save([uniqueItem()])
        store.completeWithError(anyNSError(), at: 0)
        XCTAssertEqual(store.insertCacheCallCount, 0)
    }
    
    func test_save_requestsInsertion_onSuccessfullDeletion() {
        let (sut, store) = makeSUT()
        sut.save([uniqueItem()])
        store.completeDeletionSuccessfully(at: 0)
        XCTAssertEqual(store.insertCacheCallCount, 1)
    }
    
    //MARK: Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any desc", location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com/")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 1, userInfo: nil)
    }
}
