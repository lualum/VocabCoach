import Foundation
import SwiftUI

struct WordEntry {
  static var dict: [String: [String]] = [:]
  var word: String
  var definitions: [String]

  // MARK: - Word Selection State Management
  private static let recentWordsKey = "RecentWords"
  private static let lowScoreCycleKey = "LowScoreWordCycle"
  private static let lowScoreIndexKey = "LowScoreWordIndex"

  private static var _recentWords: [String]?
  private static var recentWords: [String] {
    get {
      if _recentWords == nil {
        _recentWords = UserDefaults.standard.array(forKey: recentWordsKey) as? [String] ?? []
      }
      return _recentWords!
    }
    set {
      _recentWords = newValue
      UserDefaults.standard.set(newValue, forKey: recentWordsKey)
    }
  }

  private static var _lowScoreWordCycle: [String]?
  private static var lowScoreWordCycle: [String] {
    get {
      if _lowScoreWordCycle == nil {
        _lowScoreWordCycle =
          UserDefaults.standard.array(forKey: lowScoreCycleKey) as? [String] ?? []
      }
      return _lowScoreWordCycle!
    }
    set {
      _lowScoreWordCycle = newValue
      UserDefaults.standard.set(newValue, forKey: lowScoreCycleKey)
    }
  }

  private static var lowScoreWordIndex: Int {
    get { UserDefaults.standard.integer(forKey: lowScoreIndexKey) }
    set { UserDefaults.standard.set(newValue, forKey: lowScoreIndexKey) }
  }

  func getDefs() -> [String] {
    definitions
  }

  func getDefString() -> String {
    definitions.joined(separator: "\n")
  }

  static func setWord(_ newWord: String) -> WordEntry {
    return WordEntry(
      word: newWord,
      definitions: dict[newWord] ?? ["No definition available"]
    )
  }

  static func loadWords(completion: @escaping () -> Void = {}) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard
        let url = Bundle.main.url(forResource: "words", withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let decoded = try? JSONDecoder().decode([String: [String]].self, from: data)
      else {
        print("Failed to load or parse words.json")
        DispatchQueue.main.async { completion() }
        return
      }
      DispatchQueue.main.async {
        dict = decoded
        completion()
      }
    }
  }

  // MARK: - Dictionary Management Functions

  /// Add a word with its definitions to the dictionary and save to words.json
  static func addWord(
    _ word: String, definitions: [String],
    completion: @escaping (Bool, String?) -> Void = { _, _ in }
  ) {
    guard !word.isEmpty && !definitions.isEmpty else {
      completion(false, "Word and definitions cannot be empty")
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      // Add to in-memory dictionary
      dict[word] = definitions

      // Save to file
      let success = saveDictionaryToFile()

      DispatchQueue.main.async {
        if success {
          completion(true, nil)
        } else {
          // Revert in-memory change if save failed
          dict.removeValue(forKey: word)
          completion(false, "Failed to save dictionary to file")
        }
      }
    }
  }

  /// Remove a word from the dictionary and save to words.json
  static func removeWord(
    _ word: String, completion: @escaping (Bool, String?) -> Void = { _, _ in }
  ) {
    guard dict[word] != nil else {
      completion(false, "Word not found in dictionary")
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      // Store the removed definitions in case we need to revert
      let removedDefinitions = dict[word]

      // Remove from in-memory dictionary
      dict.removeValue(forKey: word)

      // Save to file
      let success = saveDictionaryToFile()

      DispatchQueue.main.async {
        if success {
          // Also clean up any references in recent words and low score cycle
          cleanupWordReferences(word)
          completion(true, nil)
        } else {
          // Revert in-memory change if save failed
          dict[word] = removedDefinitions
          completion(false, "Failed to save dictionary to file")
        }
      }
    }
  }

  /// Reset dictionary to default words from defaultWords.json
  static func resetToDefaultWords(completion: @escaping (Bool, String?) -> Void = { _, _ in }) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard
        let url = Bundle.main.url(forResource: "defaultWords", withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let defaultDict = try? JSONDecoder().decode([String: [String]].self, from: data)
      else {
        DispatchQueue.main.async {
          completion(false, "Failed to load or parse defaultWords.json")
        }
        return
      }

      // Store current dictionary in case we need to revert
      let currentDict = dict

      // Update in-memory dictionary
      dict = defaultDict

      // Save to words.json
      let success = saveDictionaryToFile()

      DispatchQueue.main.async {
        if success {
          // Reset word selection state since dictionary has changed
          resetWordSelection()
          completion(true, nil)
        } else {
          // Revert to previous dictionary if save failed
          dict = currentDict
          completion(false, "Failed to save default dictionary to words.json")
        }
      }
    }
  }

  /// Get the current dictionary as a copy for external use
  static func getCurrentDictionary() -> [String: [String]] {
    return dict
  }

  /// Get count of words in dictionary
  static func getDictionaryWordCount() -> Int {
    return dict.count
  }

  // MARK: - Private Helper Functions

  private static func saveDictionaryToFile() -> Bool {
    guard
      let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        .first
    else {
      print("Could not find documents directory")
      return false
    }

    let wordsFileURL = documentsPath.appendingPathComponent("words.json")

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let jsonData = try encoder.encode(dict)
      try jsonData.write(to: wordsFileURL)

      print("Successfully saved dictionary to: \(wordsFileURL.path)")
      return true
    } catch {
      print("Failed to save dictionary: \(error)")
      return false
    }
  }

  private static func cleanupWordReferences(_ word: String) {
    // Remove from recent words
    var current = recentWords
    if let index = current.firstIndex(of: word) {
      current.remove(at: index)
      recentWords = current
    }

    // Remove from low score cycle
    var cycle = lowScoreWordCycle
    if let index = cycle.firstIndex(of: word) {
      cycle.remove(at: index)
      lowScoreWordCycle = cycle
      // Adjust index if needed
      if lowScoreWordIndex > index {
        lowScoreWordIndex -= 1
      } else if lowScoreWordIndex >= cycle.count {
        lowScoreWordIndex = 0
      }
    }
  }

  // MARK: - Original Functions (unchanged)

  static func randomWordEntry() -> WordEntry {
    // First priority: Check for saved words with score <= 4 (average <= 2.0)
    let allLowScoreWords = SaveUtil.loadWordsInScoreRange(min: 0, max: 4)
    let lowScoreWords = allLowScoreWords.filter { !recentWords.contains($0.word) }

    if !lowScoreWords.isEmpty {
      let selectedWord = selectFromLowScoreWords(lowScoreWords)

      if let definitions = dict[selectedWord.word] {
        addToRecentWords(selectedWord.word)
        return WordEntry(word: selectedWord.word, definitions: definitions)
      }
    }

    // Second priority: Chance for new word based on Settings.newWordsStudied
    let newWordChance = Settings.newWordsStudied
    let randomPercentage = Int.random(in: 1...100)

    if randomPercentage <= newWordChance {
      if let newWordEntry = selectNewWord() {
        addToRecentWords(newWordEntry.word)
        return newWordEntry
      }
    }

    // Third priority: Pick from remaining saved words (score > 4)
    let allHigherScoreWords = SaveUtil.loadWordsInScoreRange(
      min: 5, max: 6, lastElementThreshold: 3)
    let higherScoreWords = allHigherScoreWords.filter { !recentWords.contains($0.word) }

    if !higherScoreWords.isEmpty {
      let selectedWord = selectFromHigherScoreWords(higherScoreWords)

      if let definitions = dict[selectedWord.word] {
        addToRecentWords(selectedWord.word)
        return WordEntry(word: selectedWord.word, definitions: definitions)
      }
    }

    // Final fallback: Any word from dictionary (avoiding recent words)
    if let fallbackEntry = selectFallbackWord() {
      addToRecentWords(fallbackEntry.word)
      return fallbackEntry
    }

    return WordEntry(word: "_", definitions: [])
  }

  private static func selectFromLowScoreWords(_ lowScoreWords: [WordScore]) -> WordScore {
    // Use cycling approach to ensure all low-score words are covered
    if lowScoreWordCycle.isEmpty || lowScoreWordIndex >= lowScoreWordCycle.count {
      // Refresh cycle with current low-score words (already filtered to exclude recent ones)
      lowScoreWordCycle = lowScoreWords.map { $0.word }.shuffled()
      lowScoreWordIndex = 0
    }

    let selectedWordString = lowScoreWordCycle[lowScoreWordIndex]
    lowScoreWordIndex += 1

    // Find the WordScore object for the selected word
    return lowScoreWords.first { $0.word == selectedWordString }!
  }

  private static func selectNewWord() -> WordEntry? {
    let allSavedWords = Set(SaveUtil.wordScores.map { $0.word.lowercased() })

    // Filter dictionary to only unsaved words, excluding recent ones
    let newWords = dict.filter { word, _ in
      !allSavedWords.contains(word.lowercased()) && !recentWords.contains(word)
    }

    if !newWords.isEmpty, let randWord = newWords.keys.randomElement(),
      let randDefs = newWords[randWord]
    {
      return WordEntry(word: randWord, definitions: randDefs)
    }

    return nil
  }

  private static func selectFromHigherScoreWords(_ higherScoreWords: [WordScore]) -> WordScore {
    // Words are already filtered to exclude recent ones
    // Weight by inverse of score (higher score = lower weight)
    let weights = higherScoreWords.map { 1.0 / Double($0.averageScoreInt + 1) }
    return weightedRandomSelection(words: higherScoreWords, weights: weights)
  }

  private static func selectFallbackWord() -> WordEntry? {
    let availableWords = dict.filter { !recentWords.contains($0.key) }
    let wordsToUse = !availableWords.isEmpty ? availableWords : dict

    guard !wordsToUse.isEmpty,
      let randWord = wordsToUse.keys.randomElement(),
      let randDefs = wordsToUse[randWord]
    else {
      return nil
    }

    return WordEntry(word: randWord, definitions: randDefs)
  }

  private static func weightedRandomSelection(words: [WordScore], weights: [Double]) -> WordScore {
    let totalWeight = weights.reduce(0, +)
    let randomValue = Double.random(in: 0..<totalWeight)

    var currentWeight = 0.0
    for (index, weight) in weights.enumerated() {
      currentWeight += weight
      if randomValue < currentWeight {
        return words[index]
      }
    }

    return words.last!
  }

  private static func addToRecentWords(_ word: String) {
    var current = recentWords
    current.append(word)

    // Keep only the most recent words based on Settings.maxRecentWords
    let maxRecentWords = Settings.maxRecentWords
    if current.count > maxRecentWords {
      current.removeFirst(current.count - maxRecentWords)
    }

    recentWords = current
  }

  // Call this when user gets a word right to potentially remove it from recent tracking
  static func markWordAsLearned(_ word: String) {
    var current = recentWords
    if let index = current.firstIndex(of: word) {
      current.remove(at: index)
      recentWords = current
    }

    // Reset low-score cycle if this was part of it
    var cycle = lowScoreWordCycle
    if cycle.contains(word) {
      cycle.removeAll()
      lowScoreWordCycle = cycle
      lowScoreWordIndex = 0
    }
  }

  // Reset the system (useful for testing or user preference)
  static func resetWordSelection() {
    recentWords = []
    lowScoreWordCycle = []
    lowScoreWordIndex = 0
  }

  // Get statistics for debugging
  static func getSelectionStats() -> (recentCount: Int, cycleProgress: String) {
    let cycle = lowScoreWordCycle
    let progress = cycle.isEmpty ? "Not started" : "\(lowScoreWordIndex)/\(cycle.count)"
    return (recentWords.count, progress)
  }

  static func countDictionaryWordsWithScoreRange(min: Int, max: Int) -> Int {
    // Get all words with scores in the specified range
    let wordsWithScores = SaveUtil.loadWordsInScoreRange(min: min, max: max)

    // Count how many exist in the dictionary
    let count = wordsWithScores.reduce(0) { count, wordScore in
      return dict[wordScore.word] != nil ? count + 1 : count
    }

    return count
  }

  // Add this method to use SaveUtil.loadWordsInScoreRange
  static func loadWordsInScoreRange(min: Int, max: Int) -> [WordScore] {
    return SaveUtil.loadWordsInScoreRange(min: min, max: max)
  }
}
