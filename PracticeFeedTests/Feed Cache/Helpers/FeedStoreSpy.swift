//
//  FeedStoreSpy.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 24/07/21.
//

import Foundation
import PracticeFeed

class FeedStoreSpy: FeedStore {
    var insertCompletions: [InsertCompletion] = []
    var deleteCompletions: [DeleteCompletion] = []
    var retrieveCompletions: [RetrieveCompletion] = []
    var receivedMessages: [ReceivedMessage] = []
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        deleteCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        insertCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        retrieveCompletions.append(completion)
        receivedMessages.append(.retrieve)
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
    
    func completeRetrieval(with error: NSError, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrieveCompletions[index](.empty)
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timeStamp: Date, at index: Int = 0) {
        retrieveCompletions[index](.found(feed: feed, timestamp: timeStamp))
    }
}
