//
//  PlayerProgress.swift
//  Cora's Math Journey
//
//  Created by Justin Santorno on 9/10/25.
//


import Foundation

struct PlayerProgress: Codable {
    var totalPoints: Int
    var currentLevel: Int
    var completedLessons: [Int]
    var lessonScores: [Int: Int]  // lesson number: score
    var unicornProgress: Double
    var lastPlayed: Date
    
    static func load() -> PlayerProgress {
        if let data = try? Data(contentsOf: getFileURL()),
           let progress = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            return progress
        }
        // Return default values if no saved data exists
        return PlayerProgress(
            totalPoints: 0,
            currentLevel: 1,
            completedLessons: [],
            lessonScores: [:],
            unicornProgress: 0,
            lastPlayed: Date()
        )
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: Self.getFileURL())
        }
    }
    
    static func getFileURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("CoraProgress.json")
    }
}
