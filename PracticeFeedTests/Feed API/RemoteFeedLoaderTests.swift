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
        expect(sut, toCompleteWithResult: .failure(.connectiviy)) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError)
        }
    }
    
    func test_LoadData_Fails_InvalidData_Non200Response() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                let data = self.makeItemsJSON([])
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_LoadData_InvalidJSON_With200Response() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let data = "invalid json".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_LoadData_ValidJSON_NoItems_With200Response() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let data = self.makeItemsJSON([])
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_deliversValidItems_With200Response() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-image-url.com/")!)
        let item2 = makeItem(id: UUID(), description: "Test description", location: "test location", imageURL: URL(string: "https://another-image-url.com/")!)
        
        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            let data = self.makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    //MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com/")!,  file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        return (sut, client)
    }
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leak", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load({ result in capturedResults.append(result)})
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private func makeItemsJSON(_ itemJSONs: [[String: Any]]) -> Data {
        let json = ["items":itemJSONs]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL)
        
        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (result, element) in
            if let value = element.value { result[element.key] = value}
        }
        return (item, itemJSON)
    }
    
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(response, data))
        }
    }

}
