//
//  iOSAuthLibraryTests.swift
//  iOSAuthLibraryTests
//
//  Created by David Collom on 10/12/16.
//  Copyright © 2016 Pariveda Solutions. All rights reserved.
//

import XCTest
@testable import iOSAuthLibrary

class iOSAuthLibraryTests: XCTestCase {
    
    var loginViewController: LoginViewController!
    var authLibrary: AuthLibrary!
    var keychainService: MockKeychainService!
    
    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard (name: "Login", bundle: Bundle(for: LoginViewController.self))
        loginViewController = storyboard.instantiateInitialViewController() as! LoginViewController
        
        authLibrary = AuthLibrary()
        keychainService = MockKeychainService()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCorrectMockStoreAndGetToken() {
        let mockToken = "test"
        keychainService.storeToken(mockToken, TokenType.id_token.rawValue)
        let token = keychainService.getToken(TokenType.id_token.rawValue)
        XCTAssert(token == mockToken)
    }
    
    func testIncorrectMockStoreAndGetToken() {
        let mockToken = "test"
        keychainService.storeToken(mockToken, TokenType.id_token.rawValue)
        let token = keychainService.getToken(TokenType.auth_token.rawValue)
        XCTAssert(token != mockToken)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
