//
//  PListService.swift
//  iOSAuthLibrary
//
//  Created by David Collom on 11/2/16.
//  Copyright © 2016 Pariveda Solutions. All rights reserved.
//

import Foundation

open class PListService
{
    var properties : Dictionary<String, String>
    
    init(_ file: String) {
        print(file)
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = paths.appending("authCodeRequest.plist")
        properties = NSDictionary(contentsOfFile: path) as! Dictionary
    }
    
    open func getAllProperties() -> Dictionary<String, String> {
        return self.properties
    }
    
    open func getProperty(_ key: String) -> String {
        return properties[key] as String!
    }
}
