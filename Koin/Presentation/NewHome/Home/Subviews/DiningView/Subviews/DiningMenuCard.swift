//
//  DiningMenuCard.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI
import UIKit

struct DiningMenuCard: View {
    let item: HomeDiningItem
    let action: () -> Void

    private let contentWidth: CGFloat = 266

    private var menuLines: [String] {
        let menuText = item.menu
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
        guard !menuText.isEmpty else { return [""] }
        guard menuText.width(using: .appFont(.pretendardMedium, size: 14)) > contentWidth else {
            return [menuText]
        }

        let splitIndex = menuText.fittingPrefixIndex(
            maxWidth: contentWidth,
            font: .appFont(.pretendardMedium, size: 14)
        )
        let firstLine = String(menuText[..<splitIndex])
            .trimmingMenuLine()
        let secondLine = String(menuText[splitIndex...])
            .trimmingMenuLine()

        return secondLine.isEmpty ? [firstLine] : [firstLine, secondLine]
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text(item.timeText)
                        .font(.appFont(.pretendardMedium, size: 12))
                        .foregroundStyle(Color.ColorSystem.Neutral.gray600)
                        .frame(height: 19.2)

                    Spacer(minLength: 8)

                    HStack(spacing: 2) {
                        if let priceText = item.priceText {
                            Text(priceText)
                                .font(.appFont(.pretendardMedium, size: 12))
                                .foregroundStyle(Color.ColorSystem.Neutral.gray600)
                                .frame(height: 19.2)
                        }

                        if item.priceText != nil, item.kcalText != nil {
                            Text("·")
                                .font(.appFont(.pretendardSemiBold, size: 12))
                                .foregroundStyle(Color.ColorSystem.Neutral.gray600)
                                .frame(height: 19.2)
                        }

                        if let kcalText = item.kcalText {
                            Text(kcalText)
                                .font(.appFont(.pretendardSemiBold, size: 12))
                                .foregroundStyle(Color.ColorSystem.Neutral.gray700)
                                .frame(height: 19.2)
                        }
                    }
                }
                .frame(height: 19.2)

                Text(item.placeName)
                    .font(.appFont(.pretendardBold, size: 20))
                    .foregroundStyle(Color.ColorSystem.Neutral.gray800)
                    .frame(height: 32)

                ForEach(Array(menuLines.enumerated()), id: \.offset) { index, line in
                    Text(line)
                        .font(.appFont(.pretendardMedium, size: 14))
                        .foregroundStyle(Color.ColorSystem.Neutral.gray600)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, minHeight: 22.4, maxHeight: 22.4, alignment: .leading)
                }
            }
            .padding(.horizontal, 23)
            .padding(.vertical, 21)
            .frame(width: 312, height: 171, alignment: .topLeading)
            .background(Color.ColorSystem.Neutral.gray0)
            .clipShape(.rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.ColorSystem.Neutral.gray300, lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
    }
}

private extension String {
    func width(using font: UIFont) -> CGFloat {
        (self as NSString).size(withAttributes: [.font: font]).width
    }

    func fittingPrefixIndex(maxWidth: CGFloat, font: UIFont) -> String.Index {
        var low = 0
        var high = count
        var best = 1

        while low <= high {
            let mid = (low + high) / 2
            let index = self.index(startIndex, offsetBy: mid)
            let candidate = String(self[..<index])

            if candidate.width(using: font) <= maxWidth {
                best = max(mid, 1)
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        return index(startIndex, offsetBy: best)
    }

    func trimmingMenuLine() -> String {
        trimmingCharacters(in: CharacterSet(charactersIn: " ·\n\t"))
    }
}
