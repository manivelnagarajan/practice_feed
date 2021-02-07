//
//  HTTPClient.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 07/02/21.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void)
}
