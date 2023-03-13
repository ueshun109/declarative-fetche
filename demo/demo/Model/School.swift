struct School: Codable, Equatable {
  var address: String
  var name: String
}

extension School {
  static let fake: School = .init(address: "One Apple Park Way Cupertino", name: "Apple School")
  static let fake2: School = .init(address: "One Apple Park Way Cupertino", name: "Apple School2")
}
