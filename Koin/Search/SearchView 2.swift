//
//  Search+View.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/27.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    private func search() {
        viewModel.fetchSearch()
    }
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        List {
            searchField
            // MARK:- 검색 여부에 따라 empty, 최근 검색 표시
            if viewModel.dataSource.isEmpty {
                emptySection
            } else {
                forecastSection
            }
        }
            
        .listStyle(GroupedListStyle())
    }
}

private extension SearchView {
    var searchField: some View {
        HStack(alignment: .center) {
            TextField("e.g. Cupertino", text: $viewModel.query, onCommit: search)
        }
    }
    
    var forecastSection: some View {
        Section {
            ForEach(viewModel.dataSource, content: SearchRow.init(viewModel:))
        }
    }
    
    // MARK:- 최근 검색 항목 가져올 시 데이터베이스 활용
    
    /*
    var cityHourlyWeatherSection: some View {
        Section {
            NavigationLink(destination: viewModel.currentWeatherView) {
                VStack(alignment: .leading) {
                    Text(viewModel.city)
                    Text("Weather today")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    */
    var emptySection: some View {
        Section {
            Image("no_search")
            Text("일치하는 검색 결과가 없습니다.")
        }
    }
}
