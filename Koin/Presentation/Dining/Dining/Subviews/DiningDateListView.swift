//
//  DiningDateListView.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import SwiftUI

struct DiningDateListView: View {
    // MARK: - Properties
    let rows: [DiningDateRowView.Configuration]
    let action: (Date)->Void
    
    // MARK: - Initializer
    init(
        dates: [Date],
        selectedDate: Date,
        action: @escaping (Date)->Void
    ) {
        self.rows = dates.map { date in
            DiningDateRowView.Configuration(
                from: date,
                selectedDate: selectedDate
            )
        }
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        HStack(alignment: .center) {
            ForEach(rows) { configuration in
                DiningDateRowView(
                    configuration: configuration,
                    action: action
                )
                
                if configuration.id != rows.last?.id {
                    Spacer()
                }
            }
        }
//        .animation(.easeInOut(duration: 0.1), value: row)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .padding(.top, 24)
    }
}
