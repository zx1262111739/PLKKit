//
//  PKStringTransfrom.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation


protocol PKStringTransform: PKTransfrom { }

extension PKStringTransform {
    static func transform(from object: Any) -> String? {
        
        switch object {
        case let str as String:
            return str
            
        case let num as NSNumber:
            if NSStringFromClass(type(of: num)) == "__NSCFBoolean" {
                if num.boolValue {
                    return "true"
                } else {
                    return "false"
                }
            }
            
            return num.stringValue
            
        default:
            return nil
        }
    }
}

extension String: PKStringTransform {}
