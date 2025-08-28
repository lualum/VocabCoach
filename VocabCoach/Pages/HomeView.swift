//
//  HomeView.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/1/25.
//
import SwiftUI

struct HomeView: View {
  @ObservedObject private var settings = Settings.shared
  @Binding var currentPage: Page
  @State private var showingFeedback = false
  @Binding var learnedPage: Bool

  var body: some View {
    ZStack {
      // Main content
      VStack(spacing: 40) {
        Spacer()

        // App title and logo
        VStack(spacing: 24) {
          Image("Icon")
            .resizable()
            .frame(width: 240, height: 240)

          VStack(spacing: 8) {
            Text("VocabCoach")
              .font(.system(size: 48, weight: .bold, design: .default))
              .foregroundColor(Shade.text)

            Text("LEARN VOCABULARY ON-THE-GO")
              .font(.system(size: 14, weight: .medium, design: .default))
              .foregroundColor(.gray)
              .tracking(1.5)
          }
        }.padding(.bottom, 40)

        // Buttons section
        VStack(spacing: 20) {
          // Play button - larger and prominent
          Button(action: {
            currentPage = .question
          }) {
            HStack(spacing: 16) {
              Image(systemName: "play.fill")
                .foregroundColor(.white)
                .font(.title2)
                .frame(width: 24, height: 24)
              Text("Play")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
              LinearGradient(
                gradient: Gradient(colors: Shade.buttonPrimary),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .cornerRadius(16)
          }

          // Dashboard and Dictionary buttons in a row
          HStack(spacing: 16) {
            Button(action: {
              currentPage = .dashboard
            }) {
              VStack(spacing: 12) {
                Image(systemName: "square.grid.2x2")
                  .foregroundColor(.white)
                  .font(.title)
                  .frame(width: 32, height: 32)
                Text("Dashboard")
                  .font(.title3)
                  .fontWeight(.medium)
                  .foregroundColor(.white)
              }
              .padding(.vertical, 24)
              .frame(maxWidth: .infinity)
              .background(Shade.buttonSecondary)
              .cornerRadius(16)
            }

            Button(action: {
              currentPage = .dictionary
            }) {
              VStack(spacing: 12) {
                Image(systemName: "book")
                  .foregroundColor(.white)
                  .font(.title)
                  .frame(width: 32, height: 32)
                Text("Dictionary")
                  .font(.title3)
                  .fontWeight(.medium)
                  .foregroundColor(.white)
              }
              .padding(.vertical, 24)
              .frame(maxWidth: .infinity)
              .background(Shade.buttonSecondary)
              .cornerRadius(16)
            }
          }
        }
        .padding(.horizontal, 32)

        Spacer()
      }
    }
  }
}
