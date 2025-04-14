import SwiftUI

struct OTPInputField: View {
    @Binding var text: String
    
    @State var precedentCount = 0
    @State var placeholder = "123 456"
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            ZStack {
                Text(placeholder)
                    .fontDesign(.monospaced)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
                    .kerning(5)
                TextField("", text: $text)
                    .fontDesign(.monospaced)
                    .keyboardType(.numberPad)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .kerning(5)
                    .focused($isFocused)
                    .frame(width: 210)
                    .onChange(of: text) {
                        if (text.count > precedentCount) { //character added
                            if (text.count >= 3) {
                                let clean = text.replacingOccurrences(of: " ", with: "")
                                text = ""
                                
                                if clean.count >= 3 {
                                    text += String(clean.prefix(3))
                                }
                                if clean.count > 3 {
                                    let remaining = clean.dropFirst(3)
                                    text += " " + String(remaining.prefix(3))
                                }
                            }
                        } else { //character removed
                            if (text.count == 3) {
                                text = String(text.prefix(2))
                            }
                        }
                        text = String(text.prefix(7))
                        placeholder = String(repeating: " ", count: text.count) + "123 456".suffix(7 - text.count)
                        precedentCount = text.count
                    }
            }
            Spacer()
        }
        .onAppear {
            isFocused = true
        }
    }
}

struct OTPView: View {
    @EnvironmentObject var keychain: Keychain
    
    let deviceId: String
    @Binding var vonageRequestId: String?
    
    @State var errorMessage: String?
    @State var isVerifyingCode = false
    
    @State var otpCode: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("""
            What’s the code
            you received ?
            """)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fixedSize()
            .padding(.top, 30)
            HStack(alignment: .center, spacing: 0) {
                OTPInputField(text: $otpCode)
            }
            .frame(height: 50)
            .padding(.top, 20)
            .disabled(isVerifyingCode)
            if let error = errorMessage {
                Text(error)
                    .font(.subheadline.bold())
                    .foregroundColor(Color.stayRealRed)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button {
                Task {
                    await VerifyCode()
                }
            } label: {
                if (isVerifyingCode) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                } else {
                    Text("Verify this code")
                }
            }
            .buttonStyle(ProminentButtonStyle())
            .disabled(isVerifyingCode)
            .padding(.top)
        }
        .padding()
        .background(Color.background)
        .foregroundStyle(.white)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_mini")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
        }
    }
    
    func VerifyCode() async {
        // Getting the code without space format
        let code = otpCode.replacingOccurrences(of: " ", with: "")
        
        // Checking code size and is only number
        if code.count != 6 || !code.allSatisfy(\.isNumber) {
            errorMessage = "Please enter a valid 6 digit code"
            return
        }
        
        // Setting loader
        isVerifyingCode = true
        
        // Checking for vonageRequestId
        guard let vonageRequestId = vonageRequestId else {
            errorMessage = "Invalid Vonage Request ID"
            isVerifyingCode = false
            return
        }
        
        do {
            let token = try await VonageService.shared.verifySMS(
                code: code,
                deviceId: deviceId,
                vonageRequestId: vonageRequestId
            )
            
            let idToken = try await FirebaseService.shared.verifyCustomToken(token)
            
            let tokens = try await TokenService.shared.grantFirebase(
                idToken: idToken,
                deviceId: deviceId
            )
            
            let success = keychain.setCredentials(
                    accessToken: tokens.access_token,
                    refreshToken: tokens.refresh_token,
                    deviceID: deviceId
                )
            if (!success) {
                errorMessage = "Failed to save tokens to keychain"
                isVerifyingCode = false
                return
            }
        }
        catch VonageError.invalidResponse(let message) {
            errorMessage = message
        } catch VonageError.incorrectCode(let message) {
            errorMessage = message
        } catch {
            errorMessage = "An unexpected error occurred."
        }
        isVerifyingCode = false
    }
}

#Preview {
    NavigationView {
        MainContainer()
    }
    .colorScheme(.dark)
}
