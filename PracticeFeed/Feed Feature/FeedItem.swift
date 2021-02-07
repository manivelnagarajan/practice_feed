//
//  FeedItem.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 04/02/21.
//

import Foundation

public struct FeedItem: Equatable {
    var id: UUID
    var description: String
    var location: String?
    var imageURL: URL
}
