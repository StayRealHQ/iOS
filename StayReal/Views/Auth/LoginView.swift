import PhoneNumberKit
import SwiftUI
import SwiftUIIntrospect
import UIKit

struct AutoFocusTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.textContentType = .telephoneNumber
        textField.keyboardType = .phonePad
        textField.font = UIFont
            .systemFont(
                ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize,
                weight: .bold
            )
        textField.text = text
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.becomeFirstResponder()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
        return CGSize(width: proposal.width ?? 100, height: 50)
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        
        init(text: Binding<String>) {
            self.text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }
    }
}

struct LoginView: View {
    @State private var phoneNumber = ""
    @State private var internationalPhoneNumber = ""
    @State private var verificationCode = ""
    
    @State private var errorMessage: String?
    
    private let deviceId = UUID().uuidString
    @State var dataExchange: String?
    @State var captchaToken: String?
    @State var vonageRequestId: String?
    
    @State var countryCode: String = Locale.current.region?.identifier ?? "us"
    @State var isWaitingForVerificationCode: Bool = false
    @State var phoneNumberPlaceHolder: String = PartialFormatter().formatPartial(PartialFormatter().nationalNumber(from: PhoneNumberUtility().getFormattedExampleNumber(forCountry: Locale.current.region?.identifier ?? "us") ?? ""))
    
    @State var showCaptcha: Bool = false
    @State var showOTPView: Bool = false
    
    func handleURL(_ url: URL) -> OpenURLAction.Result {
        UIApplication.shared.open(url)
        return .handled
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("""
            What’s your
            phone number ?
            """)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fixedSize()
            .padding(.top, 30)
            HStack(alignment: .center) {
                Menu {
                    ForEach(phoneCountryCodes, id: \.countryCode) { phone in
                        Button {
                            countryCode = phone.countryCode
                            phoneNumberPlaceHolder = PartialFormatter().formatPartial(PartialFormatter().nationalNumber(from: PhoneNumberUtility().getFormattedExampleNumber(forCountry: countryCode) ?? ""))
                        } label: {
                            Text("\(phone.countryCode.flagEmoji) \(phone.countryName) (+\(phone.code))")
                        }
                    }
                } label: {
                    Text("\(countryCode.flagEmoji) +\(PhoneNumberUtility().countryCode(for: countryCode) ?? 1)")
                        .font(.largeTitle.bold())
                }
                AutoFocusTextField(
                    text: $phoneNumber,
                    placeholder: phoneNumberPlaceHolder
                )
                    .opacity(isWaitingForVerificationCode ? 0.28:1)
                    .onChange(of: phoneNumber) { _, value in
                        do {
                            phoneNumber = PartialFormatter().nationalNumber(from: value)
                            phoneNumber = PartialFormatter().formatPartial(phoneNumber)
                        }
                    }
            }
            .frame(height: 50)
            .padding(.top, 20)
            .disabled(isWaitingForVerificationCode)
            if let error = errorMessage {
                Text(error)
                    .font(.subheadline.bold())
                    .foregroundColor(Color.stayRealRed)
            }
            Spacer()
            Text("""
            By continuing, you agree that StayReal is not affiliated with BeReal and that you are using this service at your own risk.
            You also agree to **[StayReal's Privacy Policy](https://stayreal.vexcited.com/privacy-policy)** and **[BeReal's Terms of Service](https://bereal.com/terms)**.
            """)
                .tint(.white.opacity(0.4))
                .foregroundColor(.white.opacity(0.4))
                .font(.footnote)
                .environment(\.openURL, OpenURLAction(handler: handleURL))
            Button {
                Task {
                    await sendVerificationCode()
                }
            } label: {
                if (isWaitingForVerificationCode) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                } else {
                    Text("Send me a verification code")
                }
            }
            .buttonStyle(ProminentButtonStyle())
            .disabled(isWaitingForVerificationCode)
            .padding(.top)
        }
        .padding()
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_mini")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
        }
        .sheet(isPresented: Binding(
            get: { showCaptcha && dataExchange != nil },
            set: { showCaptcha = $0 }
        )) {
            VStack(alignment: .leading) {
                Text("""
                Are you a
                real human ?
                """)
                .font(.largeTitle)
                .fontWeight(.bold)
                .fixedSize()
                .padding(.top, 50)
                Text("We are not able to verify if you’re an human. Please complete the captcha below.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 30)
                CaptchaWebView(
                    deviceId: deviceId, dataExchange: dataExchange!,
                    callback: { token in
                        captchaToken = token
                        showCaptcha = false
                    }
                )
                .aspectRatio(0.9, contentMode: .fit)
                .background(.black)
                .mask {RoundedRectangle(cornerRadius: 20)}
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                }
                Spacer()
            }
            .padding()
            .background(Color.background)
            .foregroundStyle(.white)
            .presentationDragIndicator(.visible)
        }
        .onChange(of: showCaptcha) { _, value in
            if (value == false) {
                if (captchaToken != nil) {
                    Task {
                        await sendVerificationCode()
                    }
                } else {
                    dataExchange = nil
                    isWaitingForVerificationCode = false
                }
            }
        }
        .navigationDestination(isPresented: $showOTPView) {
            OTPView(
                deviceId: deviceId,
                vonageRequestId: $vonageRequestId
            )
        }
  }

    func sendVerificationCode() async {
        // Let's reset the error message state to nil.
        errorMessage = nil
        
        // Check if phone number is set
        if phoneNumber.isEmpty {
            errorMessage = "Please enter a phone number."
            isWaitingForVerificationCode = false
            return
        }
        
        // Check if it's a valid phone number
        do {
            let parsedNumber = try PhoneNumberUtility().parse(phoneNumber)
            internationalPhoneNumber = PhoneNumberUtility().format(parsedNumber, toType: .e164)
        } catch {
            errorMessage = "Invalid phone number format, check the number and try again."
            isWaitingForVerificationCode = false
            return
        }
        
        // Show loader - The precedent verification is fast and making the button flashing so we activate the loading here
        isWaitingForVerificationCode = true
        
        // Get dataExchange from BeReal server
        if dataExchange == nil {
            do {
                let result = try await VonageService.shared.getDataExchange(deviceId: deviceId, phoneNumber: internationalPhoneNumber)
                dataExchange = result
                showCaptcha = true
            } catch VonageError.invalidResponse(let message) {
                errorMessage = message
                isWaitingForVerificationCode = false
            } catch {
                errorMessage = "An unexpected error occurred."
                isWaitingForVerificationCode = false
            }
            return
        }
        
        if let captchaToken = captchaToken {
            do {
                vonageRequestId = try await VonageService.shared.sendSMS(
                    captchaToken: captchaToken,
                    deviceId: deviceId,
                    phoneNumber: internationalPhoneNumber
                )
                showOTPView = true
            } catch VonageError.invalidResponse(let message) {
                errorMessage = message
            } catch {
                errorMessage = "An unexpected error occurred."
            }
            isWaitingForVerificationCode = false
        }
  }
}

#Preview {
    MainContainer()
}
