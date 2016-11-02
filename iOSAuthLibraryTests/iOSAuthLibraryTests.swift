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
    var keychainService: KeychainService!
    
    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard (name: "Login", bundle: Bundle(for: LoginViewController.self))
        loginViewController = storyboard.instantiateInitialViewController() as! LoginViewController
        
        authLibrary = AuthLibrary()
        keychainService = KeychainService()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        XCTAssert(true)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
