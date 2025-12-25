import SwiftUI

struct CumulativeStatCard: View {
  @ObservedObject private var settings = Settings.shared

  let number: Int
  let label: String
  let color: Color
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 16) {
        Image(systemName: "star.fill").foregroundColor(color)

        VStack(alignment: .leading, spacing: 4) {
          Text(label)
            .font(.subheadline)
            .foregroundColor(Shade.text)
            .multilineTextAlignment(.leading)

          Text("\(number)")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(Shade.text)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .foregroundColor(Shade.text.opacity(0.6))
          .font(.subheadline)
      }
      .padding(16)
      .background((Settings.isDarkMode ? Color.white : Color.gray).opacity(0.05))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.clear, lineWidth: 1)
      )
      .cornerRadius(12)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct DashboardView: View {
  @ObservedObject private var settings = Settings.shared
  @Binding var currentPage: Page

  @Binding var correctCount: Int
  @Binding var incorrectCount: Int

  @State private var totalAttempted: Int = 0
  @State private var youKnowIt: Int = 0
  @State private var canBeMorePrecise: Int = 0
  @State private var needToLearnMore: Int = 0

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        VStack(spacing: 32) {
          // Title
          Text("Dashboard")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Shade.text)
            .padding(.top, 20)

          // Total attempted
          VStack(alignment: .leading, spacing: 8) {
            Text("# of words attempted")
              .font(.headline)
              .foregroundColor(Shade.text)

            Text("\(totalAttempted)")
              .font(.system(size: 36, weight: .bold))
              .foregroundColor(Shade.text)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 24)

          // Score-based categories
          VStack(spacing: 16) {
            CumulativeStatCard(
              number: youKnowIt,
              label: "Learned",
              color: .blue
            ) {
              FilteredDictionaryManager.shared.setFilter(min: 5, max: 6, title: "Learned")
              currentPage = .filteredDictionary  // Changed from .dictionary
            }

            CumulativeStatCard(
              number: canBeMorePrecise,
              label: "Still Learning",
              color: .yellow
            ) {
              FilteredDictionaryManager.shared.setFilter(min: 4, max: 4, title: "Still Learning")
              currentPage = .filteredDictionary  // Changed from .dictionary
            }

            CumulativeStatCard(
              number: needToLearnMore,
              label: "Newly Learned",
              color: .gray
            ) {
              FilteredDictionaryManager.shared.setFilter(min: 0, max: 3, title: "Newly Learned")
              currentPage = .filteredDictionary  // Changed from .dictionary
            }
          }
          .padding(.horizontal, 24)

          Spacer()

          // Buttons
          VStack(spacing: 16) {
            Button(action: {
              currentPage = .question
            }) {
              HStack(spacing: 12) {
                Image(systemName: "play.fill")
                  .font(.headline)
                Text("Continue")
                  .font(.title3)
                  .fontWeight(.bold)
                  .bold()
              }
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(Gradient(colors: Shade.buttonPrimary))
              .cornerRadius(12)
            }

            Button(action: {
              currentPage = .home
            }) {
              HStack(spacing: 12) {
                Image(systemName: "house.fill")
                  .font(.headline)
                Text("Return Home")
                  .font(.title3)
                  .fontWeight(.bold)
                  .bold()
              }
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(Shade.buttonSecondary)
              .cornerRadius(12)
            }
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 40)
        }
      }
    }
    .onAppear {
      loadStats()
    }
  }

  private func loadStats() {
    // Get all word scores using SaveUtil
    let allWordScores = SaveUtil.wordScores
    totalAttempted = allWordScores.count

    // Count words in each score range using the existing method
    youKnowIt = WordEntry.countDictionaryWordsWithScoreRange(
      min: 5, max: 6, )
    canBeMorePrecise = WordEntry.countDictionaryWordsWithScoreRange(min: 4, max: 4)
    needToLearnMore = WordEntry.countDictionaryWordsWithScoreRange(min: 0, max: 3)
  }
}
