//
//  DiningDateRowView.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import SwiftUI

struct DiningDateRowView: View {
    typealias Configuration = DiningDateRowConfiguration
    
    // MARK: - Properties
    let configuration: Configuration
    let action: (Date)->Void
    
    // MARK: - Initializer
    init(
        configuration: Configuration,
        action: @escaping (Date)->Void
    ) {
        self.configuration = configuration
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button {
            action(configuration.date)
        } label: {
            VStack(alignment: .center, spacing: 0) {
                Text(configuration.date.weekday)
                    .font(.appFont(.pretendardRegular, size: 13))
                    .foregroundStyle(Color.appColor(.neutral600))
                    .frame(idealWidth: 21)
                    .padding(.bottom, 8)
                Text("\(configuration.date.day)")
                    .font(.appFont(configuration.font, size: configuration.fontSize))
                    .foregroundStyle(Color.appColor(configuration.textColor))
                    .indicator(style: configuration.indicatorStyle)
                    .padding(.bottom, 6)
                
                bottomIndicator(isToday: configuration.style == .today)
            }
        }
        .buttonStyle(.plain)
    }
}

extension DiningDateRowView {
    @ViewBuilder
    private func bottomIndicator(isToday: Bool) -> some View {
        Group {
            if isToday {
                Color.appColor(.new500)
            } else {
                Color.clear
            }
        }
        .frame(width: 15, height: 2)
        .clipShape(.capsule)
    }
}

// MARK: - Modifier
private extension View {
    func indicator(style: DiningDateRowView.Configuration.IndicatorStyle) -> some View {
        modifier(InidicatorModifier(style: style))
    }
}

private struct InidicatorModifier: ViewModifier {
    let style: DiningDateRowView.Configuration.IndicatorStyle
    let indicatorColor = Color.appColor(.new500)
    
    func body(content: Content) -> some View {
        switch style {
        case .fill:
            content
                .frame(width: 28, height: 28, alignment: .center)
                .background {
                    indicatorColor
                        .frame(width: 28, height: 28, alignment: .center)
                        .clipShape(.circle)
                }
        case .border:
            content
                .frame(width: 28, height: 28, alignment: .center)
                .background {
                    Color.clear
                        .frame(width: 28, height: 28, alignment: .center)
                        .border(indicatorColor, width: 1, radius: 14)
                }
        case .none:
            content
                .frame(width: 28, height: 28, alignment: .center)
        }
    }
}
