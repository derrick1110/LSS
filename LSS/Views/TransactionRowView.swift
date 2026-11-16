import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.title)
                    .font(.headline)
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(transaction.createdAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(MoneyFormatter.currencyText(transaction.amount))
                .font(.headline)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
        .listRowBackground(isHighlighted ? Color.green.opacity(0.18) : Color.clear)
    }
}
