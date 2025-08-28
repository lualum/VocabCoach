//
//  LearnView.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/9/25.
//

import SwiftUI

struct LearnView: View {
  @ObservedObject private var settings = Settings.shared
  @Binding var currentPage: Page
  @Binding var currentWord: WordEntry

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        // Title
        Text(currentWord.word)
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(Shade.secondary)
          .padding(.top, 40)
          .padding(.bottom, 30)

        // Content sections
        VStack(alignment: .leading, spacing: 25) {
          // Parts of Speech section
          VStack(alignment: .leading, spacing: 8) {
            Text("Parts of Speech of \(currentWord.word)")
              .font(.title2)
              .fontWeight(.semibold)
              .foregroundColor(Shade.secondary)

            Text(getPartsOfSpeech())
              .font(.body)
              .foregroundColor(.gray)
          }

          // Meaning section
          VStack(alignment: .leading, spacing: 8) {
            Text("Meaning of \(currentWord.word)")
              .font(.title2)
              .fontWeight(.semibold)
              .foregroundColor(Shade.secondary)

            Text(getMeaning())
              .font(.body)
              .foregroundColor(.gray)
          }

          // Sample sentence section
          if let sampleSentence = getSampleSentence() {
            VStack(alignment: .leading, spacing: 8) {
              Text("Sample sentence using \(currentWord.word)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Shade.secondary)

              Text(sampleSentence)
                .font(.body)
                .foregroundColor(.gray)
            }
          }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)

        Spacer()

        // Buttons
        VStack(spacing: 16) {
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
            .background(Gradient(colors: Shade.buttonPrimary))
            .cornerRadius(12)

          }

          Button(action: {
            currentWord = WordEntry.randomWordEntry()
            currentPage = .question
          }) {
            HStack(spacing: 12) {
              Image(systemName: "play.fill")
              Text("Continue")
            }
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Shade.buttonSecondary)
            .cornerRadius(12)
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
      }
    }
  }

  // Helper function to extract parts of speech
  private func getPartsOfSpeech() -> String {
    let defs = currentWord.getDefs()
    var partsOfSpeech: Set<String> = []

    for def in defs {
      // Extract part of speech from definition format like "(v.)" or "(n.)"
      if let match = def.range(of: "\\([a-z]+\\.\\)", options: .regularExpression) {
        let partOfSpeech = String(def[match])
          .trimmingCharacters(in: CharacterSet(charactersIn: "()."))
        partsOfSpeech.insert(partOfSpeech)
      }
    }

    // Convert abbreviations to full words
    let fullForms = partsOfSpeech.map { abbrev in
      switch abbrev {
      case "v": return "verb"
      case "n": return "noun"
      case "adj": return "adjective"
      case "adv": return "adverb"
      default: return abbrev
      }
    }

    return fullForms.joined(separator: ", ")
  }

  // Helper function to extract meaning
  private func getMeaning() -> String {
    let defs = currentWord.getDefs()
    guard let firstDef = defs.first else { return "" }

    // Extract the meaning part after the part of speech
    let pattern = "\\([a-z]+\\.\\)\\s*(.+?)\\s*\\("
    if let range = firstDef.range(of: pattern, options: .regularExpression) {
      let fullMatch = String(firstDef[range])
      // Extract just the meaning part
      let meaningPattern = "\\)\\s*(.+?)\\s*\\("
      if let meaningRange = fullMatch.range(of: meaningPattern, options: .regularExpression) {
        let meaning = String(fullMatch[meaningRange])
          .trimmingCharacters(in: CharacterSet(charactersIn: ") ("))
        return meaning
      }
    }

    // Fallback: try to extract meaning after part of speech
    if let parenIndex = firstDef.firstIndex(of: ")") {
      let afterParen = String(firstDef[firstDef.index(after: parenIndex)...])
      if let exampleStart = afterParen.firstIndex(of: "(") {
        return String(afterParen[..<exampleStart]).trimmingCharacters(in: .whitespaces)
      }
      return afterParen.trimmingCharacters(in: .whitespaces)
    }

    return firstDef
  }

  // Helper function to extract sample sentence
  private func getSampleSentence() -> String? {
    let defs = currentWord.getDefs()
    guard let firstDef = defs.first else { return nil }

    // Look for text in parentheses at the end (sample sentence)
    let pattern = "\\(([^)]+)\\)$"
    if let range = firstDef.range(of: pattern, options: .regularExpression) {
      let sentence = String(firstDef[range])
        .trimmingCharacters(in: CharacterSet(charactersIn: "()"))
      return sentence
    }

    return nil
  }
}
