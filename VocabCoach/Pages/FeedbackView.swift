//
//  FeedbackView.swift
//  VocabCoach
//
//  Created by Lucas Lum on 6/7/25.
//

import MessageUI
import PhotosUI
import SwiftUI

struct FeedbackView: View {
  @ObservedObject private var settings = Settings.shared
  @State private var feedbackText = ""
  @State private var includeDeviceInfo = false
  @State private var showingMailCompose = false
  @State private var showingAlert = false
  @State private var alertMessage = ""
  @State private var selectedImages: [UIImage] = []
  @State private var showingImagePicker = false
  @State private var showingActionSheet = false
  @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack {
      VStack(spacing: 20) {
        // Title
        Text("Feedback")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(Shade.secondary)
          .underline()

        Spacer()

        // Text input area
        TextEditor(text: $feedbackText)
          .scrollContentBackground(.hidden)
          .padding()
          .background(Color.gray.opacity(0.3))
          .cornerRadius(12)
          .font(.body)
          .foregroundColor(Shade.secondary)
          .padding(.horizontal, 40)
          .frame(maxHeight: .infinity)

        // Selected images preview
        if !selectedImages.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
              ForEach(selectedImages.indices, id: \.self) { index in
                ZStack(alignment: .topTrailing) {
                  Image(uiImage: selectedImages[index])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)

                  Button(action: {
                    selectedImages.remove(at: index)
                  }) {
                    Image(systemName: "xmark.circle.fill")
                      .foregroundColor(.red)
                      .background(Color.white)
                      .clipShape(Circle())
                  }
                  .offset(x: 5, y: -5)
                }
              }
            }
            .padding(.horizontal, 40)
          }
        }

        // Upload button
        Button(action: {
          showingActionSheet = true
        }) {
          HStack {
            Image(systemName: "photo")
            Text("Upload Screenshots")
            if !selectedImages.isEmpty {
              Text("(\(selectedImages.count))")
                .fontWeight(.bold)
            }
          }
          .font(.body)
          .fontWeight(.medium)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(Color.gray.opacity(0.3))
          .cornerRadius(8)
        }.padding(.horizontal, 40)

        // Send button
        Button(action: sendFeedback) {
          HStack {
            Image(systemName: "envelope")
            Text("Send via Gmail")
          }
          .font(.body)
          .fontWeight(.medium)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(Color.blue)
          .cornerRadius(8)
        }.padding(.horizontal, 40)

        // Checkbox for device info
        HStack {
          Button(action: { includeDeviceInfo.toggle() }) {
            RoundedRectangle(cornerRadius: 4)
              .fill(includeDeviceInfo ? Shade.secondary : Color.clear)
              .stroke(Shade.secondary, lineWidth: 2)
              .frame(width: 24, height: 24)
              .overlay(
                Image(systemName: "checkmark")
                  .font(.caption)
                  .fontWeight(.bold)
                  .foregroundColor(Shade.primary)
                  .opacity(includeDeviceInfo ? 1 : 0)
              )
          }

          Text("include phone model/system")
            .font(.body)
            .foregroundColor(Shade.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
      }
    }
    .sheet(isPresented: $showingMailCompose) {
      MailComposeView(
        recipients: ["feedback@yourapp.com"],
        subject: "App Feedback",
        messageBody: createEmailBody(),
        attachments: selectedImages,
        onResult: handleMailResult
      )
    }
    .sheet(isPresented: $showingImagePicker) {
      ImagePicker(
        selectedImages: $selectedImages,
        sourceType: imagePickerSourceType
      )
    }
    .actionSheet(isPresented: $showingActionSheet) {
      ActionSheet(
        title: Text("Select Image Source"),
        buttons: [
          .default(Text("Photo Library")) {
            imagePickerSourceType = .photoLibrary
            showingImagePicker = true
          },

          .cancel(),
        ]
      )
    }
    .alert("Feedback", isPresented: $showingAlert) {
      Button("OK") {}
    } message: {
      Text(alertMessage)
    }
  }

  private func sendFeedback() {
    if MFMailComposeViewController.canSendMail() {
      showingMailCompose = true
    } else {
      // Fallback - Gmail URL scheme doesn't support attachments
      if !selectedImages.isEmpty {
        alertMessage =
          "Gmail URL scheme doesn't support attachments. Please use the Mail app or save images separately."
        showingAlert = true
        return
      }

      let gmailURL = createGmailURL()
      if UIApplication.shared.canOpenURL(gmailURL) {
        UIApplication.shared.open(gmailURL)
      } else {
        alertMessage = "Please install Gmail or configure Mail app to send feedback."
        showingAlert = true
      }
    }
  }

  private func createEmailBody() -> String {
    var body = "Feedback:\n\(feedbackText)\n\n"

    if includeDeviceInfo {
      body += """

        ---
        Device Info:
        iOS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.current.model)
        """
    }

    return body
  }

  private func createGmailURL() -> URL {
    let subject =
      "App Feedback".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let body =
      createEmailBody().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let recipient = "feedback@yourapp.com"

    let urlString = "googlegmail://co?to=\(recipient)&subject=\(subject)&body=\(body)"
    return URL(string: urlString) ?? URL(
      string: "mailto:\(recipient)?subject=\(subject)&body=\(body)")!
  }

  private func handleMailResult(_ result: Result<MFMailComposeResult, Error>) {
    switch result {
    case .success(let mailResult):
      switch mailResult {
      case .sent:
        alertMessage = "Feedback sent successfully!"
        showingAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          dismiss()
        }
      case .cancelled:
        break
      case .failed:
        alertMessage = "Failed to send feedback. Please try again."
        showingAlert = true
      case .saved:
        alertMessage = "Feedback saved to drafts."
        showingAlert = true
      @unknown default:
        break
      }
    case .failure:
      alertMessage = "An error occurred while sending feedback."
      showingAlert = true
    }
  }
}

struct MailComposeView: UIViewControllerRepresentable {
  let recipients: [String]
  let subject: String
  let messageBody: String
  let attachments: [UIImage]
  let onResult: (Result<MFMailComposeResult, Error>) -> Void

  func makeUIViewController(context: Context) -> MFMailComposeViewController {
    let composer = MFMailComposeViewController()
    composer.mailComposeDelegate = context.coordinator
    composer.setToRecipients(recipients)
    composer.setSubject(subject)
    composer.setMessageBody(messageBody, isHTML: false)

    // Add image attachments
    for (index, image) in attachments.enumerated() {
      if let imageData = image.jpegData(compressionQuality: 0.8) {
        composer.addAttachmentData(
          imageData, mimeType: "image/jpeg", fileName: "screenshot_\(index + 1).jpg")
      }
    }

    return composer
  }

  func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(onResult: onResult)
  }

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    let onResult: (Result<MFMailComposeResult, Error>) -> Void

    init(onResult: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
      self.onResult = onResult
    }

    func mailComposeController(
      _ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      if let error = error {
        onResult(.failure(error))
      } else {
        onResult(.success(result))
      }
      controller.dismiss(animated: true)
    }
  }
}

struct ImagePicker: UIViewControllerRepresentable {
  @Binding var selectedImages: [UIImage]
  let sourceType: UIImagePickerController.SourceType
  @Environment(\.presentationMode) var presentationMode

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = sourceType
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.originalImage] as? UIImage {
        parent.selectedImages.append(image)
      }
      parent.presentationMode.wrappedValue.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}
