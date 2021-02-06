//
//  RemoteFeedLoaderTests.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 04/02/21.
//

import Foundation
import XCTest
import PracticeFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotLoad() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_requestsLoadDataFromURL() {
        let (sut, client) = makeSUT()
        sut.load({_ in })
        XCTAssertEqual(client.requestedURLs.count, 1)
    }
    
    func test_requestsTwiceLoadDataFromURLTwice() {
        let url = URL(string: "https://a-feed-url.com/")!
        let (sut, client) = makeSUT(url: url)
        sut.load({_ in })
        sut.load({_ in })
        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    func test_LoadData_Connectivity_Fails() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load({ error in capturedErrors.append(error) })
        
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErrors, [.connectiviy])
    }
    
    func test_LoadData_Fails_InvalidData_Non200Response() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { (index, code) in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load({ error in capturedErrors.append(error) })

            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    //MARK: Helpers
    private class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL]  {
            messages.map({ $0.url })
        }
        
        func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void) {
            messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(response))
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com/")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
}
