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

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text(item.timeText ?? "")
                        .font(.appFont(.pretendardMedium, size: 12))
                        .foregroundStyle(Color.ColorSystem.Neutral.gray600)
                        .frame(height: 19.2)
                        .isHidden(item.timeText == nil)
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
                
                Text(item.menu.byCharWrapping)
                    .font(.appFont(.pretendardMedium, size: 14))
                    .linespacing(fontSize: 14, percent: 236)
                    .foregroundStyle(Color.ColorSystem.Neutral.gray600)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
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
