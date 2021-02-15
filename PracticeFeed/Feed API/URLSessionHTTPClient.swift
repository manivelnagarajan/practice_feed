//
//  URLSessionHTTPClient.swift
//  PracticeFeed
//
//  Created by Manivel Nagarajan on 15/02/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnRepresentedError: Error {}
    
    public func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(response, data))
            } else {
                completion(.failure(UnRepresentedError()))
            }
        }).resume()
    }
}
