struct Teacher: Identifiable, Codable, Equatable {
  var id: Int
  var firstName: String
  var lastName: String
}

extension [Teacher] {
  static let fakes: [Teacher] = [
    .init(id: 1, firstName: "ichiro", lastName: "yamada"),
  ]
}
