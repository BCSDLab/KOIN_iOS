//
//  RecruitListHeaderView.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import SwiftUI

struct RecruitListHeaderView: View {
    
    // MARK: - State
    @State private var keyword: String = ""
    
    // MARK: - Properties
    let filterState: RecruitListFilter
    let onSearchTapped: (String)->Void
    let onFilterButtonTapped: ()->Void
    let onFilterDeleted: (String)->Void
    
    // MARK: - Initializer
    init(
        filterState: RecruitListFilter,
        onSearchTapped: @escaping (String) -> Void,
        onFilterButtonTapped: @escaping () -> Void,
        onFilterDeleted: @escaping (String) -> Void
    ) {
        self.filterState = filterState
        self.onSearchTapped = onSearchTapped
        self.onFilterButtonTapped = onFilterButtonTapped
        self.onFilterDeleted = onFilterDeleted
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                textField
                filterButton
            }
            .padding(.horizontal, 22)
            
            if !filterState.nonDefaultItems.isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        ForEach(filterState.nonDefaultItems, id: \.self) { item in
                            Button {
                                onFilterDeleted(item)
                            } label: {
                                HStack(spacing: 0) {
                                    Text(item)
                                        .font(.appFont(.pretendardMedium, size: 12))
                                        .foregroundStyle(Color.appColor(.neutral0))
                                    Image.appImage(asset: .recruitFilterX)
                                }
                                .padding(.horizontal, 10)
                                .frame(height: 30)
                                .background(Color.appColor(.new400))
                                .clipShape(.capsule)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 22)
                }
                .frame(height: 30)
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)))
            }
        }
        .animation(.spring(duration: 0.2), value: filterState.nonDefaultItems)
    }
    
    @ViewBuilder
    private var textField: some View {
        HStack(alignment: .center, spacing: 10) {
            TextField(text: $keyword) {
                Text("검색어를 입력해주세요.")
                    .font(.appFont(.pretendardRegular, size: 12))
                    .foregroundStyle(Color.appColor(.neutral600))
            }
            .font(.appFont(.pretendardRegular, size: 12))
            .foregroundStyle(Color.appColor(.neutral800))
            .onSubmit {
                onSearchTapped(keyword)
            }
            
            Button {
                onSearchTapped(keyword)
            } label: {
                Image.appImage(asset: .recruitSearch)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: 36)
        .background(Color.appColor(.neutral0))
        .clipShape(.capsule)
    }
    
    @ViewBuilder
    private var filterButton: some View {
        Button {
            onFilterButtonTapped()
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Text("필터")
                    .font(.appFont(.pretendardRegular, size: 12))
                    .foregroundStyle(Color.appColor(.neutral600))
                
                Image.appImage(asset: .recruitFilter)
            }
            .padding(.horizontal, 15)
            .frame(height: 36)
            .background(Color.appColor(.neutral0))
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}
