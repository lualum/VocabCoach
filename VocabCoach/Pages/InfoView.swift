//
//  InfoView.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/7/25.
//

import SwiftUI

struct InfoView: View {
  @ObservedObject private var settings = Settings.shared
  @Binding var currentPage: Page

  var body: some View {
    ScrollView {
      VStack(spacing: 35) {

        // MARK: - How It Works Section
        VStack(spacing: 20) {
          HStack {
            Image(systemName: "lightbulb.fill")
              .foregroundColor(Shade.secondary)
              .font(.title2)
            Text("How It Works")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(Shade.secondary)
          }

          VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 12) {
              Text("1.")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
              VStack(alignment: .leading, spacing: 4) {
                Text("Enter a sentence")
                  .font(.headline)
                  .fontWeight(.semibold)
                Text("Use the vocabulary word in the text box provided.")
                  .font(.body)
                  .foregroundColor(.secondary)
              }
            }

            HStack(alignment: .top, spacing: 12) {
              Text("2.")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
              VStack(alignment: .leading, spacing: 4) {
                Text("Demonstrate understanding")
                  .font(.headline)
                  .fontWeight(.semibold)
                Text(
                  "Show your knowledge through correct grammar, synonyms, and context clues. For example, instead of \"She is studious,\" write \"The studious young woman spent every weekend in the library, preparing for classes and reading extra books.\""
                )
                .font(.body)
                .foregroundColor(.secondary)
              }
            }

            HStack(alignment: .top, spacing: 12) {
              Text("3.")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
              VStack(alignment: .leading, spacing: 4) {
                Text("Submit for grading")
                  .font(.headline)
                  .fontWeight(.semibold)
                Text("Click Submit to receive automatic feedback on your response.")
                  .font(.body)
                  .foregroundColor(.secondary)
              }
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(25)
          .background(Color(white: 0.96))
          .cornerRadius(12)
          .padding(.horizontal, 20)
        }

        // MARK: - Vocabulary Lists Section
        VStack(spacing: 20) {
          HStack {
            Image(systemName: "book.fill")
              .foregroundColor(Shade.secondary)
              .font(.title2)
            Text("Vocabulary Lists")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(Shade.secondary)
          }

          VStack(alignment: .leading, spacing: 15) {
            Text("The app uses a Top-1000 SAT word list as default.")
              .font(.body)
              .foregroundColor(.primary)

            Text("Starting with v1.2, you can:")
              .font(.body)
              .fontWeight(.medium)
              .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 8) {
              Text("• Export the default dictionary for customization")
              Text("• Upload your own vocabulary list (.csv format)")
              Text("• Use format: word, definition")
            }
            .font(.body)
            .foregroundColor(.secondary)
            .padding(.leading, 10)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(25)
          .background(Color(white: 0.96))
          .cornerRadius(12)
          .padding(.horizontal, 20)
        }

        // MARK: - Scoring Section
        VStack(spacing: 20) {
          HStack {
            Image(systemName: "star.fill")
              .foregroundColor(.yellow)
              .font(.title2)
            Text("Scoring System")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(Shade.secondary)
          }

          VStack(spacing: 20) {
            // Scoring criteria
            VStack(alignment: .leading, spacing: 15) {
              Text("Your sentence is scored on:")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

              HStack(alignment: .top, spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                  Text("Grammar")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                  Text("• Correct part of speech")
                  Text("• Proper sentence structure")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                  Text("Usage")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                  Text("• Clear definition knowledge")
                  Text("• Synonyms or context clues")
                }
                .font(.caption)
                .foregroundColor(.secondary)
              }
            }

            Divider()
              .padding(.horizontal, 10)

            // Score categories
            VStack(alignment: .leading, spacing: 12) {
              Text("Score Categories:")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

              VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                  HStack(spacing: 2) {
                    ForEach(0..<3) { _ in
                      Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    }
                  }
                  VStack(alignment: .leading, spacing: 2) {
                    Text("Learned")
                      .font(.subheadline)
                      .fontWeight(.semibold)
                    Text("Perfect score - appears less frequently")
                      .font(.caption)
                      .foregroundColor(.secondary)
                  }
                }

                HStack(alignment: .top, spacing: 8) {
                  HStack(spacing: 2) {
                    ForEach(0..<2) { _ in
                      Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    }
                    Image(systemName: "star")
                      .foregroundColor(.gray)
                      .font(.caption)
                  }
                  VStack(alignment: .leading, spacing: 2) {
                    Text("Still Learning")
                      .font(.subheadline)
                      .fontWeight(.semibold)
                    Text("Good understanding - will reappear")
                      .font(.caption)
                      .foregroundColor(.secondary)
                  }
                }

                HStack(alignment: .top, spacing: 8) {
                  HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                      .foregroundColor(.red)
                      .font(.caption)
                    ForEach(0..<2) { _ in
                      Image(systemName: "star")
                        .foregroundColor(.gray)
                        .font(.caption)
                    }
                  }
                  VStack(alignment: .leading, spacing: 2) {
                    Text("Newly Learned")
                      .font(.subheadline)
                      .fontWeight(.semibold)
                    Text("Needs practice - will appear frequently")
                      .font(.caption)
                      .foregroundColor(.secondary)
                  }
                }
              }
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(25)
          .background(Color(white: 0.96))
          .cornerRadius(12)
          .padding(.horizontal, 20)
        }

        // MARK: - Contact & Support Section
        VStack(spacing: 20) {
          HStack {
            Image(systemName: "envelope.fill")
              .foregroundColor(Shade.secondary)
              .font(.title2)
            Text("Contact & Support")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(Shade.secondary)
          }

          VStack(alignment: .leading, spacing: 10) {
            Text("Need help or have feedback?")
              .font(.body)
              .foregroundColor(.primary)

            Link(
              "vocabmateapp@gmail.com", destination: URL(string: "mailto:vocabmateapp@gmail.com")!
            )
            .font(.body)
            .foregroundColor(.blue)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(25)
          .background(Color(white: 0.96))
          .cornerRadius(12)
          .padding(.horizontal, 20)
        }

        // MARK: - Acknowledgements Section
        VStack(spacing: 20) {
          HStack {
            Image(systemName: "heart.fill")
              .foregroundColor(.red)
              .font(.title2)
            Text("Acknowledgements")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(Shade.secondary)
          }

          VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
              Text("Inspiration")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
              Text("Mr. Christopher Hurshman, Honors English Teacher")
              Text("The Harker School, San Jose, CA")
            }

            VStack(alignment: .leading, spacing: 6) {
              Text("Vocabulary Sources")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
              Text("Jay Koo Academy")
              Text("SAT Vocabulary by christinee91")
            }

            VStack(alignment: .leading, spacing: 6) {
              Text("Technology")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
              Text("Google Gemini Developer APIs")
            }

            VStack(alignment: .leading, spacing: 6) {
              Text("Developer")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
              Link(
                "Lucas A. Lum (github.com/lualum)",
                destination: URL(string: "https://github.com/lualum")!)
              Text("Co-founder, Inspira Foundation Inc.")
              Link(
                "inspirafoundationinc.org",
                destination: URL(string: "https://inspirafoundationinc.org")!
              )
              .font(.caption)
              .foregroundColor(.blue)
            }
          }
          .font(.body)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(25)
          .background(Color(white: 0.96))
          .cornerRadius(12)
          .padding(.horizontal, 20)
        }

        // Bottom padding
        Color.clear
          .frame(height: 10)
      }
      .padding(.top, 20)
    }
    .navigationTitle("Information")
  }
}
