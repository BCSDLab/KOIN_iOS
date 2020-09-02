//
//  Search+View.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/27.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import CoreData

struct ClearButton: ViewModifier
{
    @EnvironmentObject var viewModel: SearchViewModel
    @Binding var text: String
    @Binding var isCleared: Bool
    
    public func body(content: Content) -> some View
    {
        if (text.isEmpty) {
            self.isCleared = false
        }
        return ZStack(alignment: .trailing)
        {
            content
            
            if !text.isEmpty
            {
                Button(action:
                    {
                        self.text = ""
                        self.isCleared = false
                })
                {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject var tabData: ViewRouter
    @State var query: String = ""
    @State var isSearched: Bool = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: RecentSearch.allRecentFetchRequest()) var recentSearch: FetchedResults<RecentSearch>
    
    
    init() {
        self.viewModel = SearchViewModel(searchFetcher: SearchFetcher())
        UITableView.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        return GeometryReader { geometry in
            VStack{
                List {
                    if (self.isSearched) {
                        if (self.viewModel.dataSource.isEmpty) {
                            VStack {
                                Image("no_search")
                                    .resizable()
                                    .frame(width: 75, height: 75, alignment: .center)
                                    .padding(.bottom, 24)
                                Text("일치하는 검색 결과가 없습니다.")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 159/255, green: 169/255, blue: 179/255))
                            }.frame(width: 300,alignment: .center)
                        } else {
                            self.forecastSection
                        }
                    } else {
                        Text("최근 검색")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: 0x175c8e))
                            .frame(height: 20, alignment: .leading)
                        
                        ForEach(self.recentSearch) { recent in
                            Button(action: {
                                self.viewModel.query = recent.query ?? ""
                                self.query = recent.query ?? ""
                                self.viewModel.fetchSearch(query: recent.query ?? "")
                            }) {
                                Text(recent.query ?? "")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: 0x252525))
                                    .padding(8)
                            }
                        }/*.onDelete { (indexSet) in
                         let blogIdeaToDelete = self.recentSearch[indexSet.first!]
                         self.managedObjectContext.delete(blogIdeaToDelete)
                         
                         do {
                         try self.managedObjectContext.save()
                         } catch {
                         print(error)
                         }
                         }*/
                    }
                    
                }.onReceive(self.viewModel.searchResult) { result in
                    self.isSearched = result
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(trailing: HStack {
                    CustomTextField(
                        placeholder: Text("검색어를 입력해주세요.")
                            .foregroundColor(Color(red: 210/255, green: 218/255, blue: 226/255))
                            .font(.system(size: 14)),
                        text: self.$query,
                        editingChanged: { test in
                            print(test)
                    }, commit: {
                        self.viewModel.fetchSearch(query: self.query)
                    }
                        ).modifier(ClearButton(text: self.$query, isCleared: self.$isSearched))
                        .onReceive(self.viewModel.searchResult) { result in
                        self.isSearched = result
                        let data = RecentSearch(context: self.managedObjectContext)
                        data.query = self.query
                        data.created_at = Date()
                        print(data)
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print(error)
                        }
                    }
                    
                    Button(action: {
                        self.viewModel.fetchSearch(query: self.query)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                        
                    }
                    .padding(.leading, 16)
                }
                .frame(width: 300,alignment: .center))
                    
                .background(Color.white)
                .listStyle(GroupedListStyle())
            }.background(Color("light_navy"))
            
        }.onAppear{
            
        }
        
    }
}

private extension SearchView {
    
    var forecastSection: some View {
        Section {
            Text("\'\(viewModel.query)\' 검색 결과입니다.")
                .font(.system(size: 14))
                .foregroundColor(Color("light_navy"))
            ForEach(viewModel.dataSource) { vm in
                SearchRow(viewModel: vm).environment(\.managedObjectContext, self.managedObjectContext)
                
            }
        }
    }
    /*
     var recentSearchSection: some View {
     Section {
     ForEach(self.recentSearch) { recent in
     Text(recent.query ?? "")
     .font(.headline)
     }
     }
     }*/
    
}
