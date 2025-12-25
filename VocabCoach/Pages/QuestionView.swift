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

// Custom hand-drawn flag shape
struct HandDrawnFlag: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    // Create an irregular, hand-drawn looking flag shape
    let width = rect.width
    let height = rect.height

    // Start from bottom left with slight irregularity
    path.move(to: CGPoint(x: 2, y: height - 1))

    // Left edge with hand-drawn wobble
    path.addCurve(
      to: CGPoint(x: 1, y: height * 0.7),
      control1: CGPoint(x: 0.5, y: height - 3),
      control2: CGPoint(x: 1.5, y: height * 0.8)
    )

    path.addCurve(
      to: CGPoint(x: 2, y: height * 0.3),
      control1: CGPoint(x: 0, y: height * 0.6),
      control2: CGPoint(x: 2.5, y: height * 0.4)
    )

    path.addCurve(
      to: CGPoint(x: 1, y: 2),
      control1: CGPoint(x: 1.5, y: height * 0.2),
      control2: CGPoint(x: 0.5, y: 4)
    )

    // Top edge with wavy hand-drawn effect
    path.addCurve(
      to: CGPoint(x: width * 0.25, y: 1),
      control1: CGPoint(x: width * 0.1, y: 0.5),
      control2: CGPoint(x: width * 0.2, y: 2)
    )

    path.addCurve(
      to: CGPoint(x: width * 0.5, y: 0.5),
      control1: CGPoint(x: width * 0.3, y: 0),
      control2: CGPoint(x: width * 0.45, y: 1.5)
    )

    path.addCurve(
      to: CGPoint(x: width * 0.75, y: 1.5),
      control1: CGPoint(x: width * 0.55, y: 0),
      control2: CGPoint(x: width * 0.7, y: 0.5)
    )

    path.addCurve(
      to: CGPoint(x: width - 2, y: 2),
      control1: CGPoint(x: width * 0.8, y: 2.5),
      control2: CGPoint(x: width * 0.9, y: 1)
    )

    // Right edge with wavy flag effect
    path.addCurve(
      to: CGPoint(x: width + 1, y: height * 0.2),
      control1: CGPoint(x: width - 1, y: height * 0.1),
      control2: CGPoint(x: width + 2, y: height * 0.15)
    )

    path.addCurve(
      to: CGPoint(x: width - 1, y: height * 0.4),
      control1: CGPoint(x: width - 1, y: height * 0.25),
      control2: CGPoint(x: width + 1, y: height * 0.35)
    )

    path.addCurve(
      to: CGPoint(x: width + 2, y: height * 0.6),
      control1: CGPoint(x: width + 1, y: height * 0.45),
      control2: CGPoint(x: width - 0.5, y: height * 0.55)
    )

    path.addCurve(
      to: CGPoint(x: width - 1, y: height * 0.8),
      control1: CGPoint(x: width, y: height * 0.65),
      control2: CGPoint(x: width + 1, y: height * 0.75)
    )

    // Bottom right with hand-drawn irregularity
    path.addCurve(
      to: CGPoint(x: width - 2, y: height - 2),
      control1: CGPoint(x: width + 0.5, y: height * 0.85),
      control2: CGPoint(x: width - 3, y: height - 1)
    )

    // Bottom edge
    path.addCurve(
      to: CGPoint(x: width * 0.7, y: height - 1),
      control1: CGPoint(x: width * 0.85, y: height - 3),
      control2: CGPoint(x: width * 0.75, y: height + 1)
    )

    path.addCurve(
      to: CGPoint(x: width * 0.4, y: height - 2),
      control1: CGPoint(x: width * 0.65, y: height - 0.5),
      control2: CGPoint(x: width * 0.45, y: height - 3)
    )

    path.addCurve(
      to: CGPoint(x: 2, y: height - 1),
      control1: CGPoint(x: width * 0.3, y: height - 1),
      control2: CGPoint(x: width * 0.1, y: height - 2.5)
    )

    path.closeSubpath()

    return path
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

  // New state for flag animation
  @State private var isNewWord: Bool = false
  @State private var showNewFlag: Bool = false
  @State private var flagScale: CGFloat = 0.1
  @State private var flagRotation: Double = 0
  @State private var flagOpacity: Double = 0

  var body: some View {
    ZStack {
      if result == .none || result == .loading || result == .connectionError {
        // Question input screen
        VStack(spacing: 40) {
          // Word title with New flag
          ZStack {
            Text(currentWord.word)
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(Shade.secondary)
              .underline()

            // Hand-drawn New! Flag
            // if showNewFlag && isNewWord {
            //   HStack {
            //     Spacer()
            //     VStack {
            //       ZStack {
            //         // Hand-drawn flag background with multiple layers for depth
            //         HandDrawnFlag()
            //           .fill(
            //             LinearGradient(
            //               colors: [Color.red.opacity(0.9), Color.orange.opacity(0.8)],
            //               startPoint: .topLeading,
            //               endPoint: .bottomTrailing
            //             )
            //           )
            //           .frame(width: 70, height: 32)
            //           .overlay(
            //             // Add hand-drawn border effect
            //             HandDrawnFlag()
            //               .stroke(
            //                 LinearGradient(
            //                   colors: [Color.red.opacity(0.4), Color.orange.opacity(0.6)],
            //                   startPoint: .leading,
            //                   endPoint: .trailing
            //                 ),
            //                 style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            //               )
            //           )
            //           .overlay(
            //             // Add inner sketch lines for hand-drawn effect
            //             HandDrawnFlag()
            //               .stroke(
            //                 Color.white.opacity(0.3),
            //                 style: StrokeStyle(
            //                   lineWidth: 0.8,
            //                   lineCap: .round,
            //                   lineJoin: .round,
            //                   dash: [2, 3]
            //                 )
            //               )
            //               .scaleEffect(0.85)
            //           )

            //         // Hand-drawn style text with slight irregularity
            //         Text("NEW!")
            //           .font(.system(size: 11, weight: .heavy, design: .rounded))
            //           .foregroundColor(.white)
            //           .shadow(color: .black.opacity(0.3), radius: 1, x: 0.5, y: 0.5)
            //           .rotationEffect(.degrees(Double.random(in: -1...1))) // Slight random rotation for each letter effect
            //           .scaleEffect(x: 1.05, y: 0.95) // Slightly squished for hand-drawn feel
            //       }
            //       .scaleEffect(flagScale)
            //       .rotationEffect(.degrees(flagRotation))
            //       .opacity(flagOpacity)
            //       .shadow(color: .red.opacity(0.4), radius: 6, x: 2, y: 3)
            //       // Add a subtle "paper texture" shadow
            //       .shadow(color: .orange.opacity(0.2), radius: 2, x: -1, y: -1)

            //       Spacer()
            //     }
            //     .padding(.leading, 8)
            //   }
            //   .offset(x: 45, y: -18)
            // }
          }

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
              Text("Write a sentence using the word above that demonstrates its meaning and usage.")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.horizontal, 56)
                .frame(height: 56)
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
                  Image(systemName: "tray.and.arrow.up.fill")
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
                LinearGradient(
                  gradient: Gradient(colors: Shade.buttonPrimary),
                  startPoint: .leading,
                  endPoint: .trailing
                )
                .opacity(result == .loading ? 0.5 : 1.0)  // adjust opacity here
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
                Image(systemName: "forward")
                  .foregroundColor(.white)
                Text("Skip")
                  .font(.title3)
                  .fontWeight(.bold)
                  .foregroundColor(Color.white)
              }
              .padding()
              .frame(maxWidth: .infinity)
              .background(Shade.buttonSecondary)
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
                HStack(spacing: 12) {

                  Button(action: {
                    currentPage = .info
                  }) {
                    Image(systemName: "info.circle")
                      .font(.headline)
                      .foregroundColor(.white)
                      .frame(width: 20, height: 20)
                  }

                  Text("Feedback")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                }
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(Shade.buttonSecondary)
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
                .background(Shade.buttonSecondary.opacity(0.3))
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
                Image(systemName: "book")
                  .foregroundColor(.white)
                Text("Learn")
                  .font(.title3)
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
              }
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(Shade.buttonSecondary)
              .cornerRadius(16)
            }

            Button(action: {
              resetQuestion()
            }) {
              HStack {
                Image(systemName: "arrow.right.square.fill")
                  .foregroundColor(.white)
                Text("Continue")
                  .font(.title3)
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
              }
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(
                LinearGradient(
                  gradient: Gradient(colors: Shade.buttonPrimary),
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )
              .cornerRadius(16)
            }
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 20)

        }
      }
    }
    .onAppear {
      if learnedPage {
        resetQuestion()
        learnedPage = false
      } else {
        checkIfWordIsNew()
      }
    }
    .onChange(of: currentWord.word) { _ in
      checkIfWordIsNew()
    }
  }

  private func checkIfWordIsNew() {
    // Get new words from SaveUtil
    let newWords = SaveUtil.checkNew()

    // Check if current word is in the new words list
    isNewWord = newWords.contains { wordScore in
      wordScore.word.lowercased() == currentWord.word.lowercased()
    }

    if isNewWord {
      animateNewFlag()
    } else {
      showNewFlag = false
    }
  }

  private func animateNewFlag() {
    showNewFlag = true

    // Reset animation state
    flagScale = 0.1
    flagRotation = -15  // Start with more dramatic rotation for hand-drawn feel
    flagOpacity = 0

    // Animate entrance with spring effect (more bouncy for hand-drawn style)
    withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.1)) {
      flagScale = 1.0
      flagOpacity = 1.0
    }

    // More exaggerated rotation wiggle for hand-drawn effect
    withAnimation(.easeInOut(duration: 0.4).delay(0.2)) {
      flagRotation = 8
    }

    withAnimation(.easeInOut(duration: 0.4).delay(0.6)) {
      flagRotation = -3
    }

    withAnimation(.easeInOut(duration: 0.3).delay(1.0)) {
      flagRotation = 1
    }

    // Subtle irregular pulsing effect for organic feel
    withAnimation(.easeInOut(duration: 1.2).delay(1.8).repeatForever(autoreverses: true)) {
      flagScale = 1.03
    }

    // Add slight rotation variation for living feel
    withAnimation(.easeInOut(duration: 2.0).delay(2.5).repeatForever(autoreverses: true)) {
      flagRotation = -1
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
        string: "https://gemini-proxy.vocabmateapp.workers.dev/"
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
  @ObservedObject private var settings = Settings.shared
  let title: String
  let isCorrect: Bool
  let icon: String

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(isCorrect ? .green : .red)

      Text(title + ":")
        .font(.title3)
        .fontWeight(.semibold)
        .foregroundColor(Shade.secondary)
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
  @ObservedObject private var settings = Settings.shared
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
    HStack(spacing: 4) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(color)

      Text(title + ":")
        .font(.title3)
        .fontWeight(.semibold)
        .foregroundColor(Shade.secondary)
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
