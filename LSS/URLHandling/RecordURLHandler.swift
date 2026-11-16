import Foundation
import SwiftData

enum RecordURLHandlerResult {
    case created(UUID)
    case failed(RecordURLParserError)
}

struct RecordURLHandler {
    let modelContext: ModelContext
    let parser: RecordURLParser

    init(modelContext: ModelContext, parser: RecordURLParser = RecordURLParser()) {
        self.modelContext = modelContext
        self.parser = parser
    }

    func handle(_ url: URL) -> RecordURLHandlerResult {
        switch parser.parse(url) {
        case .success(let request):
            let now = Date()
            let transaction = Transaction(
                amount: request.amount,
                category: request.category,
                source: request.source,
                createdAt: now,
                updatedAt: now
            )
            modelContext.insert(transaction)

            do {
                try modelContext.save()
                return .created(transaction.id)
            } catch {
                modelContext.delete(transaction)
                return .failed(.unsupportedRoute)
            }

        case .failure(let error):
            return .failed(error)
        }
    }
}
