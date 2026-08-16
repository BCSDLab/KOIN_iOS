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
        
        let attributedString = {
            let lectureName = lectureData.name
            let text = "\(lectureName)\(lectureName.hasFinalConsonant() ? "을":"를") 삭제하시겠어요?\n삭제한 강의는 수업추가에서\n다시 추가할 수 있어요."
            let attributedString = NSMutableAttributedString(string: text)
            let range1 = (text as NSString).range(of: "삭제")
            let range2 = (text as NSString).range(of: "수업추가")
            attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.danger700), range: range1)
            attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.primary500), range: range2)
            return attributedString
        }()
        super.init(configuration: .init(
            appearance: .destructive,
            content: .attributedSingleTitle(title: attributedString),
            button: .buttons(
                leftButtonTitle: "취소",
                rightButtonTitle: "삭제하기",
                rightButtonAction: {}
            )
        ))
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    override func rightButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            onDeleteButtonTapped(lectureData)
        }
    }
}
