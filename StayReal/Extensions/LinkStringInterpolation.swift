import SwiftUI

// See https://gist.github.com/ole/8d1ef1cab4bbd387c3bdc8c69e29eae3
extension LocalizedStringKey.StringInterpolation {
  /// String interpolation support for links in Text.
  ///
  /// Usage:
  ///
  ///     let url: URL = …
  ///     Text("\("Link title", link: url)")
  mutating func appendInterpolation(_ linkTitle: String, link url: URL) {
    var linkString = AttributedString(linkTitle)
    linkString.link = url
    linkString.foregroundColor = .blue
    self.appendInterpolation(linkString)
  }

  /// String interpolation support for links in Text.
  ///
  /// Usage:
  ///
  ///     Text("\("Link title", link: "https://example.com")")
  mutating func appendInterpolation(_ linkTitle: String, link urlString: String) {
    self.appendInterpolation(linkTitle, link: URL(string: urlString)!)
  }
}
