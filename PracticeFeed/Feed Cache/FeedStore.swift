//
//  FeedStore.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 03/07/21.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()
    typealias RetrieveCompletion = (RetrieveCachedFeedResult) -> ()
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion)
    func retrieve(completion: @escaping RetrieveCompletion)
}
