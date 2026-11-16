import SwiftUI
import SwiftData

struct TransactionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let transaction: Transaction?
    private let onSaved: (UUID) -> Void

    @State private var amountText: String
    @State private var category: TransactionCategory
    @State private var note: String
    @State private var createdAt: Date
    @State private var errorMessage: String?

    init(
        transaction: Transaction?,
        initialErrorMessage: String?,
        onSaved: @escaping (UUID) -> Void
    ) {
        self.transaction = transaction
        self.onSaved = onSaved
        _amountText = State(initialValue: transaction.map { MoneyFormatter.plain.string(from: $0.amount as NSDecimalNumber) ?? "" } ?? "")
        _category = State(initialValue: transaction?.category ?? .food)
        _note = State(initialValue: transaction?.note ?? "")
        _createdAt = State(initialValue: transaction?.createdAt ?? Date())
        _errorMessage = State(initialValue: initialErrorMessage)
    }

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section("金额") {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                        .monospacedDigit()
                }

                Section("分类") {
                    Picker("分类", selection: $category) {
                        ForEach(TransactionCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("详情") {
                    TextField("备注", text: $note)
                    DatePicker("时间", selection: $createdAt)
                }

                if transaction != nil {
                    Section {
                        Button(role: .destructive) {
                            deleteTransaction()
                        } label: {
                            Text("删除记录")
                        }
                    }
                }
            }
            .navigationTitle(transaction == nil ? "补记" : "编辑")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                }
            }
        }
    }

    private func save() {
        guard let amount = MoneyFormatter.decimal(from: amountText) else {
            errorMessage = "金额格式不正确"
            return
        }

        guard amount > 0 else {
            errorMessage = "金额必须大于 0"
            return
        }

        let savedTransaction: Transaction
        if let transaction {
            transaction.amount = amount
            transaction.category = category
            transaction.note = note
            transaction.createdAt = createdAt
            transaction.updatedAt = Date()
            savedTransaction = transaction
        } else {
            let newTransaction = Transaction(
                amount: amount,
                category: category,
                note: note,
                source: .manual,
                createdAt: createdAt,
                updatedAt: Date()
            )
            modelContext.insert(newTransaction)
            savedTransaction = newTransaction
        }

        do {
            try modelContext.save()
            onSaved(savedTransaction.id)
            dismiss()
        } catch {
            errorMessage = "保存失败，请稍后重试"
        }
    }

    private func deleteTransaction() {
        guard let transaction else { return }
        modelContext.delete(transaction)
        try? modelContext.save()
        dismiss()
    }
}
