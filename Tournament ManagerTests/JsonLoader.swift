//
//  JsonLoader.swift
//  Tournament Manager
//
//  Created by Marcus Trenton on 2017-09-11.
//  Copyright © 2017 Marcus Trenton. All rights reserved.
//

import Foundation

struct JsonLoader {
    static func loadFile(fileName: String, classRef: AnyObject) -> [String: AnyObject]? {
        let testBundle = Bundle(for: type(of: classRef))
        let url = testBundle.url(forResource: fileName, withExtension: "json")
        
        guard let data: Data = NSData(contentsOf: url!) as Data?
            else {
                return nil
        }
        
        do {
            let jsonRaw = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let json = jsonRaw as? [String: AnyObject]
                else {
                    return nil
            }
            return json
            
        } catch {
            print("Not parsed")
        }
        
        return nil
    }
}
