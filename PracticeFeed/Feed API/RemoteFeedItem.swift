//
//  RemoteFeedItem.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 04/07/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    var id: UUID
    var description: String?
    var location: String?
    var image: URL
}
