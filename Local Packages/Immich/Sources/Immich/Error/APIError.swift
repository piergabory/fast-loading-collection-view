import Foundation

struct APIError: LocalizedError, ExpressibleByStringLiteral {
    let errorDescription: String?

    init(stringLiteral value: StringLiteralType) {
        self.errorDescription = value
    }

    static let invalidResponse: Self = """
        Immich returned an invalid response.
        """
}
