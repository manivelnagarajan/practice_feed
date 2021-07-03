//
//  LocalFeedLoader.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 03/07/21.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping() -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> ()) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], completion: @escaping (Error?) -> ()) {
        store.insert(items, timestamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()

    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertCompletion)
}
