//
//  URLSesssionHTTPClientTests.swift
//  PracticeFeedTests
//
//  Created by Manivel Nagarajan on 13/02/21.
//

import Foundation
import PracticeFeed
import XCTest

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: HTTPSession
    init(session: HTTPSession) {
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
    
    func test_getFromURL_dataTaskWithURL_Resumes() {
        let url = URL(string: "https://a-url.com/")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url, {_ in })
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_dataTaskWithURL_Failure() {
        let url = URL(string: "https://a-url.com/")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "Test", code: 1, userInfo: nil)
        session.stub(url: url, task: task, error: error)
        let sut = URLSessionHTTPClient(session: session)
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
    }
    
    //MARK: Helpers
    private class HTTPSessionSpy: HTTPSession {
        private var stub = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTaskSpy
            var error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTaskSpy, error: Error? = nil) {
            stub[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stub[url] else { return FakeURLSessionDataTask()}
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() {
        }
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0

        func resume() {
            resumeCallCount += 1
        }
    }
}
