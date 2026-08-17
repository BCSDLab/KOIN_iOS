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

        let attributedString = {
            let text = "시간표가 작성되어 있는 학기가\n있어요. 해당 학기를 제외할 경우\n학기 내 시간표도 함께 삭제돼요."
            let attributedString = NSMutableAttributedString(
                string: text,
                attributes: [
                    .font: UIFont.appFont(.pretendardMedium, size: 16),
                    .foregroundColor: UIColor.appColor(.neutral800)
                ]
            )
            let range = (text as NSString).range(of: "학기 내 시간표도 함께 삭제")
            attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.danger700), range: range)
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
            onDeleteButtonTapped(semesters)
        }
    }
}
