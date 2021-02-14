//
//  URLSesssionHTTPClientTests.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 13/02/21.
//

import Foundation
import PracticeFeed
import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    private struct UnRepresentedError: Error {}
    func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void) {
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

class URLSesssionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performGetRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "waiting for the request load")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_dataTaskWithURL_Failure() {
        let error = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: error)
        XCTAssertEqual(receivedError as NSError?, error)
    }
    
    func test_getFromURL_failsOnUnrepresentedStateErrors() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let httpURLResponse = anyHTTPURLResponse()
        URLProtocolStub.stub(data: nil, response: httpURLResponse, error: nil)
        let exp = expectation(description: "wait for fetching data")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(receivedResponse, receivedData):
                let emptyData = Data()
                XCTAssertEqual(receivedData, emptyData)
                XCTAssertEqual(receivedResponse.url, httpURLResponse.url)
                XCTAssertEqual(receivedResponse.statusCode, httpURLResponse.statusCode)
            case .failure:
                XCTFail("Expected success, but got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_succeedsWithHTTPURLResponseAndData() {
        let data = anyData()
        let httpURLResponse = anyHTTPURLResponse()
        URLProtocolStub.stub(data: data, response: httpURLResponse, error: nil)
        let exp = expectation(description: "wait for fetching data")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(receivedResponse, receivedData):
                XCTAssertEqual(receivedResponse.url, httpURLResponse.url)
                XCTAssertEqual(receivedResponse.statusCode, httpURLResponse.statusCode)
                XCTAssertEqual(receivedData, data)
            case .failure:
                XCTFail("Expected success, but got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    //MARK: Helpers
    func resultErrorFor(data: Data?, response: URLResponse?, error: Error?) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "wait to get error")
        var receivedError: Error?
        makeSUT().get(from: anyURL(), { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, but got \(result) instead")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func makeSUT() -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut)
        return sut
    }

    private func anyData() -> Data {
        "any data".data(using: .utf8)!
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com/")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "Test", code: 1, userInfo: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 403, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> ())?
        private struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }
        
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> ()) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
        }
    }
}
