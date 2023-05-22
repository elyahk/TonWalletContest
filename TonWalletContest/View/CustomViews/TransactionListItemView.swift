import SwiftUI

struct TransactionListItemView: View {
    var transaction: Transaction1

    init(transaction: Transaction1) {
        self.transaction = transaction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(spacing: 3.0) {
                TransactionAmountView(
                    amount: transaction.amount,
                    color: transaction.isTransactionSend ? .systemRed : .systemGreen,
                    size: (19, 18, 16)
                )
                Text(transaction.isTransactionSend ? "to" : "from")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                Spacer()
                Text(transaction.date.formattedDateString(type: .short))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Text(transaction.senderAddress)
                .font(.system(size: 15, weight: .regular))
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
                .truncationMode(.middle)
                .padding(.top, -2.0)

            Text("\(transaction.fee) storage fee")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
            ChatBubble {
                Text(transaction.comment)
                    .font(.system(size: 15, weight: .regular))
                    .padding([.trailing], 10)
                    .padding([.leading], 15)
                    .padding([.bottom, .top], 8)
                    .multilineTextAlignment(.leading)
                    .background(Color(UIColor(red: 0.937, green: 0.937, blue: 0.953, alpha: 1).cgColor))
            }
        }
    }
}

