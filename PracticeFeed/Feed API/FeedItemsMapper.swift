//
//  FeedItemsMapper.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 07/02/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    var id: UUID
    var description: String?
    var location: String?
    var image: URL
}

internal final class FeedItemsMapper {
    
    private struct Root: Decodable {
        var items: [RemoteFeedItem]
    }
    
    static var OK_200 = 200
    
    static func map(_ response: HTTPURLResponse, data: Data) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,  let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
