//
//  FeedItemsMapper.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 07/02/21.
//

import Foundation

internal final class FeedItemsMapper {
    
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
    
    static func map(_ response: HTTPURLResponse, data: Data) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,  let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.items.map({ $0.item}))
    }

}
