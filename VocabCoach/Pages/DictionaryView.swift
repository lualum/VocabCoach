//
//  FilteredDictionaryView.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/11/25.
//

import SwiftUI

// Singleton to manage filter state across navigation
class FilteredDictionaryManager: ObservableObject {
  static let shared = FilteredDictionaryManager()

  @Published var scoreRange: (min: Int, max: Int, title: String) = (0, 0, "")

  private init() {}

  func setFilter(min: Int, max: Int, title: String) {
    scoreRange = (min: min, max: max, title: title)
  }
}

// Word row component for displaying individual words
struct WordRowView: View {
  @ObservedObject private var settings = Settings.shared

  @Binding var currentPage: Page
  @Binding var currentWord: WordEntry

  let word: WordEntry
  let scores: [Int]
  let color: Color

  private var averageScore: Double {
    guard !scores.isEmpty else { return 0.0 }
    let sum = scores.reduce(0, +)
    return Double(sum) / Double(scores.count)
  }

  var body: some View {
    HStack(spacing: 16) {
      // Score indicator circle
      Circle()
        .fill(color)
        .frame(width: 12, height: 12)

      VStack(alignment: .leading, spacing: 4) {
        // Word name
        Text(word.word)
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(Shade.text)

        // Score info
        HStack(spacing: 8) {
          Text("Avg: \(averageScore, specifier: "%.1f")")
            .font(.headline)
            .foregroundColor(.gray)

          Text("Scores: \(scores.map(String.init).joined(separator: ", "))")
            .font(.headline)
            .foregroundColor(.gray)
        }
      }

      Spacer()

      // Go to Learn
      Button(action: {
        currentWord = word
        currentPage = .learn
      }) {
        Image(systemName: "chevron.right")
          .foregroundColor(.gray)
          .font(.caption)
      }

    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(Color.clear)
  }
}

struct FilteredDictionaryView: View {
  @ObservedObject private var settings = Settings.shared

  @Binding var currentPage: Page
  @Binding var currentWord: WordEntry
  @StateObject private var filterManager = FilteredDictionaryManager.shared
  @State private var filteredWords: [WordScore] = []

  // Color definitions (same as DictionaryView)
  private let workingColors = [
    Color(red: 0.87, green: 0.49, blue: 0.42),  // Score 0
    Color(red: 0.92, green: 0.60, blue: 0.60),  // Score 1
    Color(red: 0.98, green: 0.80, blue: 0.61),  // Score 2
    Color(red: 1.00, green: 0.90, blue: 0.60),  // Score 3
    Color(red: 1.00, green: 0.85, blue: 0.40),  // Score 4
  ]

  private let learnedColors = [
    Color(red: 0.54, green: 0.70, blue: 0.89),  // Score 5
    Color(red: 0.79, green: 0.85, blue: 0.97),  // Score 6
  ]

  var body: some View {
    VStack(spacing: 0) {

      Text(filterManager.scoreRange.title + " (\(filteredWords.count))")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(Shade.text)

        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)

      // Scrollable Content
      if filteredWords.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "book.closed")
            .font(.system(size: 48))
            .foregroundColor(.gray)

          Text("No words in this category yet")
            .font(.headline)
            .foregroundColor(.gray)

          Text("Start learning to see words here!")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(filteredWords.sorted(by: { $0.word < $1.word }), id: \.word) { wordScore in
              WordRowView(
                currentPage: $currentPage,
                currentWord: $currentWord,
                word: WordEntry.setWord(wordScore.word),
                scores: wordScore.scores,
                color: getColorForScore(wordScore.averageScoreInt)
              )

              // Add divider between items (except for the last one)
              if wordScore.word != filteredWords.last?.word {
                Divider()
                  .padding(.horizontal, 20)
              }
            }
          }
          .padding(.bottom, 40)
        }
      }

      Spacer()
      Button(action: {
        currentPage = .dashboard
      }) {
        HStack(spacing: 12) {
          Image(systemName: "square.grid.2x2.fill")
          Text("Dashboard")
        }
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue)
        .cornerRadius(12)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
    }
    .onAppear {
      loadFilteredWords()
    }
  }

  private func loadFilteredWords() {
    let range = filterManager.scoreRange
    // Use SaveUtil.loadWordsInScoreRange as requested
    filteredWords = SaveUtil.loadWordsInScoreRange(min: range.min, max: range.max)
  }

  private func getColorForScore(_ score: Int) -> Color {
    if score >= 5 {
      return score >= 6 ? learnedColors[1] : learnedColors[0]
    } else {
      let index = min(score, workingColors.count - 1)
      return workingColors[index]
    }
  }
}
