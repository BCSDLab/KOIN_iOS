//
//  SubstituteTimetableModalViewController.swift
//  koin
//
//  Created by 김나훈 on 12/4/24.
//

import UIKit

final class SubstituteTimetableModalViewController: KoinModalViewController {
    
    // MARK: - Properties
    private let onSubstituteButtonTapped: (Any) -> Void
    
    // MARK: - State
    private var lectureData: LectureData?
    
    // MARK: - Initializer
    init(onSubstituteButtonTapped: @escaping (Any) -> Void) {
        self.onSubstituteButtonTapped = onSubstituteButtonTapped
        
        super.init(configuration: .init(
            appearance: .new,
            content: .titles(
                mainTitleText: "시간표가 중복돼요",
                mainTitleStyle: .init(textColor: .neutral700, font: .pretendardMedium, fontSize: 18),
                subTitleText: "추가하려는 시간에 이미 다른 강의가 있어요\n새로운 강의로 대체할까요?"
            ),
            button: .buttons(
                leftButtonTitle: "취소",
                leftButtonStyle: .init(textColor: .neutral600, font: .pretendardMedium, fontSize: 15, borderColor: .gray, borderWidth: 1, cornerRadius: 8),
                rightButtonTitle: "대체하기",
                rightButtonAction: {},
                rightButtonStyle: .init(textColor: .neutral0, font: .pretendardMedium, fontSize: 15, backgroundColor: .new500, cornerRadius: 8)
            )
        ))
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(lectureData: LectureData) {
        self.lectureData = lectureData
    }
    
    // MARK: - Override
    override func rightButtonTapped() {
        guard let lectureData else { return }
        let onSubstitute = onSubstituteButtonTapped
        dismiss(animated: true) {
            onSubstitute(lectureData)
        }
    }
}
