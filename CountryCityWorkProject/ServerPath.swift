//
//  ServerPath.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 22.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
//

import Foundation
import MobileCoreServices

struct ServerRoot {
    static let WorkRoot = "https://atw-backend.azurewebsites.net"
}

struct ServerPath {
    static let GetCountriesInfo = "api/countries"
}

private var CurrentServerRoot: String? {
    return ServerRoot.WorkRoot
}

func GetServerPathUrl(method: String, params: NSDictionary = [:]) -> NSURL? {
    
    var paramsString = ""
    
    for param in params {
        paramsString += "\(param.key)=\(param.value)&"
    }
    
    if paramsString != "" {
        paramsString = "?" + paramsString.substringToIndex(paramsString.endIndex.advancedBy(-1))
    }
    
    if let serverMainRoot = CurrentServerRoot {
        print("\(serverMainRoot)/\(method)" + paramsString)
        return NSURL(string: "\(serverMainRoot)/\(method)\(paramsString)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        
        // return NSURL(string: "\(serverMainRoot)/\(method)\(paramsString)")
    }
    
    return nil
}

class JSON {
    static func getData(jsonUrl: NSURL?) -> NSDictionary? {
        if let url = jsonUrl {
            let jsonData = NSData(contentsOfURL: url)
            if jsonData != nil {
                do {
                    let boardsDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    return boardsDictionary
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
}






