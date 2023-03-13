struct Student: Identifiable, Codable, Equatable {
  var id: Int
  var firstName: String
  var lastName: String
}

extension [Student] {
  static let fakes: [Student] = [
    .init(id: 1, firstName: "taro", lastName: "tanaka"),
    .init(id: 2, firstName: "hanako", lastName: "suzuki"),
    .init(id: 3, firstName: "ryo", lastName: "hashimoto"),
  ]
}
