//
//  iOSAuthLibraryTests.swift
//  iOSAuthLibraryTests
//
//  Created by Pariveda Solutions.
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
        
        authLibrary = AuthLibrary("Toyota")
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
    
    func testPerformanceIsAuthenticated() {
        self.measure {
            self.authLibrary.isAuthenticated()
        }
    }
    
}
