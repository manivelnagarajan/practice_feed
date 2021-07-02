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
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping() -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> ()) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()

    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertCompletion)
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save([uniqueItem(), ]) {_ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestsInsertion_whenDeletionError() {
        let (sut, store) = makeSUT()
        sut.save([uniqueItem()]) {_ in }
        store.completeDeletion(with: anyNSError(), at: 0)
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestsInsertionWithTimestamp_onSuccessfullDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        sut.save(items) {_ in }
        store.completeDeletionSuccessfully(at: 0)
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timestamp)])
    }
    
    func test_save_fails_whenDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError, at: 0)
        }
    }
    
    func test_save_fails_onCacheInsertionError() {
        let (sut, store) = makeSUT()
        let cacheInsertionError = anyNSError()
        expect(sut, toCompleteWithError: cacheInsertionError) {
            store.completeDeletionSuccessfully(at: 0)
            store.completeInsertion(with: cacheInsertionError, at: 0)
        }
    }
    
    func test_save_succeed_onSuccessfullCacheInsertion() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully(at: 0)
            store.completeInsertionSuccessfully(at: 0)
        }
    }
    
    //MARK: Helpers
    func makeSUT(currentDate: @escaping() -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: @escaping() -> (), file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wating for save result")
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError)
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
    
    class FeedStoreSpy: FeedStore {
        var insertCompletions: [InsertCompletion] = []
        var deleteCompletions: [DeleteCompletion] = []
        var receivedMessages: [ReceivedMessage] = []
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([FeedItem], Date)
        }
        
        func deleteCachedFeed(completion: @escaping DeleteCompletion) {
            deleteCompletions.append(completion)
            receivedMessages.append(.deleteCacheFeed)
        }
        
        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertCompletion) {
            insertCompletions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
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
