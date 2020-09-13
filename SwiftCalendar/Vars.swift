//
//  Vars.swift
//  SwiftCalendar
//
//  Created by hyperactive on 13/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation

struct Exercise: CustomStringConvertible {
    var description: String
    var isDot:Bool {
        didSet {
            setDescription()
        }
    }
    var numbers:[String] {
        didSet {
            setDescription()
        }
    }
    var operations:[String] {
        didSet {
            setDescription()
        }
    }
    var isOperation:Bool {
        didSet {
            setDescription()
        }
    }
    
    init() {
        isDot = false
        isOperation = false
        numbers = []
        operations = []
        description = ""
    }
    
    mutating func setDescription() {
        description = ""
        if isDot {
            description += "true"
        }
        else {
            description += "false"
        }
        
        if isOperation {
            description += ",true"
        }
        else {
            description += ",false"
        }
        
        var operationsDescription = operations.description.replacingOccurrences(of: ",", with: " ")
        var numbersDescription = numbers.description.replacingOccurrences(of: ",", with: " ")
        
        description += ("," + operationsDescription)
        
        description += ("," + numbersDescription)
    }
}

struct User {
    var userName = ""
    var exercise = Exercise()
}
