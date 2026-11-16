import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case expense

    var id: String { rawValue }
}

enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case food
    case daily
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food:
            "餐饮"
        case .daily:
            "日用"
        case .other:
            "其他"
        }
    }
}

enum TransactionSource: String, Codable, CaseIterable, Identifiable {
    case shortcut
    case manual

    var id: String { rawValue }
}

@Model
final class Transaction: Identifiable {
    @Attribute(.unique) var id: UUID
    var amount: Decimal
    var type: TransactionType
    var category: TransactionCategory
    var note: String
    var source: TransactionSource
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        amount: Decimal,
        type: TransactionType = .expense,
        category: TransactionCategory = .food,
        note: String = "",
        source: TransactionSource = .manual,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.note = note
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func shortcutRecord(
        amount: Decimal,
        category: TransactionCategory = .food,
        createdAt: Date = Date()
    ) -> Transaction {
        Transaction(
            amount: amount,
            category: category,
            source: .shortcut,
            createdAt: createdAt,
            updatedAt: createdAt
        )
    }
}
