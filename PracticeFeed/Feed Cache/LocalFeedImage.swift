//
//  LocalFeedItem.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 04/07/21.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
