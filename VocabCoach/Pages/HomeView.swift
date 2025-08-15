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
      VStack {
        // App title and word count
        VStack(spacing: 16) {
          Text("VocabCoach")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Shade.secondary)

          Image(settings.isDarkMode ? "IconDark" : "Icon")  // Use the name you gave the image set
            .resizable()
            .frame(width: 200, height: 200 )

          Button(action: {
            currentPage = .question
          }) {
            HStack(spacing: 20) {
              Image(systemName: "play.fill")
                .foregroundColor(.white)
                .font(.title3)
                .frame(width: 24, height: 24)  // Fixed dimensions
                .multilineTextAlignment(.center)  // Center icon in frame
              Text("Play")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
              Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .cornerRadius(12)
          }

          Button(action: {
            currentPage = .dashboard
          }) {
            HStack(spacing: 20) {
              Image(systemName: "square.grid.2x2.fill")
                .foregroundColor(.white)
                .font(.title3)
                .frame(width: 24, height: 24)
                .multilineTextAlignment(.center)
              Text("Dashboard")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
              Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
          }
        }
        .padding(.horizontal, 40)

      }
    }
  }
}
