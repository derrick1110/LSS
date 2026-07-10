import Foundation

struct RecordRequest: Equatable {
    let amount: Decimal
    let category: TransactionCategory
    let source: TransactionSource
}

enum RecordURLParserError: LocalizedError, Equatable {
    case unsupportedRoute
    case missingAmount
    case invalidAmount
    case nonPositiveAmount

    var errorDescription: String? {
        switch self {
        case .unsupportedRoute:
            "不支持的快捷指令入口"
        case .missingAmount:
            "请输入金额"
        case .invalidAmount:
            "金额格式不正确"
        case .nonPositiveAmount:
            "金额必须大于 0"
        }
    }
}

struct RecordURLParser {
    func parse(_ url: URL) -> Result<RecordRequest, RecordURLParserError> {
        guard isRecordRoute(url) else {
            return .failure(.unsupportedRoute)
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .failure(.unsupportedRoute)
        }

        let queryItems = components.queryItems ?? []
        guard let amountText = queryItems.firstValue(named: "amount")?.trimmingCharacters(in: .whitespacesAndNewlines),
              !amountText.isEmpty else {
            return .failure(.missingAmount)
        }

        guard let amount = Decimal(string: amountText, locale: Locale(identifier: "en_US_POSIX")) else {
            return .failure(.invalidAmount)
        }

        guard amount > 0 else {
            return .failure(.nonPositiveAmount)
        }

        let category = queryItems.firstValue(named: "category")
            .flatMap(TransactionCategory.init(rawValue:)) ?? .food
        let source = queryItems.firstValue(named: "source")
            .flatMap(TransactionSource.init(rawValue:)) ?? .shortcut

        return .success(RecordRequest(amount: amount, category: category, source: source))
    }

    private func isRecordRoute(_ url: URL) -> Bool {
        url.scheme == "jijianbook" && (url.host == "record" || url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) == "record")
    }
}

private extension Array where Element == URLQueryItem {
    func firstValue(named name: String) -> String? {
        first { $0.name == name }?.value
    }
}
