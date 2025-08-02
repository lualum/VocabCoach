//
//  VocabCoachApp.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/1/25.
//

import SwiftUI

struct DefaultButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(configuration.isPressed ? 0.75 : 1.0)
      .offset(y: configuration.isPressed ? 2 : 0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

@main
struct VocabCoachApp: App {
  init() {
    UIButton.appearance().showsMenuAsPrimaryAction = false  // Optional UIKit fallback
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .statusBar(hidden: true)
        .buttonStyle(DefaultButtonStyle())
    }
  }
}

#Preview {
  RootView()
}
