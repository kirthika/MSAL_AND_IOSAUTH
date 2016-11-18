//
//  PListService.swift
//  iOSAuthLibrary
//
//  Created by Pariveda Solutions.
//

import Foundation

open class PListService
{
    var properties : Dictionary<String, String>
    
    init(_ file: String) {
        let path = Bundle(for: PListService.self).path(forResource: file, ofType: "plist")!
        properties = NSDictionary(contentsOfFile: path) as! Dictionary
    }
    
    open func getAllProperties() -> Dictionary<String, String> {
        return self.properties
    }
    
    open func getProperty(_ key: String) -> String {
        return properties[key] as String!
    }
}
