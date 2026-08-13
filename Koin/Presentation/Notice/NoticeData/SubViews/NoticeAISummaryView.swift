//
//  NoticeAISummaryView.swift
//  koin
//
//  Created by 홍기정 on 8/11/26.
//

import SwiftUI

final class NoticeAISummaryViewHostingController: UIHostingController<NoticeAISummaryView> {
    
    // MARK: - Initializer
    init() {
        super.init(rootView: NoticeAISummaryView(summary: .init(status: .loading, items: [])))
    }
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(summary: NoticeAISummary) {
        rootView = NoticeAISummaryView(summary: summary)
    }
}

struct NoticeAISummaryView: View {
    
    // MARK: - Properties
    let summary: NoticeAISummary
    
    // MARK: - Initializer
    init(summary: NoticeAISummary) {
        self.summary = summary
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            
            switch summary.status {
            case .loading:
                EmptyView()
            case .success:
                successView
            case .pending:
                pendingView
            case .unavailable:
                unavailableView
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    var header: some View {
        HStack(alignment: .center, spacing: 2) {
            Text("AI 요약")
                .font(.appFont(.pretendardMedium, size: 14))
                .foregroundStyle(Color.appColor(.new800))
            
            Image.appImage(asset: .noticeAISummary)
            
            Spacer()
        }
        .frame(height: 22)
    }
    
    @ViewBuilder
    var pendingView: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            
            Text("요약중...")
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.neutral500))
                .frame(minHeight: 22)
            
            Spacer()
        }
        .padding(EdgeInsets(top: 40, leading: 0, bottom: 52, trailing: 0))
    }
    
    @ViewBuilder
    var unavailableView: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            
            Text("요약할 내용이 없어요.")
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.neutral500))
                .frame(minHeight: 22)
            
            Spacer()
        }
        .padding(EdgeInsets(top: 40, leading: 0, bottom: 52, trailing: 0))
    }
    
    @ViewBuilder
    var successView: some View {
        VStack(alignment: .leading, spacing: 22) {
            ForEach(summary.items) { item in
                Text(item.attributedString)
                    .linespacing(fontSize: 14, percent: 160)
            }
        }
    }
}
