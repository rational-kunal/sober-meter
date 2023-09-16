//
//  Question.swift
//  SoberMeter
//
//  Created by Kunal Kamble on 13/09/23.
//

import Foundation

// x - y = answer
struct Question {
    let x, y: Int
    var answer: Int {
        return x - y
    }
    
    static func new() -> Question {
        let x = Int.random(in: 10..<100)
        let ans = Int.random(in: 0..<10)
        return Question(x: x, y: x - ans)
    }
}
