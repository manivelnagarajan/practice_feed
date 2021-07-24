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
    
    func retrieve() {
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
}
