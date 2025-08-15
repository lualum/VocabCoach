//
//  QuestionView.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/1/25.
//

import Foundation
import SwiftUI

enum QuestionResult: Equatable {
  case none
  case loading
  case success(APIResponse)
  case error
  case connectionError

  static func == (lhs: QuestionResult, rhs: QuestionResult) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none), (.loading, .loading), (.error, .error),
      (.connectionError, .connectionError):
      return true
    case (.success(let lhsResponse), .success(let rhsResponse)):
      return lhsResponse.usage == rhsResponse.usage
        && lhsResponse.feedback == rhsResponse.feedback
        && lhsResponse.grammar == rhsResponse.grammar
    default:
      return false
    }
  }
}

struct APIResponse: Codable, Equatable {
  let grammar: Bool
  let usage: String
  let feedback: String

  enum CodingKeys: String, CodingKey {
    case grammar
    case usage
    case feedback
  }
}

struct QuestionView: View {
  @ObservedObject private var settings = Settings.shared
  @Binding var currentPage: Page
  @Binding var currentWord: WordEntry

  @State public var result: QuestionResult = .none
  @State public var userInput: String = ""
  @State public var apiResponse: APIResponse?

  @Binding var correctCount: Int
  @Binding var incorrectCount: Int

  @Binding var sumPoints: Int
  @Binding var totalPoints: Int

  @Binding var learnedPage: Bool

  var body: some View {
    ZStack {
      if result == .none || result == .loading || result == .connectionError {
        // Question input screen
        VStack(spacing: 40) {
          // Word title
          Text(currentWord.word)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Shade.secondary)
            .underline()

          // Connection error message
          if result == .connectionError {
            HStack(spacing: 8) {
              Image(systemName: "wifi.slash")
                .foregroundColor(.red)
                .font(.title2)
              Text("Check your connection and try again")
                .font(.body)
                .foregroundColor(.red)
                .fontWeight(.medium)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 40)
          }

          // Input area with placeholder
          ZStack(alignment: .topLeading) {
            TextEditor(text: $userInput)
              .scrollContentBackground(.hidden)
              .padding()
              .background(Color.gray.opacity(0.2))
              .cornerRadius(12)
              .font(.body)
              .foregroundColor(Shade.secondary)
              .padding(.horizontal, 40)
              .frame(maxHeight: .infinity)

            if userInput.isEmpty {
              Text("Write a sentence using the word above")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.horizontal, 56)
                .padding(.vertical, 24)
                .allowsHitTesting(false)
            }
          }

          // Action buttons
          VStack(spacing: 16) {
            Button(action: {
              submitAnswer()
              Settings.attemptedCount += 1
            }) {
              HStack {
                if result == .loading {
                  ProgressView()
                    .progressViewStyle(
                      CircularProgressViewStyle(
                        tint: Shade.secondary
                      )
                    )
                    .scaleEffect(0.8)
                } else {
                  Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                }
                Text(
                  result == .loading
                    ? "Submitting..." : "Submit"
                )
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
              }
              .padding()
              .frame(maxWidth: .infinity)
              .background(
                result == .loading ? Color.gray : Color.green
              )
              .cornerRadius(12)
            }
            .disabled(
              result == .loading
                || userInput.trimmingCharacters(
                  in: .whitespacesAndNewlines
                ).isEmpty
            )

            Button(action: {
              result = .success(
                APIResponse(
                  grammar: false,
                  usage: "incorrect",
                  feedback: currentWord.getDefString()
                )
              )
              apiResponse = APIResponse(
                grammar: false,
                usage: "incorrect",
                feedback: currentWord.getDefString()
              )
              Settings.unattemptedCount += 1
              incorrectCount += 1
              totalPoints += 3
            }) {
              HStack {
                Image(systemName: "arrow.right.circle.fill")
                  .foregroundColor(.white)
                Text("Skip")
                  .font(.title3)
                  .fontWeight(.bold)
                  .foregroundColor(Color.white)
              }
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.blue)
              .cornerRadius(12)
            }
            .disabled(result == .loading)
          }
          .padding(.horizontal, 40)
          .padding(.bottom, 40)
        }
      } else {
        // Detailed grading screen
        VStack(spacing: 20) {
          // Word title
          Text(currentWord.word)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Shade.text)
            .underline()

          // User input display
          ScrollView {
            Text(userInput)
              .font(.body)
              .foregroundColor(Shade.text)
              .padding()
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .background(Color.gray.opacity(0.2))
          .cornerRadius(12)
          .padding(.horizontal, 20)
          .frame(height: 100)

          // Grading criteria cards
          if let response = apiResponse {
            VStack(spacing: 12) {
              // Header
              Text("Scoring")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Shade.secondary)
                .padding(.bottom, 10)

              HStack(spacing: 12) {
                // Usage card
                UsageGradingCard(
                  title: "Usage",
                  isCorrect: response.usage,
                  icon: "lightbulb"
                )

                // Grammar card
                GradingCard(
                  title: "Grammar",
                  isCorrect: response.grammar,
                  icon: "text.book.closed"
                )
              }

              // Overall rating stars
              HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                  Image(
                    systemName: index
                      < getStarRating(response)
                      ? "star.fill" : "star"
                  )
                  .foregroundColor(
                    index < getStarRating(response)
                      ? .yellow : .gray
                  )
                  .font(.title2)
                }
              }
              .padding(.top, 10)

              // Feedback section
              VStack(spacing: 8) {
                HStack(spacing: 3) {
                  Text("Feedback")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                  Button(action: {
                    currentPage = .info
                  }) {
                    Image(systemName: "info.circle")
                      .font(.headline)
                      .foregroundColor(.white)
                      .frame(width: 20, height: 20)
                  }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)

                ScrollView {
                  Text(response.feedback)
                    .font(.body)
                    .foregroundColor(Shade.secondary)
                    .padding()
                    .frame(
                      maxWidth: .infinity,
                      alignment: .leading
                    )
                }
                .background(Color.blue.opacity(0.3))
                .cornerRadius(8)
                .frame(
                  maxWidth: .infinity,
                  maxHeight: .infinity
                )
              }
              .padding(.top, 10)
            }
            .padding(.horizontal, 20)
          }

          HStack(spacing: 16) {
            Button(action: {
              currentPage = .learn
              learnedPage = true
            }) {
              HStack {
                Image(systemName: "book.circle.fill")
                  .foregroundColor(.white)
                Text("Learn")
                  .font(.title3)
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
              }
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(Color.blue)
              .cornerRadius(16)
            }

            Button(action: {
              resetQuestion()
            }) {
              HStack {
                Image(systemName: "arrow.right.circle.fill")
                  .foregroundColor(.white)
                Text("Continue")
                  .font(.title3)
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
              }
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(Color.green)
              .cornerRadius(16)
            }
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 20)

        }
      }
    }.onAppear {
      if learnedPage {
        resetQuestion()
        learnedPage = false
      }
    }
  }

  private func submitAnswer() {
    guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      return
    }

    result = .loading

    guard
      let url = URL(
        string: "https://gemini-proxy.VocabMateapp.workers.dev/"
      )
    else {
      result = .error
      return
    }

    let requestBody = [
      "word": currentWord.word,
      "sentence": userInput,
    ]

    guard
      let jsonData = try? JSONSerialization.data(
        withJSONObject: requestBody
      )
    else {
      result = .error
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if let error = error {
          print("Network error: \(error)")
          result = .connectionError
          return
        }

        guard let data = data else {
          print("No data received")
          result = .connectionError
          return
        }

        do {
          let decodedResponse = try JSONDecoder().decode(
            APIResponse.self,
            from: data
          )

          apiResponse = decodedResponse
          result = .success(decodedResponse)

          print("API Response - Usage: \(decodedResponse.usage)")
          print("Grammar correct: \(decodedResponse.grammar)")
          print("Feedback: \(decodedResponse.feedback)")

          SaveUtil.saveScore(
            word: currentWord.word,
            score: getStarRating(decodedResponse)
          )

          if (getStarRating(decodedResponse)) == 3 {
            correctCount += 1
          } else {
            incorrectCount += 1
          }

          sumPoints += getStarRating(decodedResponse)
          totalPoints += 3

        } catch {
          print("JSON decoding error: \(error)")
          result = .error
        }
      }
    }.resume()
  }

  private func getStarRating(_ response: APIResponse) -> Int {
    let usageStars: Int
    switch response.usage {
    case "correct":
      usageStars = 2
    case "partial":
      usageStars = 1
    default:
      usageStars = 0
    }

    return [
      response.grammar
    ].filter { $0 }.count + usageStars
  }

  private func resetQuestion() {
    result = .none
    userInput = ""
    apiResponse = nil
    currentWord = WordEntry.randomWordEntry()
  }
}

struct GradingCard: View {
  let title: String
  let isCorrect: Bool
  let icon: String

  var body: some View {
    VStack(spacing: 4) {
      HStack(spacing: 4) {
        Image(systemName: icon)
          .font(.title3)
          .foregroundColor(isCorrect ? .green : .red)

        Text(title + ":")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(Shade.secondary)
      }
      // Status indicator
      Image(
        systemName: isCorrect
          ? "checkmark.circle.fill" : "xmark.circle.fill"
      )
      .foregroundColor(isCorrect ? .green : .red)
      .font(.title3)
    }
    .padding(6)
    .frame(maxWidth: .infinity, maxHeight: 70)
    .background(Color.gray.opacity(0.2))
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(isCorrect ? Color.green : Color.red, lineWidth: 2)
    )
  }
}

struct UsageGradingCard: View {
  let title: String
  let isCorrect: String
  let icon: String

  var color: Color {
    switch isCorrect {
    case "correct": return .green
    case "partial": return .yellow
    default: return .red
    }
  }
  var resultIcon: String {
    switch isCorrect {
    case "correct": return "checkmark.circle.fill"
    case "partial": return "questionmark.circle.fill"
    default: return "xmark.circle.fill"
    }
  }

  var body: some View {
    VStack(spacing: 4) {
      HStack(spacing: 4) {
        Image(systemName: icon)
          .font(.title3)
          .foregroundColor(color)

        Text(title + ":")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(Shade.secondary)
      }
      // Status indicator
      Image(
        systemName: resultIcon
      )
      .foregroundColor(color)
      .font(.title3)
    }
    .padding(6)
    .frame(maxWidth: .infinity, maxHeight: 70)
    .background(Color.gray.opacity(0.2))
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(color, lineWidth: 2)
    )
  }
}
