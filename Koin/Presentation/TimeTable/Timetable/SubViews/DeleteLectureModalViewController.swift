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
        
        let attributedString = Self.makeAttributedString(lectureName: lectureData.name)
        
        super.init(configuration: .init(
            appearance: .destructive,
            content: .attributedSingleTitle(title: attributedString),
            button: .buttons(
                leftButtonTitle: "취소",
                rightButtonTitle: "삭제하기",
                rightButtonAction: {}
            ),
            layout: .init(
                paddingBetweenContentAndButton: 24 - 9.6
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

extension DeleteLectureModalViewController {
    private static func makeAttributedString(lectureName: String) -> NSAttributedString {
        let textMedium16 = "\(lectureName)\(lectureName.hasFinalConsonant() ? "을":"를") 삭제하시겠어요?"
        let textMedium15 = "삭제한 강의는 수업추가에서\n다시 추가할 수 있어요."
        let text = textMedium16 + "\n" + textMedium15
        
        let rangeMedium16 = (text as NSString).range(of: textMedium16)
        let rangeMedium15 = (text as NSString).range(of: textMedium15)
        let range1 = (text as NSString).range(of: "삭제")
        let range2 = (text as NSString).range(of: "수업추가")
        
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttributes([
            .font: UIFont.appFont(.pretendardMedium, size: 16),
            .foregroundColor: UIColor.appColor(.neutral800)
        ], range: rangeMedium16)
        
        attributedString.addAttributes([
            .font: UIFont.appFont(.pretendardMedium, size: 15),
            .foregroundColor: UIColor.appColor(.neutral800)
        ], range: rangeMedium15)
        
        attributedString.addAttributes([
            .font: UIFont.appFont(.pretendardBold, size: 16),
            .foregroundColor: UIColor.appColor(.danger700)
        ], range: range1)
        
        attributedString.addAttributes([
            .foregroundColor: UIColor.appColor(.primary500)
        ], range: range2)
        
        return attributedString
    }
}
