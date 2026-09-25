import ComposableArchitecture
import Foundation

struct NumberFactClient {
  var fetch: @Sendable (Int) async throws -> String
}

private struct NumberFactResponse: Decodable {
  let text: String
}

extension NumberFactClient: DependencyKey {
  static let liveValue = Self { number in
    let (data, _) = try await URLSession.shared.data(
      from: URL(string: "http://localhost:8080/\(number)")!
    )
    return try JSONDecoder().decode(NumberFactResponse.self, from: data).text
  }
  
  static let mockValue = Self { _ in "This is mock number" }
}

extension DependencyValues {
  var numberFact: NumberFactClient {
    get { self[NumberFactClient.self] }
    set { self[NumberFactClient.self] = newValue }
  }
}
