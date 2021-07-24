//
//  LocalFeedLoader.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 03/07/21.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveResult = Error?
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping() -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> ()) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed: feed, completion: completion)
            }
        }
    }
    
    private func cache(feed: [FeedImage], completion: @escaping (SaveResult) -> ()) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
    
    public func load(completion: @escaping(Error?) -> ()) {
        store.retrieve(completion: completion)
    }
}

extension Array where Element == FeedImage  {
    func toLocal() -> [LocalFeedImage] {
        map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}


