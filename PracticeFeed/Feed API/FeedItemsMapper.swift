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
    
    static func map(_ response: HTTPURLResponse, data: Data) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,  let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        let items = root.items.map({ $0.item})
        return .success(items)
    }
}
