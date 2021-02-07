//
//  FeedLoader.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 04/02/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(_ completion: @escaping (LoadFeedResult) -> Void)
}
