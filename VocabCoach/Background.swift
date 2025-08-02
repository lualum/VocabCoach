//
//  Background.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/1/25.
//

import SwiftUI

class Shade: ObservableObject {
  @ObservedObject private var settings = Settings.shared

  static let shared = Shade()

  private init() {}

  var primary: Color {
    settings.isDarkMode ? .black : .white
  }

  var secondary: Color {
    settings.isDarkMode ? .white : .black
  }

  var background: Color {
    settings.isDarkMode ? .black : .white
  }

  var text: Color {
    settings.isDarkMode ? .white : .black
  }

  // Static convenience properties
  static var primary: Color {
    shared.primary
  }

  static var secondary: Color {
    shared.secondary
  }

  static var background: Color {
    shared.background
  }

  static var text: Color {
    shared.text
  }
}

struct Background: View {
  @ObservedObject private var settings = Settings.shared
  @State private var rotation: Angle = .zero

  @Binding var currentPage: Page

  var body: some View {
    Shade.background.ignoresSafeArea()
  }
}

struct NavigationRow: View {
  @ObservedObject private var settings = Settings.shared
  @Binding var currentPage: Page
  @Binding var showingSettings: Bool
  @Binding var sumPoints: Int
  @Binding var totalPoints: Int

  var body: some View {
    HStack(alignment: .center) {
      // Left navigation button
      Button(action: {
        if currentPage == .home {
          currentPage = .info
        } else {
          currentPage = .home
        }
      }) {
        Image(systemName: currentPage == .home ? "info.circle.fill" : "house.fill")
          .font(.title2)
          .foregroundColor(Shade.secondary)
          .frame(width: 44, height: 44)  // Standard touch target size
      }
      .padding(.horizontal, 22)

      Spacer()

      // Right settings button
      Button(action: {
        showingSettings = true
      }) {
        Image(systemName: "gearshape.fill")
          .font(.title2)
          .foregroundColor(Shade.secondary)
          .frame(width: 44, height: 44)  // Standard touch target size
      }
      .padding(.horizontal, 22)
    }
    .frame(height: 44)  // Consistent height
    .padding(.horizontal, 20)
    .padding(.top, 15)  // Add top padding to account for status bar and notch
    .padding(.bottom, 15)
    .background(Color.gray.opacity(0.15))
    .ignoresSafeArea(.container, edges: .top)  // Extend beyond safe area at top
  }
}
