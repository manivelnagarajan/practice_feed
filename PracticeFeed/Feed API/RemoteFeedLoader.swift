//
//  RemoteFeedLoader.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 06/02/21.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void)
}

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
                do {
                    let items = try FeedItemsMapper.map(response: response, data: data)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectiviy))
            }
        }
    }
}

private class FeedItemsMapper {
    
    private struct Root: Decodable {
        var items: [Item]
    }

    private struct Item: Decodable {
        var id: UUID
        var description: String?
        var location: String?
        var image: URL
        
        var item: FeedItem {
            FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    
    static var OK_200 = 200
    
    static func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map({ $0.item})
    }
}
