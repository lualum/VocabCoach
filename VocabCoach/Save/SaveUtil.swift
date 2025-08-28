//
//  SaveUtil.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/8/25.
//

import Foundation

struct WordScore: Codable {
  let word: String
  var scores: [Int]  // Stores last two scores
  var lastUpdated: Date

  var averageScoreInt: Int {
    if scores.isEmpty { return 0 }
    let sum = scores.reduce(0, +)
    // Multiply by 2 to convert to integer (0.5 -> 1, 1.0 -> 2, etc.)
    return (sum * 2) / scores.count
  }

  init(word: String, score: Int) {
    self.word = word
    self.scores = [score]
    self.lastUpdated = Date()
  }

  mutating func addScore(_ score: Int) {
    scores.append(score)
    // Keep only last two scores
    if scores.count > 2 {
      scores = Array(scores.suffix(2))
    }
    lastUpdated = Date()
  }
}

struct ScoreGroup: Codable {
  let averageScoreInt: Int  // Now stored as integer (0-6)
  var words: [WordScore]

  init(averageScoreInt: Int) {
    self.averageScoreInt = averageScoreInt
    self.words = []
  }
}

struct ScoreData: Codable {
  var groups: [ScoreGroup]

  init() {
    self.groups = ScoreData.createAllPossibleGroups()
  }

  static func createAllPossibleGroups() -> [ScoreGroup] {
    // Possible integer averages with scores 0-3 and up to 2 scores (multiplied by 2):
    let possibleAverageInts: [Int] = [6, 5, 4, 3, 2, 1, 0]

    return possibleAverageInts.map { averageInt in
      ScoreGroup(averageScoreInt: averageInt)
    }
  }
}

class SaveUtil {
  private static let fileName = "wordScores.json"

  // Cached data - initialized once and kept in sync
  private static var _cachedScoreData: ScoreData?

  private static func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }

  private static func getFileURL() -> URL {
    return getDocumentsDirectory().appendingPathComponent(fileName)
  }

  private static func loadScoreDataFromDisk() -> ScoreData {
    let url = getFileURL()

    guard let data = try? Data(contentsOf: url),
      let scoreData = try? JSONDecoder().decode(ScoreData.self, from: data)
    else {
      return ScoreData()  // Returns structure with all possible groups
    }

    // Ensure all possible groups exist (for backward compatibility)
    var updatedScoreData = scoreData
    let allPossibleAverageInts: [Int] = [6, 5, 4, 3, 2, 1, 0]

    for averageInt in allPossibleAverageInts {
      if !updatedScoreData.groups.contains(where: { $0.averageScoreInt == averageInt }) {
        updatedScoreData.groups.append(ScoreGroup(averageScoreInt: averageInt))
      }
    }

    // Sort groups by average score (descending)
    updatedScoreData.groups.sort { $0.averageScoreInt > $1.averageScoreInt }

    return updatedScoreData
  }

  private static func getScoreData() -> ScoreData {
    if let cached = _cachedScoreData {
      return cached
    }

    // If not cached, load from disk and cache it
    let data = loadScoreDataFromDisk()
    _cachedScoreData = data
    return data
  }

  private static func saveScoreData(_ scoreData: ScoreData) {
    let url = getFileURL()

    do {
      let data = try JSONEncoder().encode(scoreData)
      try data.write(to: url)

      // Update cached data after successful save
      _cachedScoreData = scoreData
    } catch {
      print("Error saving score data: \(error)")
    }
  }

  static func initialize() {
    _cachedScoreData = loadScoreDataFromDisk()
    print("SaveUtil initialized with \(wordScores.count) words")
  }

  static var wordScores: [WordScore] {
    let scoreData = getScoreData()
    var allWords: [WordScore] = []

    for group in scoreData.groups {
      allWords.append(contentsOf: group.words)
    }

    // Return words in time order (most recent first)
    return allWords.sorted { $0.lastUpdated > $1.lastUpdated }
  }

  static func saveScore(word: String, score: Int) {
    var scoreData = getScoreData()
    let lowercasedWord = word.lowercased()

    var updatedWordScore: WordScore?
    var originalGroupIndex: Int?
    var wordIndexInGroup: Int?

    for (groupIndex, group) in scoreData.groups.enumerated() {
      if let index = group.words.firstIndex(where: { $0.word.lowercased() == lowercasedWord }) {
        var existing = group.words[index]
        existing.addScore(score)
        updatedWordScore = existing
        originalGroupIndex = groupIndex
        wordIndexInGroup = index
        break
      }
    }

    // If still not found, create new word
    if updatedWordScore == nil {
      updatedWordScore = WordScore(word: word, score: score)
    } else if let groupIndex = originalGroupIndex, let wordIndex = wordIndexInGroup {
      // Remove old version from group
      scoreData.groups[groupIndex].words.remove(at: wordIndex)
    }

    guard let updated = updatedWordScore else {
      print("Unexpected error updating word score.")
      return
    }

    // Add updated word to the correct group
    let newAverage = updated.averageScoreInt
    if let groupIndex = scoreData.groups.firstIndex(where: { $0.averageScoreInt == newAverage }) {
      scoreData.groups[groupIndex].words.append(updated)
    } else {
      print("Error: Could not find group for average score \(newAverage)")
      return
    }

    saveScoreData(scoreData)
  }

  static func loadScores() -> [ScoreGroup] {
    let scoreData = getScoreData()
    return scoreData.groups
  }

  static func loadWordsWithScore(_ targetScore: Int) -> [WordScore] {
    let scoreData = getScoreData()

    // Find the specific group with matching average score
    if let group = scoreData.groups.first(where: { $0.averageScoreInt == targetScore }) {
      // Return words in time order (most recent first)
      return group.words.sorted { $0.lastUpdated > $1.lastUpdated }
    }

    return []
  }

  static func loadWordsInScoreRange(min: Int, max: Int, lastElementThreshold: Int? = nil)
    -> [WordScore]
  {
    let scoreData = getScoreData()
    var matchingWords: [WordScore] = []

    for group in scoreData.groups {
      if group.averageScoreInt >= min && group.averageScoreInt <= max {
        matchingWords.append(contentsOf: group.words)
      }
      // Exception: if last element in scores is >= lastElementThreshold, include it too
      else {
        for word in group.words {
          if let lastScore = word.scores.last, let threshold = lastElementThreshold,
            lastScore >= threshold
          {
            matchingWords.append(word)
          }
        }
      }
    }

    // Return words in time order (most recent first)
    return matchingWords.sorted { $0.lastUpdated > $1.lastUpdated }
  }

  static func checkNew(daysThreshold: Int = 7) -> [WordScore] {
    let scoreData = getScoreData()
    let calendar = Calendar.current
    let cutoffDate = calendar.date(byAdding: .day, value: -daysThreshold, to: Date()) ?? Date()

    var newWords: [WordScore] = []

    for group in scoreData.groups {
      for word in group.words {
        // Check if word is truly new (only has one score) or hasn't been updated recently
        let isNewWord = word.scores.count == 1
        let isRecentlyUpdated = word.lastUpdated > cutoffDate

        if isNewWord || !isRecentlyUpdated {
          newWords.append(word)
        }
      }
    }

    // Return words sorted by last updated (most recent first)
    return newWords.sorted { $0.lastUpdated > $1.lastUpdated }
  }

  static func resetToInitialState() {
    let initialScoreData = ScoreData()
    saveScoreData(initialScoreData)
    print("Save data reset to initial state with \(initialScoreData.groups.count) empty groups.")
  }
}
