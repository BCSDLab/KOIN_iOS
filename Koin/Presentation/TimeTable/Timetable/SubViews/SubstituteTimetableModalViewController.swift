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
    private var customLecture: (String, [Int])?
    
    // MARK: - Initializer
    init(onSubstituteButtonTapped: @escaping (Any) -> Void) {
        self.onSubstituteButtonTapped = onSubstituteButtonTapped
        
        let mainTitle = NSAttributedString(
            string: "시간표가 중복돼요.",
            attributes: [
                .font: UIFont.appFont(.pretendardBold, size: 16),
                .foregroundColor: UIColor.appColor(.neutral800)
            ]
        )
        
        let subTitle = {
            let fullText = "추가하시려는 시간에 이미 다른 강의가\n있어요. 새로운 강의로 대체하시겠어요?"
            let highlightedText = "새로운 강의로 대체"
            
            let highlightRange = (fullText as NSString).range(of: highlightedText)
            
            let attributedString = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor: UIColor.appColor(.neutral600)
                ]
            )
            
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.appColor(.warning500),
                range: highlightRange
            )
            return attributedString
        }()
        
        super.init(configuration: .init(
            appearance: .primary,
            content: .attributedTitles(
                mainTitle: mainTitle,
                subTitle: subTitle
            ),
            button: .buttons(
                leftButtonTitle: "취소",
                rightButtonTitle: "대체하기",
                rightButtonAction: {}
            )
        ))
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(lectureData: LectureData) {
        self.lectureData = lectureData
        self.customLecture = nil
    }
    
    func configure(customLecture: (String, [Int])) {
        self.lectureData = nil
        self.customLecture = customLecture
    }
    
    // MARK: - Override
    override func rightButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            if let lectureData {
                onSubstituteButtonTapped(lectureData)
            } else if let customLecture {
                onSubstituteButtonTapped(customLecture)
            }
        }
    }
}
