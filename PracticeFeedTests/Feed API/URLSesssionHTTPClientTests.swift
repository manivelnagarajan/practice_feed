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
    
    func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url, completionHandler: { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }).resume()
    }
}

class URLSesssionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_dataTaskWithURL_Failure() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://a-url.com/")!
        let error = NSError(domain: "Test", code: 1, userInfo: nil)
        URLProtocolStub.stub(url: url, error: error)
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "wait to get error")
        sut.get(from: url, { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(error, receivedError)
            default:
                XCTFail("Result expected, but got \(result) instead")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    //MARK: Helpers
    private class URLProtocolStub: URLProtocol {
        private static var stub = [URL: Stub]()
        
        private struct Stub {
            var error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stub[url] = Stub(error: error)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return stub[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stub[url] else { return }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
        }
    }
}
