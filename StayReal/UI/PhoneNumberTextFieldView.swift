import PhoneNumberKit
import SwiftUI

struct PhoneNumberTextFieldView: View {
  @Binding var phoneNumber: String

  var body: some View {
    TextField("06 12 34 56 78", text: $phoneNumber)
      .keyboardType(.phonePad)
      .textContentType(.telephoneNumber)
      .padding(.vertical, 10)
      .padding(.horizontal, 20)
      .background(
        Color(.secondarySystemBackground),
        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
      )
      .font(.title.weight(.semibold))
      .onChange(of: phoneNumber) { _, value in
        do {
          phoneNumber = PartialFormatter()
            .formatPartial(value)
        }
      }
  }
}
