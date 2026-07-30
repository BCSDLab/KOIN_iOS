//
//  DepartmentSearchView.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

struct DepartmentSearchView: View {
    
    // MARK: - Layout
    enum Layout {
        static let topPadding: CGFloat = 20
        static let height: CGFloat = 45
        static let bottomPadding: CGFloat = 40
    }
    
    // MARK: - Properties
    let searchButtonTapped: (String)->Void
    let resetSearchButtonTapped: ()->Void
    @State private var keyword: String = ""
    private var searchButtonColor: Color {
        keyword.isEmpty ? .appColor(.neutral500) : .appColor(.new500)
    }
    
    // MARK: - Initialzier
    init(
        searchButtonTapped: @escaping (String) -> Void,
        resetSearchButtonTapped: @escaping ()->Void
    ) {
        self.searchButtonTapped = searchButtonTapped
        self.resetSearchButtonTapped = resetSearchButtonTapped
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            TextField(
                "DepartmentSearch",
                text: $keyword,
                prompt:
                    Text("검색어를 입력해주세요.")
                    .font(.appFont(.pretendardRegular, size: 12))
                    .foregroundStyle(Color.appColor(.neutral500))
            )
            .font(.appFont(.pretendardRegular, size: 12))
            .foregroundStyle(Color.appColor(.neutral800))
            .padding(.leading, 20)
            .onSubmit {
                keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                if !keyword.isEmpty {
                    searchButtonTapped(keyword)
                }
            }
            
            Spacer()
            
            Button {
                keyword = ""
                resetSearchButtonTapped()
            } label: {
                Image(systemName: "x.circle.fill")
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.appColor(.neutral300))
            }
            .buttonStyle(.plain)
            .isHidden(keyword.isEmpty)
            
            Button {
                searchButtonTapped(keyword)
            } label: {
                Image.appImage(asset: .noticeSearch)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(searchButtonColor)
                    .frame(width: 21, height: 21)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
            }
            .buttonStyle(.plain)
            .disabled(keyword.isEmpty)
        }
        .frame(height: Layout.height)
        .frame(maxWidth: .infinity)
        .background(Color.appColor(.neutral0))
        .clipShape(.capsule)
        .padding(.top, Layout.topPadding)
        .padding(.bottom, Layout.bottomPadding)
    }
}
