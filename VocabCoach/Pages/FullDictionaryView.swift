import SwiftUI
import UniformTypeIdentifiers

// Word row component for displaying individual words
struct FullDictionaryWordRowView: View {
  @ObservedObject private var settings = Settings.shared

  @Binding var currentPage: Page
  @Binding var currentWord: WordEntry

  let word: String
  let definitions: [String]
  let scores: [Int]
  let color: Color

  private var averageScore: Double {
    guard !scores.isEmpty else { return 0.0 }
    let sum = scores.reduce(0, +)
    return Double(sum) / Double(scores.count)
  }

  var body: some View {
    HStack(spacing: 16) {
      // Score indicator circle
      Circle()
        .fill(color)
        .frame(width: 12, height: 12)

      VStack(alignment: .leading, spacing: 4) {
        // Word name
        Text(word)
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(Shade.text)

        // Score info
        HStack(spacing: 8) {
          if !scores.isEmpty {
            Text("Avg: \(averageScore, specifier: "%.1f")")
              .font(.headline)
              .foregroundColor(.gray)

            Text("Scores: \(scores.map(String.init).joined(separator: ", "))")
              .font(.headline)
              .foregroundColor(.gray)
          } else {
            Text("Not learned yet")
              .font(.headline)
              .foregroundColor(.gray)
          }
        }
      }

      Spacer()

      // Go to Learn
      Button(action: {
        currentWord = WordEntry.setWord(word)
        currentPage = .learn
      }) {
        Image(systemName: "chevron.right")
          .foregroundColor(.gray)
          .font(.caption)
      }

    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(Color.clear)
  }
}

// Helper struct to combine word data with scores
struct DictionaryWordData {
  let word: String
  let definitions: [String]
  let scores: [Int]

  var averageScoreInt: Int {
    guard !scores.isEmpty else { return -1 }
    let sum = scores.reduce(0, +)
    return sum / scores.count
  }
}

struct FullDictionaryView: View {
  @ObservedObject private var settings = Settings.shared

  @Binding var currentPage: Page
  @Binding var currentWord: WordEntry
  @State private var allWords: [DictionaryWordData] = []
  @State private var searchText: String = ""

  // CSV Upload and Reset states
  @State private var showingFileImporter = false
  @State private var showingResetAlert = false
  @State private var showingOperationAlert = false
  @State private var alertMessage = ""
  @State private var alertTitle = ""
  @State private var isOperationInProgress = false

  // Color definitions (same as FilteredDictionaryView)
  private let workingColors = [
    Color(red: 0.87, green: 0.49, blue: 0.42),  // Score 0
    Color(red: 0.92, green: 0.60, blue: 0.60),  // Score 1
    Color(red: 0.98, green: 0.80, blue: 0.61),  // Score 2
    Color(red: 1.00, green: 0.90, blue: 0.60),  // Score 3
    Color(red: 1.00, green: 0.85, blue: 0.40),  // Score 4
  ]

  private let learnedColors = [
    Color(red: 0.54, green: 0.70, blue: 0.89),  // Score 5
    Color(red: 0.79, green: 0.85, blue: 0.97),  // Score 6
  ]

  // Default color for unlearned words
  private let unlearnedColor = Color.gray.opacity(0.3)

  // Filtered words based on search text
  private var filteredWords: [DictionaryWordData] {
    if searchText.isEmpty {
      return allWords
    } else {
      return allWords.filter { $0.word.localizedCaseInsensitiveContains(searchText) }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // Title and action buttons
      VStack(spacing: 16) {
        VStack(spacing: 8) {
          Text("Full Dictionary")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Shade.text)

          Text("Word Count: \(allWords.count)")
            .font(.headline)
            .foregroundColor(.gray)
        }

        // Action buttons row
        HStack(spacing: 12) {
          // Upload CSV button
          Button(action: {
            showingFileImporter = true
          }) {
            HStack(spacing: 8) {
              Image(systemName: "square.and.arrow.up")
              Text("Upload CSV")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green)
            .cornerRadius(8)
          }
          .disabled(isOperationInProgress)

          // Reset to Default button
          Button(action: {
            showingResetAlert = true
          }) {
            HStack(spacing: 8) {
              Image(systemName: "arrow.clockwise")
              Text("Reset")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange)
            .cornerRadius(8)
          }
          .disabled(isOperationInProgress)
        }

        // Loading indicator
        if isOperationInProgress {
          HStack(spacing: 8) {
            ProgressView()
              .scaleEffect(0.8)
            Text("Processing...")
              .font(.caption)
              .foregroundColor(.gray)
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 20)
      .padding(.bottom, 20)

      // Search bar
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.gray)

        TextField("Search words...", text: $searchText)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 16)

      // Scrollable Content
      if filteredWords.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "book.closed")
            .font(.system(size: 48))
            .foregroundColor(.gray)

          Text(searchText.isEmpty ? "No words available" : "No words found")
            .font(.headline)
            .foregroundColor(.gray)

          Text(
            searchText.isEmpty ? "Dictionary appears to be empty" : "Try a different search term"
          )
          .font(.subheadline)
          .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(filteredWords.sorted(by: { $0.word < $1.word }), id: \.word) { wordData in
              FullDictionaryWordRowView(
                currentPage: $currentPage,
                currentWord: $currentWord,
                word: wordData.word,
                definitions: wordData.definitions,
                scores: wordData.scores,
                color: getColorForScore(wordData.averageScoreInt)
              )

              // Add divider between items (except for the last one)
              if wordData.word != filteredWords.sorted(by: { $0.word < $1.word }).last?.word {
                Divider()
                  .padding(.horizontal, 20)
              }
            }
          }
          .padding(.bottom, 40)
        }
      }

      Spacer()

      // Back to Dashboard button
      Button(action: {
        currentPage = .dashboard
      }) {
        HStack(spacing: 12) {
          Image(systemName: "square.grid.2x2.fill")
          Text("Dashboard")
        }
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Gradient(colors: Shade.buttonPrimary))
        .cornerRadius(12)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
    }
    .onAppear {
      loadAllWords()
    }
    .fileImporter(
      isPresented: $showingFileImporter,
      allowedContentTypes: [UTType.commaSeparatedText],
      allowsMultipleSelection: false
    ) { result in
      handleFileImport(result: result)
    }
    .alert("Reset Dictionary", isPresented: $showingResetAlert) {
      Button("Cancel", role: .cancel) {}
      Button("Reset", role: .destructive) {
        performReset()
      }
    } message: {
      Text(
        "This will reset your dictionary to the default words and cannot be undone. Are you sure?")
    }
    .alert(alertTitle, isPresented: $showingOperationAlert) {
      Button("OK") {}
    } message: {
      Text(alertMessage)
    }
  }

  private func loadAllWords() {
    // Get the dictionary from WordEntry
    let dictionary = WordEntry.getCurrentDictionary()

    // Get all saved word scores
    let savedWordScores = SaveUtil.wordScores

    // Create a lookup dictionary for saved scores
    let scoresByWord = Dictionary(
      uniqueKeysWithValues: savedWordScores.map { ($0.word, $0.scores) })

    // Combine dictionary words with their scores
    allWords = dictionary.map { word, definitions in
      let scores = scoresByWord[word] ?? []
      return DictionaryWordData(word: word, definitions: definitions, scores: scores)
    }
  }

  private func getColorForScore(_ score: Int) -> Color {
    // If score is -1 or empty scores array, return unlearned color
    if score == -1 {
      return unlearnedColor
    }

    if score >= 5 {
      return score >= 6 ? learnedColors[1] : learnedColors[0]
    } else {
      let index = min(max(score, 0), workingColors.count - 1)
      return workingColors[index]
    }
  }

  // MARK: - CSV Import Functions

  private func handleFileImport(result: Result<[URL], Error>) {
    switch result {
    case .success(let urls):
      guard let selectedFile = urls.first else { return }

      if selectedFile.startAccessingSecurityScopedResource() {
        processCSVFile(at: selectedFile)
        selectedFile.stopAccessingSecurityScopedResource()
      } else {
        showAlert(title: "Error", message: "Unable to access the selected file.")
      }

    case .failure(let error):
      showAlert(title: "Import Error", message: error.localizedDescription)
    }
  }

  private func processCSVFile(at url: URL) {
    isOperationInProgress = true

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let content = try String(contentsOf: url)
        let parsedWords = parseCSVContent(content)

        if parsedWords.isEmpty {
          DispatchQueue.main.async {
            self.isOperationInProgress = false
            self.showAlert(title: "Import Error", message: "No valid words found in the CSV file.")
          }
          return
        }

        // Process words in batches to avoid blocking the main thread
        var successCount = 0
        var errorCount = 0
        let dispatchGroup = DispatchGroup()

        for (word, definitions) in parsedWords {
          dispatchGroup.enter()

          WordEntry.addWord(word, definitions: definitions) { success, error in
            if success {
              successCount += 1
            } else {
              errorCount += 1
              print("Failed to add word '\(word)': \(error ?? "Unknown error")")
            }
            dispatchGroup.leave()
          }
        }

        dispatchGroup.notify(queue: .main) {
          self.isOperationInProgress = false
          self.loadAllWords()  // Refresh the display

          let message: String
          if errorCount == 0 {
            message = "Successfully imported \(successCount) words from CSV."
          } else {
            message =
              "Imported \(successCount) words successfully. \(errorCount) words failed to import."
          }

          self.showAlert(title: "Import Complete", message: message)
        }

      } catch {
        DispatchQueue.main.async {
          self.isOperationInProgress = false
          self.showAlert(
            title: "Import Error", message: "Failed to read CSV file: \(error.localizedDescription)"
          )
        }
      }
    }
  }

  private func parseCSVContent(_ content: String) -> [(String, [String])] {
    var results: [(String, [String])] = []
    let lines = content.components(separatedBy: .newlines)

    for (index, line) in lines.enumerated() {
      let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

      // Skip empty lines
      if trimmedLine.isEmpty { continue }

      // Skip header line if it looks like one
      if index == 0
        && (trimmedLine.lowercased().contains("word")
          || trimmedLine.lowercased().contains("definition"))
      {
        continue
      }

      // Parse CSV line - handle quotes and commas properly
      let components = parseCSVLine(trimmedLine)

      guard components.count >= 2 else {
        print("Skipping invalid line \(index + 1): \(trimmedLine)")
        continue
      }

      let word = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
      let definitionsText = components[1].trimmingCharacters(in: .whitespacesAndNewlines)

      if word.isEmpty || definitionsText.isEmpty {
        print("Skipping empty word or definition on line \(index + 1)")
        continue
      }

      // Split definitions by semicolon, newline, or pipe
      let definitions =
        definitionsText
        .components(separatedBy: CharacterSet(charactersIn: ";\n|"))
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

      if definitions.isEmpty {
        print("No valid definitions found for word '\(word)' on line \(index + 1)")
        continue
      }

      results.append((word, definitions))
    }

    return results
  }

  private func parseCSVLine(_ line: String) -> [String] {
    var components: [String] = []
    var currentComponent = ""
    var insideQuotes = false
    var i = line.startIndex

    while i < line.endIndex {
      let char = line[i]

      if char == "\"" {
        insideQuotes.toggle()
      } else if char == "," && !insideQuotes {
        components.append(currentComponent.trimmingCharacters(in: .whitespacesAndNewlines))
        currentComponent = ""
      } else {
        currentComponent.append(char)
      }

      i = line.index(after: i)
    }

    // Add the last component
    components.append(currentComponent.trimmingCharacters(in: .whitespacesAndNewlines))

    // Remove surrounding quotes if present
    return components.map { component in
      var cleaned = component
      if cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"") && cleaned.count > 1 {
        cleaned = String(cleaned.dropFirst().dropLast())
      }
      return cleaned
    }
  }

  // MARK: - Reset Functions

  private func performReset() {
    isOperationInProgress = true

    WordEntry.resetToDefaultWords { success, error in
      DispatchQueue.main.async {
        self.isOperationInProgress = false

        if success {
          self.loadAllWords()  // Refresh the display
          self.showAlert(
            title: "Reset Complete", message: "Dictionary has been reset to default words.")
        } else {
          self.showAlert(title: "Reset Failed", message: error ?? "Unknown error occurred.")
        }
      }
    }
  }

  // MARK: - Helper Functions

  private func showAlert(title: String, message: String) {
    alertTitle = title
    alertMessage = message
    showingOperationAlert = true
  }
}
