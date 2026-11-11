//
//  DeleteLectureModelViewController.swift
//  koin
//
//  Created by 김나훈 on 12/10/24.
//

import UIKit

final class DeleteLectureModalViewController: KoinModalViewController {
    
    // MARK: - Properties
    private let onDeleteButtonTapped: (LectureData) -> Void
    private let lectureData: LectureData
    
    // MARK: - Initializer
    init(
        lectureData: LectureData,
        onDeleteButtonTapped: @escaping (LectureData) -> Void
    ) {
        self.lectureData = lectureData
        self.onDeleteButtonTapped = onDeleteButtonTapped
        
        let title = "\(lectureData.name)\(lectureData.name.hasFinalConsonant() ? "을" : "를") 삭제하시겠어요?"
        let attributedTitle = NSMutableAttributedString(string: title, attributes: [
            .font: UIFont.appFont(.pretendardMedium, size: 16),
            .foregroundColor: UIColor.appColor(.neutral800)
        ])
        attributedTitle.addAttribute(.font, value: UIFont.appFont(.pretendardSemiBold, size: 16), range: (title as NSString).range(of: "삭제", options: .backwards))
        let subtitle = NSAttributedString(string: "삭제한 강의는 수업추가에서 다시 추가할 수 있어요.", attributes: [
            .font: UIFont.appFont(.pretendardMedium, size: 15),
            .foregroundColor: UIColor.appColor(.neutral800)
        ])
        super.init(configuration: .init(
            appearance: .destructive,
            content: .attributedTitles(mainTitle: attributedTitle, subTitle: subtitle),
            button: .buttons(
                leftButtonTitle: "취소",
                leftButtonStyle: .init(textColor: .neutral600, font: .pretendardMedium, fontSize: 15, borderColor: .gray, borderWidth: 1, cornerRadius: 4),
                rightButtonTitle: "삭제하기",
                rightButtonAction: {},
                rightButtonStyle: .init(textColor: .neutral0, font: .pretendardMedium, fontSize: 15, backgroundColor: .danger700, cornerRadius: 4)
            )
        ))
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    override func rightButtonTapped() {
        let onDelete = onDeleteButtonTapped
        let lecture = lectureData
        dismiss(animated: true) {
            onDelete(lecture)
        }
    }
}
