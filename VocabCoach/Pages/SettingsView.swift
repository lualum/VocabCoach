//
//  SettingsView.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/6/25.
//

import SwiftUI

class Settings: ObservableObject {
  private enum Keys {
    static let isDarkMode = "isDarkMode"
    static let newWordsStudied = "newWordsStudied"
    static let attemptedCount = "attemptedCount"
    static let unattemptedCount = "unattemptedCount"
    static let maxRecentWords = "maxRecentWords"
  }

  @Published var isDarkMode: Bool {
    didSet {
      UserDefaults.standard.set(isDarkMode, forKey: Keys.isDarkMode)
    }
  }

  @Published var newWordsStudied: Int {
    didSet {
      UserDefaults.standard.set(
        newWordsStudied,
        forKey: Keys.newWordsStudied
      )
    }
  }

  @Published var attemptedCount: Int {
    didSet {
      UserDefaults.standard.set(
        attemptedCount,
        forKey: Keys.attemptedCount
      )
    }
  }

  @Published var unattemptedCount: Int {
    didSet {
      UserDefaults.standard.set(
        unattemptedCount,
        forKey: Keys.unattemptedCount
      )
    }
  }

  @Published var maxRecentWords: Int {
    didSet {
      UserDefaults.standard.set(
        maxRecentWords,
        forKey: Keys.maxRecentWords
      )
    }
  }

  static let shared = Settings()

  static var isDarkMode: Bool {
    get { shared.isDarkMode }
    set { shared.isDarkMode = newValue }
  }

  static var newWordsStudied: Int {
    get { shared.newWordsStudied }
    set { shared.newWordsStudied = newValue }
  }

  static var attemptedCount: Int {
    get { shared.attemptedCount }
    set { shared.attemptedCount = newValue }
  }

  static var unattemptedCount: Int {
    get { shared.unattemptedCount }
    set { shared.unattemptedCount = newValue }
  }

  static var maxRecentWords: Int {
    get { shared.maxRecentWords }
    set { shared.maxRecentWords = newValue }
  }

  private init() {
    self.isDarkMode =
      UserDefaults.standard.object(forKey: Keys.isDarkMode) as? Bool
      ?? true
    self.newWordsStudied =
      UserDefaults.standard.object(forKey: Keys.newWordsStudied)
      as? Int ?? 20
    self.attemptedCount =
      UserDefaults.standard.object(forKey: Keys.attemptedCount)
      as? Int ?? 0
    self.unattemptedCount =
      UserDefaults.standard.object(forKey: Keys.unattemptedCount)
      as? Int ?? 0
    self.maxRecentWords =
      UserDefaults.standard.object(forKey: Keys.maxRecentWords)
      as? Int ?? 10
  }

  func resetToDefaults() {
    isDarkMode = true
    newWordsStudied = 20
    attemptedCount = 0
    unattemptedCount = 0
    maxRecentWords = 10
  }
}

struct SettingsPopup: View {
  @Binding var showingSettings: Bool
  @Binding var currentPage: Page
  @StateObject var settings = Settings.shared
  @State private var showingResetConfirmation = false

  var body: some View {
    ZStack {
      // Semi-transparent background
      Shade.background.opacity(0.8)
        .ignoresSafeArea()
        .onTapGesture {
          showingSettings = false
        }

      // Settings popup
      VStack(spacing: 0) {
        // Header
        HStack {
          Text("Settings")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(Shade.text)

          Spacer()

          Button(action: {
            showingSettings = false
          }) {
            Image(systemName: "xmark")
              .font(.body)
              .fontWeight(.bold)
              .foregroundColor(Shade.secondary)
              .frame(width: 30, height: 30)
              .clipShape(Circle())
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
          settings.isDarkMode
            ? Color(red: 0.2, green: 0.2, blue: 0.2)
            : Color(red: 0.8, green: 0.8, blue: 0.8)
        )

        // Settings content
        VStack(spacing: 20) {
          SettingRow(title: "Dark Mode", isOn: $settings.isDarkMode)

          Divider()
            .background(Color.gray.opacity(0.3))

          StepperSettingRow(
            title: "New Words Per Session",
            value: $settings.maxRecentWords,
            range: 1...50
          )

          Divider()
            .background(Color.gray.opacity(0.3))

          Button(action: {
            currentPage = .feedback
            showingSettings = false
          }) {
            HStack {
              Image(systemName: "exclamationmark.bubble")
                .font(.body)
              Text("Feedback")
                .font(.body)
                .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Gradient(colors: Shade.buttonPrimary))
            .cornerRadius(8)
          }
          .padding(.horizontal, 20)

          Button(action: {
            showingResetConfirmation = true
          }) {
            HStack {
              Image(systemName: "trash")
                .font(.body)
              Text("Reset Save")
                .font(.body)
                .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Shade.buttonSecondary)
            .cornerRadius(8)
          }
          .padding(.horizontal, 20)

          Spacer()
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
          settings.isDarkMode
            ? Color(red: 0.1, green: 0.1, blue: 0.1)
            : Color(red: 0.9, green: 0.9, blue: 0.9)
        )
      }
      .frame(
        width: UIScreen.main.bounds.width * 0.85,
        height: UIScreen.main.bounds.height * 0.6
      )
      .cornerRadius(15)
      .shadow(radius: 20)

      // Reset confirmation popup
      if showingResetConfirmation {
        ResetConfirmationPopup(
          showingConfirmation: $showingResetConfirmation
        )
      }
    }
    .animation(.easeInOut(duration: 0.3), value: showingSettings)
  }
}

struct ResetConfirmationPopup: View {
  @Binding var showingConfirmation: Bool
  @ObservedObject var settings = Settings.shared

  var body: some View {
    ZStack {
      // Semi-transparent background
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture {
          showingConfirmation = false
        }

      // Confirmation popup
      VStack(spacing: 20) {
        VStack(spacing: 10) {
          Image(systemName: "exclamationmark.triangle")
            .font(.title)
            .foregroundColor(.red)

          Text("Are you sure?")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(Shade.text)

          Text(
            "This will permanently delete all your progress and reset the app to its initial state. This action cannot be undone."
          )
          .font(.body)
          .foregroundColor(Shade.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 10)
        }

        HStack(spacing: 15) {
          Button(action: {
            showingConfirmation = false
          }) {
            Text("Cancel")
              .font(.body)
              .fontWeight(.medium)
              .foregroundColor(Shade.text)
              .padding(.vertical, 12)
              .padding(.horizontal, 25)
              .background(Color.gray.opacity(0.2))
              .cornerRadius(8)
          }

          Button(action: {
            SaveUtil.resetToInitialState()
            showingConfirmation = false
          }) {
            Text("Reset")
              .font(.body)
              .fontWeight(.medium)
              .foregroundColor(.white)
              .padding(.vertical, 12)
              .padding(.horizontal, 25)
              .background(Color.red)
              .cornerRadius(8)
          }
        }
      }
      .padding(25)
      .background(
        settings.isDarkMode
          ? Color(red: 0.15, green: 0.15, blue: 0.15)
          : Color.white
      )
      .cornerRadius(15)
      .shadow(radius: 10)
      .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
    }
    .animation(.easeInOut(duration: 0.2), value: showingConfirmation)
  }
}

struct SettingRow: View {
  let title: String
  @Binding var isOn: Bool
  @ObservedObject var settings = Settings.shared

  var body: some View {
    HStack {
      Text(title)
        .font(.body)
        .foregroundColor(Shade.text)

      Spacer()

      Toggle("", isOn: $isOn)
        .toggleStyle(SwitchToggleStyle(tint: .green))
        .scaleEffect(0.8)
    }
    .padding(.horizontal, 20)
  }
}

struct StepperSettingRow: View {
  let title: String
  @Binding var value: Int
  @ObservedObject var settings = Settings.shared
  let range: ClosedRange<Int>

  var body: some View {
    HStack {
      Text(title)
        .font(.body)
        .foregroundColor(Shade.text)

      Spacer()

      HStack(spacing: 15) {
        Button(action: {
          if value > range.lowerBound {
            value -= 1
          }
        }) {
          Image(systemName: "minus.circle.fill")
            .font(.title3)
            .foregroundColor(
              value > range.lowerBound ? .red : .gray
            )
        }
        .disabled(value <= range.lowerBound)

        Text("\(value)")
          .font(.body)
          .fontWeight(.bold)
          .foregroundColor(Shade.text)
          .frame(minWidth: 30)

        Button(action: {
          if value < range.upperBound {
            value += 1
          }
        }) {
          Image(systemName: "plus.circle.fill")
            .font(.title3)
            .foregroundColor(
              value < range.upperBound ? .green : .gray
            )
        }
        .disabled(value >= range.upperBound)
      }
    }
    .padding(.horizontal, 20)
  }
}
