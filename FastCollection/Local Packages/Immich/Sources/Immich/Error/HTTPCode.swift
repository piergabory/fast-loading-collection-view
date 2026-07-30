import Foundation

struct HTTPStatus: LocalizedError {
    let code: Int
    let body: String?

    var errorDescription: String? {
        """
        HTTP \(code)
        \(body ?? "--")
        """
    }
}
