import Foundation

public struct PaymentData {

    private let fields: [String: String]

    public init(fields: [String: String]) {
        self.fields = fields
    }

    public subscript(key: PaymentField) -> String? {
        return fields[key.rawValue.lowercased()]
    }

    public subscript(key: String) -> String? {
        return fields[key.lowercased()]
    }
}
