import Foundation

public enum ParseMode {
    case strict // Required payment fields must be present in data
    case loose
}

extension Parser {
    // 8 bytes - service data:
    private static let headerBytesCount = 8

    // 2 bytes - format:
    private static let formatBytesRange = 0...1

    // 4 bytes - version
    private static let versionBytesRange = 2...5

    // 1 byte - encoding
    private static let encodingByteIndex = 6

    // 1 byte - separator
    private static let separatorByteIndex = 7
}

extension Parser {
    // "ST"
    private static let requiredFormat: [UInt8] = [83, 84]

    // "0001"
    private static let supportedVersion: [UInt8] = [48, 48, 48, 49]

    // "1" – WIN1251
    // "2" – UTF8
    // "3" – КОI8-R
    // "123"
    private static let allowedEncodingValues: [UInt8] = [49, 50, 51]

    // "="
    private static let dataSeparator: UInt8 = 61
}

public struct Parser {

    public init() { }

    public func parse(with data: Data, parseMode: ParseMode = .strict) -> PaymentData? {
        return parse(with: [UInt8](data), parseMode: parseMode)
    }

    public func parse(with string: String, parseMode: ParseMode = .strict) -> PaymentData? {
        return parse(with: [UInt8](string.utf8), parseMode: parseMode)
    }

    private func parse(with data: [UInt8], parseMode: ParseMode ) -> PaymentData? {
        guard data.count >= Parser.headerBytesCount else {
            return nil
        }

        let formatId = Array(data[Parser.formatBytesRange])
        guard formatId == Parser.requiredFormat else {
            return nil
        }

        let version = Array(data[Parser.versionBytesRange])
        guard version == Parser.supportedVersion else {
            return nil
        }

        let encoding = data[Parser.encodingByteIndex]
        guard Parser.allowedEncodingValues.contains(encoding) else {
            return nil
        }

        let separator = data[Parser.separatorByteIndex]

        let fieldsData = data.suffix(from: Parser.headerBytesCount)
        let strEncoding = stringEncoding(with: encoding) // String.Encoding.utf8
        let fields = Parser.parseFields(from: fieldsData, separator: separator, encoding: strEncoding)
        guard fields.count > 0 else {
            // no payment fields at all
            return nil
        }

        let hasRequiredFields: Bool
        if case .strict = parseMode {
            hasRequiredFields = PaymentField.required.allSatisfy { fields[$0.rawValue.lowercased()] != nil }
        } else {
            hasRequiredFields = true
        }
        guard hasRequiredFields else {
            // not all required fields filled
            return nil
        }
        return PaymentData(fields: fields)
    }

    private static func parseFields(from fieldsData: ArraySlice<UInt8>, separator: UInt8, encoding: String.Encoding) -> [String: String] {
        let fieldsInUInt8 = fieldsData.split(separator: separator)
        var stringFields = [String: String]()
        for field in fieldsInUInt8 {
            let split = field.split(separator: dataSeparator, maxSplits: 1, omittingEmptySubsequences: false)
            guard split.count > 1 else {
                continue
            }
            let key = Array(split[0])
            let val = Array(split[1])

            if let strKey = getString(bytes: key, encoding: encoding),
               let strVal = getString(bytes: val, encoding: encoding), shouldAdd(value: strVal) {
                stringFields[strKey.lowercased()] = strVal
            }
        }
        return stringFields
    }

    private static func getString(bytes: [UInt8], encoding: String.Encoding) -> String? {
        guard let str = String(bytes: bytes, encoding: encoding) else {
            return nil
        }
        let trimmedStr = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedStr.isEmpty {
            return  nil
        }
        return trimmedStr
    }

    private static let lowercaseIgnoreValues = ["null"]

    private static func shouldAdd(value: String) -> Bool {
        !lowercaseIgnoreValues.contains(value.lowercased())
    }

    private func stringEncoding(with value: UInt8) -> String.Encoding {
        switch value {
        case 49:
            return .windowsCP1251
        case 50:
            return .utf8
        case 51:
            return .koi8r
        default:
            return .utf8
        }
    }
}
