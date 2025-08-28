//
// VocabCoachApp.swift
// VocabCoach
//
// Created by Lucas Lum on 6/1/25.
//
import SwiftUI

struct DefaultButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    DefaultButtonContent(configuration: configuration)
  }
}

struct DefaultButtonContent: View {
  let configuration: ButtonStyle.Configuration
  @State private var isHovered = false

  var body: some View {
    configuration.label
      .brightness(isHovered ? 0.2 : 0.0)  // Brighter on hover
      .opacity(configuration.isPressed ? 0.75 : 1.0)
      .offset(y: configuration.isPressed ? 2 : (isHovered ? -2 : 0))  // Rise on hover, sink on press
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
      .animation(.easeInOut(duration: 0.15), value: isHovered)
      .onHover { hovering in
        isHovered = hovering
      }
  }
}

@main
struct VocabCoachApp: App {
  init() {
    UIButton.appearance().showsMenuAsPrimaryAction = false  // Optional UIKit fallback
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .statusBar(hidden: true)
        .buttonStyle(DefaultButtonStyle())
    }
  }
}

#Preview {
  ContentView()
}
