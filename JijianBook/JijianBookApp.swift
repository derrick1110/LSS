import SwiftUI
import SwiftData

@main
struct JijianBookApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Transaction.self)
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var highlightedTransactionID: UUID?
    @State private var isShowingCreateForm = false
    @State private var formErrorMessage: String?

    var body: some View {
        TodayView(
            highlightedTransactionID: $highlightedTransactionID,
            isShowingCreateForm: $isShowingCreateForm,
            formErrorMessage: $formErrorMessage
        )
        .onOpenURL { url in
            let result = RecordURLHandler(modelContext: modelContext).handle(url)
            switch result {
            case .created(let transactionID):
                highlightedTransactionID = transactionID
            case .failed(let error):
                formErrorMessage = error.errorDescription
                isShowingCreateForm = true
            }
        }
    }
}
