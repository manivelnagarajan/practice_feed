//
//  RemoteFeedLoader.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 06/02/21.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public typealias Result = LoadFeedResult
    
    public enum Error: Swift.Error {
        case connectiviy
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(_ completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(response, data):
                completion(FeedItemsMapper.map(response, data: data))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectiviy))
            }
        }
    }
}
