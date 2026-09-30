//
//  RecruitMyApplicationListEmptyView.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import SwiftUI

struct RecruitMyApplicationListEmptyView: View {

    let onListButtonTapped: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Spacer()

            Image.appImage(asset: .sleepBcsdSymbol)
                .frame(height: 75)

            Text("지원한 모집글이 없어요.")
                .font(.appFont(.pretendardMedium, size: 16))
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(height: 26)
                .padding(.bottom, 2)

            Text("직접 모집글을 작성하여 팀원을 모집해보세요.")
                .font(.appFont(.pretendardRegular, size: 14))
                .foregroundStyle(Color.appColor(.neutral600))
                .frame(height: 22)

            Button(action: onListButtonTapped) {
                Text("모집글 둘러보기")
                    .font(.appFont(.pretendardMedium, size: 16))
                    .foregroundStyle(Color.appColor(.new600))
                    .padding(.horizontal, 12)
                    .frame(height: 42)
                    .clipShape(.capsule)
                    .border(.appColor(.new400), width: 1, radius: 21)
                    .applySketchShadow(
                        color: .appColor(.neutral800),
                        alpha: 0.09,
                        x: 0,
                        y: 4,
                        blur: 10
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 12)

            Spacer()
        }
    }
}
