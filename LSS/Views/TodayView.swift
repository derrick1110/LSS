import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.createdAt, order: .reverse) private var transactions: [Transaction]

    @Binding var highlightedTransactionID: UUID?
    @Binding var isShowingCreateForm: Bool
    @Binding var formErrorMessage: String?

    @State private var editingTransaction: Transaction?

    private var todayTransactions: [Transaction] {
        transactions.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    private var todayTotal: Decimal {
        todayTransactions.reduce(Decimal(0)) { $0 + $1.amount }
    }

    private var categoryTotals: [TransactionCategory: Decimal] {
        todayTransactions.reduce(into: [:]) { result, transaction in
            result[transaction.category, default: 0] += transaction.amount
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("今日总额")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(MoneyFormatter.currencyText(todayTotal))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    CategoryShareView(totals: categoryTotals, totalAmount: todayTotal)
                        .padding(.vertical, 8)
                }

                Section("今日流水") {
                    if todayTransactions.isEmpty {
                        ContentUnavailableView("今天还没有记录", systemImage: "tray")
                    } else {
                        ForEach(todayTransactions) { transaction in
                            Button {
                                editingTransaction = transaction
                            } label: {
                                TransactionRowView(
                                    transaction: transaction,
                                    isHighlighted: highlightedTransactionID == transaction.id
                                )
                            }
                            .buttonStyle(.plain)
                            .swipeActions {
                                Button(role: .destructive) {
                                    delete(transaction)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("极简记账")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        formErrorMessage = nil
                        isShowingCreateForm = true
                    } label: {
                        Label("补记", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateForm) {
                TransactionFormView(
                    transaction: nil,
                    initialErrorMessage: formErrorMessage
                ) { savedID in
                    highlightedTransactionID = savedID
                    clearHighlightLater()
                }
            }
            .sheet(item: $editingTransaction) { transaction in
                TransactionFormView(transaction: transaction, initialErrorMessage: nil) { savedID in
                    highlightedTransactionID = savedID
                    clearHighlightLater()
                }
            }
            .onChange(of: highlightedTransactionID) { _, newValue in
                if newValue != nil {
                    clearHighlightLater()
                }
            }
        }
    }

    private func delete(_ transaction: Transaction) {
        modelContext.delete(transaction)
        try? modelContext.save()
    }

    private func clearHighlightLater() {
        let currentID = highlightedTransactionID
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if highlightedTransactionID == currentID {
                highlightedTransactionID = nil
            }
        }
    }
}
