//
//  RemoteFeedLoader.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 06/02/21.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public enum Error: Swift.Error {
        case connectiviy
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(_ completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(response, data):
                completion(FeedItemsMapper.map(response, data: data))
            case .failure:
                completion(.failure(.connectiviy))
            }
        }
    }
}
