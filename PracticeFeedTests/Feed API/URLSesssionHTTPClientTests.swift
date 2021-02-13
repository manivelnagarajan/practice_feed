//
//  URLSesssionHTTPClientTests.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 13/02/21.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url, completionHandler: { _, _, _ in }).resume()
    }
}

class URLSesssionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_dataTaskWithURL_Resumes() {
        let url = URL(string: "https://a-url.com/")!
        let session = HTTPURLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    //MARK: Helpers
    private class HTTPURLSessionSpy: URLSession {
        override init() {}
        var stub = [URL: URLSessionDataTaskSpy]()
        
        func stub(url: URL, task: URLSessionDataTaskSpy) {
            stub[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stub[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override init() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        override init() {}
        var resumeCallCount = 0

        override func resume() {
            resumeCallCount += 1
        }
    }
}
