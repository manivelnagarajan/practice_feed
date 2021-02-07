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
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load({ result in capturedResults.append(result) })
        
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with: clientError)
        XCTAssertEqual(capturedResults, [.failure(.connectiviy)])
    }
    
    func test_LoadData_Fails_InvalidData_Non200Response() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { (index, code) in
            var capturedResults = [RemoteFeedLoader.Result]()
            sut.load({ error in capturedResults.append(error) })

            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedResults, [.failure(.invalidData)])
        }
    }
    
    func test_LoadData_InvalidJSON_With200Response() {
        let (sut, client) = makeSUT()
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load({ result in capturedResults.append(result)})
        let data = "invalid json".data(using: .utf8)!
        client.complete(withStatusCode: 200, data: data)
        XCTAssertEqual(capturedResults, [.failure(.invalidData)])
    }
    
    func test_LoadData_ValidJSON_NoItems_With200Response() {
        let (sut, client) = makeSUT()
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load({ result in capturedResults.append(result)})
        let data = "{\"items\": []}".data(using: .utf8)!
        client.complete(withStatusCode: 200, data: data)
        XCTAssertEqual(capturedResults, [.success([])])
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
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(response, data))
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com/")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
}
