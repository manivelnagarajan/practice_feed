//
//  FeedItem.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 04/02/21.
//

import Foundation

public struct FeedItem: Equatable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
