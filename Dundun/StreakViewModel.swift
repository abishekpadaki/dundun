//
//  StreakViewModel.swift
//  Dundun
//
//  Created by Abishek Padaki on 8/16/24.
//

import Foundation

class StreakViewModel: ObservableObject {
    @Published var streaks: [Streak] = []
    
    init() {
        loadStreaks()
    }
    
    func addStreak(title: String) {
        let newStreak = Streak(title: title)
        streaks.append(newStreak)
        saveStreaks()
    }
    
    func completeStreak(_ streak: Streak) {
        if let index = streaks.firstIndex(where: { $0.id == streak.id }) {
            let today = Calendar.current.startOfDay(for: Date())
            if let lastCompleted = streak.lastCompletedDate,
               Calendar.current.isDate(lastCompleted, inSameDayAs: today) {
                // Already completed today
                return
            }
            
            if let lastCompleted = streak.lastCompletedDate,
               Calendar.current.isDateInYesterday(lastCompleted) {
                streaks[index].count += 1
            } else {
                streaks[index].count = 1
            }
            
            // Update longest streak if necessary
            if streaks[index].count > streaks[index].longestStreak {
                streaks[index].longestStreak = streaks[index].count
            }
            
            streaks[index].lastCompletedDate = today
            saveStreaks()
        }
    }
    
    func isStreakCompletedToday(_ streak: Streak) -> Bool {
        guard let lastCompleted = streak.lastCompletedDate else {
            return false
        }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    func deleteStreak(_ streak: Streak) {
        streaks.removeAll { $0.id == streak.id }
        saveStreaks()
    }
    
    func resetStreak(_ streak: Streak) {
        if let index = streaks.firstIndex(where: { $0.id == streak.id }) {
            let originalCount = streaks[index].count
            let originalLongestStreak = streaks[index].longestStreak

            streaks[index].count = 0
            streaks[index].lastCompletedDate = nil
            
            // If the original count was the longest streak, reset longest streak to 0
            if originalCount == originalLongestStreak {
                streaks[index].longestStreak = 0
            }
            // Note: We don't reset the longest streak here if originalCount != originalLongestStreak
            saveStreaks()
        }
    }
    
    func undoCompleteStreak(_ streak: Streak) {
        if let index = streaks.firstIndex(where: { $0.id == streak.id }) {
            // Only allow undo if it was completed today
            if let lastCompleted = streaks[index].lastCompletedDate, Calendar.current.isDateInToday(lastCompleted) {
                let originalCount = streaks[index].count
                let originalLongestStreak = streaks[index].longestStreak

                if streaks[index].count > 0 {
                    streaks[index].count -= 1
                }
                streaks[index].lastCompletedDate = nil

                // If the original count was the longest streak, update longest streak to the new count
                if originalCount == originalLongestStreak {
                    streaks[index].longestStreak = streaks[index].count
                }
                saveStreaks()
            }
        }
    }
    
    private func saveStreaks() {
        if let encoded = try? JSONEncoder().encode(streaks) {
            UserDefaults.standard.set(encoded, forKey: "Streaks")
        }
    }
    
    private func loadStreaks() {
        if let savedStreaks = UserDefaults.standard.data(forKey: "Streaks"),
           let decodedStreaks = try? JSONDecoder().decode([Streak].self, from: savedStreaks) {
            streaks = decodedStreaks
        }
    }
}
