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
    var plistPath : String
    var properties : NSDictionary
    
    init(_ file: String) {
        plistPath = Bundle.main.path(forResource: file, ofType: "plist")!
        properties = NSDictionary(contentsOfFile: plistPath)!
    }
    
    open func getProperty(_ key: String) -> String {
        return properties.object(forKey: key) as! String
    }
}
