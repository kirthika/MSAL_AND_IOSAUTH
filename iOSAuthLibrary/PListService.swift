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
        let testPath = Bundle.main.resourcePath!
        print(testPath)
        let testDocs = NSDictionary(contentsOfFile: testPath) as! Dictionary<String, String>
        print(testDocs)
        let plistPath = Bundle.main.path(forResource: file, ofType: "plist")!
        print(plistPath)
        
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = dir + "/" + file + ".plist"
        print(path)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            properties = NSDictionary(contentsOfFile: path) as! Dictionary
        } else if fileManager.fileExists(atPath: plistPath){
            properties = NSDictionary(contentsOfFile: plistPath) as! Dictionary
        }
        else {
            properties = NSDictionary() as! Dictionary
        }
        
        
    }
    
    open func getAllProperties() -> Dictionary<String, String> {
        return self.properties
    }
    
    open func getProperty(_ key: String) -> String {
        return properties[key] as String!
    }
}
