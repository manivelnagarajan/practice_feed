//
//  FeedStore.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 03/07/21.
//

import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()

    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion)
    func retrieve()
}
