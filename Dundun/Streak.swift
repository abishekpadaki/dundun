//
//  Streak.swift
//  Dundun
//
//  Created by Abishek Padaki on 8/16/24.
//

import Foundation

struct Streak: Identifiable, Codable {
    let id: UUID
    var title: String
    var count: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    
    init(id: UUID = UUID(), title: String, count: Int = 0, longestStreak: Int = 0, lastCompletedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.count = count
        self.longestStreak = longestStreak
        self.lastCompletedDate = lastCompletedDate
    }
}
