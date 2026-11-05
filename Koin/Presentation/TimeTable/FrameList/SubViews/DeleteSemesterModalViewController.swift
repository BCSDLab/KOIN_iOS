//
//  DeleteSemesterModalViewController.swift
//  koin
//
//  Created by 김나훈 on 12/10/24.
//

import UIKit

final class DeleteSemesterModalViewController: KoinModalViewController {

    // MARK: - Properties
    private let onDeleteButtonTapped: ([String]) -> Void
    private let semesters: [String]

    // MARK: - Initializer
    init(
        semesters: [String],
        onDeleteButtonTapped: @escaping ([String]) -> Void
    ) {
        self.semesters = semesters
        self.onDeleteButtonTapped = onDeleteButtonTapped

        let message = "시간표가 작성되어 있는 학기가\n있어요. 해당 학기를 제외할 경우\n학기 내 시간표도 함께 삭제돼요."
        let attributedTitle = NSMutableAttributedString(string: message, attributes: [
            .font: UIFont.appFont(.pretendardMedium, size: 16),
            .foregroundColor: UIColor.appColor(.neutral800)
        ])
        attributedTitle.addAttribute(.font, value: UIFont.appFont(.pretendardSemiBold, size: 16), range: (message as NSString).range(of: "학기 내 시간표도 함께 삭제"))
        super.init(configuration: .init(
            appearance: .destructive,
            content: .attributedSingleTitle(title: attributedTitle),
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
        let semesters = semesters
        dismiss(animated: true) {
            onDelete(semesters)
        }
    }
}
