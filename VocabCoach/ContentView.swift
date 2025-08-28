//
//  ContentView.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/1/25.
//

import Foundation
import SwiftUI

enum Page {
  case loading
  case home
  case dictionary
  case filteredDictionary
  case info
  case question
  case learn
  case dashboard
  case feedback
}

struct ContentView: View {
  @ObservedObject private var settings = Settings.shared
  @State private var currentPage: Page = .loading
  @State private var previousPage: Page = .loading
  @State public var showingSettings: Bool = false
  @State public var wordsStudied: Int = 0
  @State public var currentWord: WordEntry = WordEntry(
    word: "",
    definitions: []
  )
  @State public var correctCount: Int = 0
  @State public var incorrectCount: Int = 0
  @State public var attemptedCount: Int = 0
  @State public var unattemptedCount: Int = 0

  @State public var sumPoints: Int = 0
  @State public var totalPoints: Int = 0

  @State public var learnedPage: Bool = false

  var body: some View {
    ZStack {
      Background(currentPage: $currentPage)

      VStack {
        NavigationRow(
          currentPage: $currentPage,
          showingSettings: $showingSettings,
          sumPoints: $sumPoints,
          totalPoints: $totalPoints
        )
        Spacer()

        switch currentPage {
        case .loading:
          ProgressView("Loading words...")
            .onAppear {
              WordEntry.loadWords {
                currentWord = WordEntry.randomWordEntry()
                currentPage = .home
              }
              SaveUtil.initialize()
            }
        case .home:
          HomeView(
            currentPage: $currentPage,
            learnedPage: $learnedPage
          )
        case .dictionary:
          FullDictionaryView(currentPage: $currentPage, currentWord: $currentWord)
        case .filteredDictionary:
          FilteredDictionaryView(currentPage: $currentPage, currentWord: $currentWord)
        case .info:
          InfoView(currentPage: $currentPage)
        case .question:
          QuestionView(
            currentPage: $currentPage,
            currentWord: $currentWord,
            correctCount: $correctCount,
            incorrectCount: $incorrectCount,
            sumPoints: $sumPoints,
            totalPoints: $totalPoints,
            learnedPage: $learnedPage
          )
        case .learn:
          LearnView(
            currentPage: $currentPage,
            currentWord: $currentWord
          )
        case .dashboard:
          DashboardView(
            currentPage: $currentPage,
            correctCount: $correctCount,
            incorrectCount: $incorrectCount
          )
        case .feedback:
          FeedbackView()
        }
        Spacer()
      }
      .animation(.easeInOut(duration: 0.2), value: currentPage)

      // Settings popup overlay
      if showingSettings {
        SettingsPopup(
          showingSettings: $showingSettings, currentPage: $currentPage
        )
        .transition(.opacity.combined(with: .scale))
      }
    }
    .onChange(of: currentPage) { oldValue, newValue in
      previousPage = oldValue
    }
  }
}
