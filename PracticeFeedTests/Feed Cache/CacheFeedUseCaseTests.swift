//
//  CacheFeedUseCaseTests.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 02/07/21.
//

import XCTest
import PracticeFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save(uniqueImageFeed().models) {_ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestsInsertion_whenDeletionError() {
        let (sut, store) = makeSUT()
        sut.save(uniqueImageFeed().models) {_ in }
        store.completeDeletion(with: anyNSError(), at: 0)
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestsInsertionWithTimestamp_onSuccessfullDeletion() {
        let timestamp = Date()
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        sut.save(feed.models) {_ in }
        store.completeDeletionSuccessfully(at: 0)
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(feed.locals, timestamp)])
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
    
    func test_save_doesnotReturnResultOnDeletionError_AfterTheSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models) { receivedResults.append($0) }
        sut = nil
        store.completeDeletion(with: anyNSError(), at: 0)
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesnotReturnResultOnInsertinoError_AfterTheSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models) { receivedResults.append($0) }
        store.completeDeletionSuccessfully(at: 0)
        sut = nil
        store.completeInsertion(with: anyNSError(), at: 0)
        XCTAssertTrue(receivedResults.isEmpty)
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
        sut.save(uniqueImageFeed().models) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any desc", location: nil, url: anyURL())
    }
    
    func uniqueImageFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let locals = models.map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
        return (models, locals)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com/")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 1, userInfo: nil)
    }
}
