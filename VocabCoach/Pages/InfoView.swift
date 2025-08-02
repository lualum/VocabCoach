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

  enum SectionID: String, CaseIterable {
    case howTo = "How To"
    case scoring = "Scoring"
    case credits = "Credits"
  }

  var body: some View {
    // ScrollViewReader provides a proxy to programmatically control the scroll position.
    ScrollViewReader { proxy in
      ScrollView {
        VStack(spacing: 30) {

          Text("Table of Contents")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Shade.secondary)
            .underline()

          // MARK: - Table of Contents
          VStack(spacing: 15) {

            HStack(spacing: 30) {
              // Loop through all sections to create buttons dynamically.
              ForEach(SectionID.allCases, id: \.self) { section in
                Button(action: {
                  // The action scrolls to the corresponding section ID with a smooth animation.
                  withAnimation(.spring()) {
                    proxy.scrollTo(section, anchor: .top)
                  }
                }) {
                  Text(section.rawValue)
                    .font(.headline)
                    .foregroundColor(.blue)
                }
              }
            }
          }
          .padding(.vertical, 20)
          .frame(maxWidth: .infinity)
          .background(Color(white: 0.95))
          .cornerRadius(15)
          .padding(.horizontal, 20)

          howToSection
            .id(SectionID.howTo)

          scoringSection
            .id(SectionID.scoring)  // Assigns a unique ID to this view.

          // MARK: - Credits Section
          creditsSection
            .id(SectionID.credits)  // Assigns a unique ID to this view.

          // Bottom padding to ensure last section can scroll fully to the top.
          Color.clear
            .frame(height: 50)
        }
        .padding(.top, 20)
      }
    }
    .navigationTitle("Information")
  }

  private var howToSection: some View {
    VStack(spacing: 20) {
      Text("How To")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(Shade.secondary)
        .underline()

      VStack(alignment: .leading, spacing: 25) {
        Text(
          "Enter a sentence in the grey text box that correctly uses the word above. Make sure your sentence shows that you truly understand the word’s meaning—this could be through using synonyms, context clues, or clearly demonstrating the definition. When you're finished, click [Submit] to have your response graded using the rubric below."
        )
      }
      .font(.body)
      .foregroundColor(.black)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(30)
      .background(Color(white: 0.95))
      .cornerRadius(15)
      .padding(.horizontal, 20)
    }
  }

  private var scoringSection: some View {
    VStack(spacing: 20) {
      Text("Scoring")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(Shade.secondary)
        .underline()

      VStack(spacing: 15) {
        // Context header with star rating
        VStack(spacing: 10) {
          HStack {
            Image(systemName: "star.fill").foregroundColor(.yellow)
            Image(systemName: "star.fill").foregroundColor(.orange)
            Image(systemName: "star.fill").foregroundColor(.orange)
          }
          .font(.title)

          HStack {
            Spacer()
            Text("Grammar").font(.title2).fontWeight(.medium)
            Spacer()
            Text("Usage").font(.title2).fontWeight(.medium)
            Spacer()
          }
          .foregroundColor(Shade.primary)
          .padding(.horizontal, 40)
        }

        // Divider
        Rectangle()
          .fill(Color.gray.opacity(0.4))
          .frame(height: 1)
          .padding(.horizontal, 20)

        // Scoring criteria
        VStack(alignment: .leading, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Grammar")
              .font(.headline)
              .fontWeight(.semibold)
            Text("- Vocab has correct part of speech")
            Text("- Correct grammar in sentence")
          }

          VStack(alignment: .leading, spacing: 4) {
            Text("Usage")
              .font(.headline)
              .fontWeight(.semibold)
            Text("- Show clear knowledge of definition by using either its synonyms or its meaning")
          }
        }
        .font(.body)
        .foregroundColor(Shade.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
      }
      .padding(.vertical, 20)
      .background(Color(white: 0.95))
      .cornerRadius(15)
      .padding(.horizontal, 20)
    }
  }

  private var creditsSection: some View {
    VStack(spacing: 20) {
      Text("Credits")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(Shade.secondary)
        .underline()

      VStack(alignment: .leading, spacing: 25) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Vocabulary Lists:")
            .font(.headline)
            .fontWeight(.semibold)
          Text("Jay Koo Academy")
          Text("SAT Vocabulary by christinee91")
        }

        VStack(alignment: .leading, spacing: 8) {
          Text("Teacher/Format:")
            .font(.headline)
            .fontWeight(.semibold)
          Text("Christopher Hurshman")
        }

        VStack(alignment: .leading, spacing: 8) {
          Text("Developer:")
            .font(.headline)
            .fontWeight(.semibold)
          Link(
            "Lucas Lum (github.com/lualum)",
            destination: URL(string: "https://github.com/lualum")!)
        }
      }
      .font(.body)
      .foregroundColor(Shade.primary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(30)
      .background(Color(white: 0.95))
      .cornerRadius(15)
      .padding(.horizontal, 20)
    }
  }
}
