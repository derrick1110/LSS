import SwiftUI

struct CategoryShareView: View {
    let totals: [TransactionCategory: Decimal]
    let totalAmount: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类占比")
                .font(.headline)

            ForEach(TransactionCategory.allCases) { category in
                let amount = totals[category, default: 0]
                let ratio = ratio(for: amount)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(category.title)
                        Spacer()
                        Text("\(Int((ratio * 100).rounded()))%")
                            .foregroundStyle(.secondary)
                        Text(MoneyFormatter.currencyText(amount))
                            .monospacedDigit()
                    }
                    ProgressView(value: ratio)
                        .tint(tint(for: category))
                }
            }
        }
    }

    private func ratio(for amount: Decimal) -> Double {
        guard totalAmount > 0 else { return 0 }
        let amountNumber = amount as NSDecimalNumber
        let totalNumber = totalAmount as NSDecimalNumber
        return amountNumber.dividing(by: totalNumber).doubleValue
    }

    private func tint(for category: TransactionCategory) -> Color {
        switch category {
        case .food:
            .green
        case .daily:
            .blue
        case .other:
            .orange
        }
    }
}
