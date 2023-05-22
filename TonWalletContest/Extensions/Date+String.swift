import Foundation

extension Date {
    enum FormatType {
        case full
        case short

        var format: String {
            switch self {
            case .full: return "MMM d, yyyy 'at' HH:mm"
            case .short: return "HH:mm"
            }
        }
    }

    func formattedDateString(type: FormatType) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = type.format
        return dateFormatter.string(from: self)
    }
}
