import PhoneNumberKit
import SwiftUI

struct LoginView: View {
  @State private var phoneNumber = ""
  @State private var internationalPhoneNumber = ""

  @State private var isLoading = false
  @State private var errorMessage: String?
  @FocusState private var isPhoneNumberFieldFocused: Bool

  private let deviceId = UUID().uuidString
  @State private var dataExchange: String?
  @State private var captchaToken: String?

  private let phoneNumberUtility = PhoneNumberUtility()

  var body: some View {
    ZStack {
      VStack(spacing: 20) {
        Text("What's your phone number?")
          .fontWeight(.semibold)

        PhoneNumberTextFieldView(phoneNumber: $phoneNumber)
          .padding(.horizontal, 40)
          .padding(.vertical, 20)
          .focused($isPhoneNumberFieldFocused)
          .onAppear {
            isPhoneNumberFieldFocused = true
          }

        VStack(spacing: 20) {
          Text(
            "By continuing, you agree that StayReal is not affiliated with BeReal and that you are using this service at your own risk."
          )
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .font(.subheadline)

          Text(
            "You also agree to \("StayReal's Privacy Policy", link: "https://stayreal.vexcited.com/privacy-policy") and \("BeReal's Terms of Service", link: "https://bereal.com/terms")."
          )
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .font(.subheadline)
        }

        Spacer()

        if let error = errorMessage {
          Text(error)
            .foregroundColor(.red)
            .font(.caption)
        }

        AsyncButton(
          action: {
            await sendVerificationCode()
          },
          label: {
            Text("Send me a verification code")
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color(.blue))
              .foregroundColor(.white)
              .cornerRadius(10)
              .opacity(isLoading || phoneNumber.isEmpty ? 0.75 : 1)
          }
        )
        .disabled(isLoading || phoneNumber.isEmpty)
      }
      .padding()

      if let dataExchange = dataExchange, captchaToken == nil {
        CaptchaWebView(
          deviceId: deviceId, dataExchange: dataExchange,
          callback: { token in
            // We grab the token from the captcha.
            captchaToken = token

            // We can send the verification code now.
            Task {
              await sendVerificationCode()
            }
          }
        )
        .padding()
        .onAppear {
          isPhoneNumberFieldFocused = false
        }
      }
    }
  }

  func sendVerificationCode() async {
    if phoneNumber.isEmpty {
      return
    }

    // Let's reset the error message state to nil.
    errorMessage = nil

    do {
      let parsedNumber = try phoneNumberUtility.parse(phoneNumber)
      internationalPhoneNumber = phoneNumberUtility.format(parsedNumber, toType: .e164)
    } catch {
      errorMessage = "Invalid phone number format, check the number and try again."
    }

    if dataExchange == nil {
      do {
        isLoading = true
        dataExchange = try await VonageService.shared.getDataExchange(
          deviceId: deviceId,
          phoneNumber: internationalPhoneNumber
        )
      } catch VonageError.dataExchangeError(let message) {
        errorMessage = message
        isLoading = false
      } catch {
        errorMessage = "An unexpected error occurred."
        isLoading = false
      }

      return
    }

    if let dataExchange = dataExchange, let captchaToken = captchaToken {
      print("dataExchange: \(dataExchange)")
      print("captchaToken: \(captchaToken)")
      print("internationalPhoneNumber: \(internationalPhoneNumber)")
      print("deviceId: \(deviceId)")
      print("Let's send all of this to BeReal !")
    }
  }
}
