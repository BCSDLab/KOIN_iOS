//
//  DiningMenuRowView.swift
//  koin
//
//  Created by 홍기정 on 10/6/26.
//

import SwiftUI
import Kingfisher

struct DiningMenuRowView: View {
    
    // MARK: - Property
    let item: DiningItem
    let onImageTapped: (DiningItem)->Void
    let onShareButtonTapped: (DiningItem)->Void
    
    // MARK: - ABTest
    let shouldShowReportButton: Bool
    let onReportButtonTapped: ()->Void
    
    // MARK: - Initializer
    init(
        item: DiningItem,
        onImageTapped: @escaping (DiningItem)->Void,
        onShareButtonTapped: @escaping (DiningItem)->Void,
        shouldShowReportButton: Bool,
        onReportButtonTapped: @escaping ()->Void
    ) {
        self.item = item
        self.onImageTapped = onImageTapped
        self.onShareButtonTapped = onShareButtonTapped
        self.shouldShowReportButton = shouldShowReportButton
        self.onReportButtonTapped = onReportButtonTapped
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            imageView
                .padding(.horizontal, 16)
            menusView
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            shareButton
        }
        .background(Color.appColor(.neutral0))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .applySketchShadow(
            color: .appColor(.neutral800),
            alpha: 0.02,
            x: 0,
            y: 1,
            blur: 1
        )
        .applySketchShadow(
            color: .appColor(.neutral800),
            alpha: 0.04,
            x: 0,
            y: 2,
            blur: 4
        )
    }
}

extension DiningMenuRowView {
    // MARK: - HeaderView
    @ViewBuilder private var headerView: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(item.place.name)
                .font(.appFont(.pretendardSemiBold, size: 18))
                .foregroundStyle(Color.appColor(.neutral800))
            
            if item.isSoldOut {
                soldoutChip
            } else if item.isChanged {
                changedChip
            }
            if !item.isSoldOut && shouldShowReportButton {
                reportButton
                    .anchorPreference(
                        key: ReportButtonPreferenceKey.self,
                        value: .bounds
                    ) { anchor in
                        item.place == .cornerA ? anchor : nil
                    }
            }
            
            Spacer()
            
            Text(item.kcalPriceText)
                .font(.appFont(.pretendardRegular, size: 12))
                .foregroundStyle(Color.appColor(.neutral500))
        }
    }
    
    @ViewBuilder private var soldoutChip: some View {
        Text("품절")
            .font(.appFont(.pretendardMedium, size: 14))
            .foregroundStyle(Color.appColor(.new500))
            .padding(.horizontal, 8)
            .frame(height: 30)
            .background(Color.appColor(.new100))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    @ViewBuilder private var changedChip: some View {
        Text("변경")
            .font(.appFont(.pretendardMedium, size: 14))
            .foregroundStyle(Color.appColor(.neutral500))
            .padding(.horizontal, 8)
            .frame(height: 30)
            .background(Color.appColor(.neutral300))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    @ViewBuilder private var reportButton: some View {
        Button(action: onReportButtonTapped) {
            Image.appImage(asset: .diningReport)
        }
        .buttonStyle(.plain)
    }
}

extension DiningMenuRowView {
    private var is1000WonBreakfast: Bool {
        item.menu.contains { $0.contains("천원의 아침") }
    }
    
    // MARK: - ImageView
    @ViewBuilder var imageView: some View {
        switch item.image {
        case .imageUrl(let imageUrl):
            if is1000WonBreakfast {
                kfImageView(imageUrl: imageUrl)
            } else {
                Button {
                    onImageTapped(item)
                } label: {
                    kfImageView(imageUrl: imageUrl)
                }
                .buttonStyle(.plain)
            }
        case .empty(let imageAsset):
            Image.appImage(asset: imageAsset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 12)
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder private func kfImageView(imageUrl: String) -> some View {
        KFImage(URL(string: imageUrl))
            .fade(duration: 0.2)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay {
                if item.isSoldOut && !is1000WonBreakfast {
                    soldoutOverlayView
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 12)
    }
    
    @ViewBuilder private var soldoutOverlayView: some View {
        ZStack(alignment: .center) {
            Color.appColor(.neutral800)
                .opacity(0.5)
            
            
            VStack(alignment: .center, spacing: 18) {
                Image.appImage(asset: .noMeal)
                
                Text("품절된 메뉴입니다.")
                    .font(.appFont(.pretendardRegular, size: 12))
                    .foregroundStyle(Color.appColor(.neutral0))
            }
        }
    }
}

extension DiningMenuRowView {
    // MARK: - MenusView
    @ViewBuilder private var menusView: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 0, alignment: .leading),
                GridItem(.flexible(), spacing: 0, alignment: .leading)
            ],
            spacing: 0
        ) {
            ForEach(Array(item.menu.enumerated()), id: \.offset) { _, menu in
                Text(menu)
                    .font(.appFont(.pretendardRegular, size: 14))
                    .foregroundStyle(Color.appColor(.neutral800))
                    .padding(.vertical, 4)
                    .lineLimit(1)
            }
        }
    }
}

extension DiningMenuRowView {
    // MARK: - ShareButton
    @ViewBuilder private var shareButton: some View {
        Button {
            onShareButtonTapped(item)
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Image.appImage(asset: .share)
                Text("카카오톡으로 식단 공유하기")
                    .font(.appFont(.pretendardRegular, size: 14))
                    .foregroundStyle(Color.appColor(.neutral600))
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity, alignment: .center)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .border(Color.appColor(.neutral100), width: 1, edges: .init(arrayLiteral: .top))
    }
}

// MARK: - PreferenceKey
struct ReportButtonPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGRect>?

    static let defaultValue: Self.Value? = nil

    static func reduce(
        value: inout Self.Value,
        nextValue: () -> Self.Value
    ) {
        value = value ?? nextValue()
    }
}
