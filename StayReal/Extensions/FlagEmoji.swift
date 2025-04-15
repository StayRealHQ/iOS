extension String {
    var flagEmoji: String {
        return self.uppercased().unicodeScalars.reduce("") {
            guard let scalar = UnicodeScalar(127397 + $1.value) else { return $0 }
            return $0 + String(scalar)
        }
    }
}
