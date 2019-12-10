//
//  ContentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @State var isDrawerOpen: Bool = false
    
       var body: some View {
           
        return ZStack {
            if !self.isDrawerOpen {
                NavigationView {
                    EmptyView()
                    .navigationBarTitle(Text("코인"))
                        .navigationBarItems(leading: Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.isDrawerOpen.toggle()
                            }
                        })
                        {
                            Image(systemName: "sidebar.left")
                        })
                }
            }
            NavigationDrawer(isOpen: self.isDrawerOpen)
        }.onTapGesture {
                if self.isDrawerOpen {
                    self.isDrawerOpen.toggle()
                }
        }
        
        TabView(selection: $selection){
            Text("홈")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("first")
                        Text("홈")
                    }
                }
                .tag(0)
            Text("카테고리")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("second")
                        Text("카테고리")
                    }
                }
                .tag(1)
            Text("내정보")
            .font(.title)
            .tabItem {
                VStack {
                    Image("second")
                    Text("내정보")
                }
            }
            .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
