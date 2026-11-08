//
//  DeleteFrameModalViewController.swift
//  koin
//
//  Created by 김나훈 on 12/10/24.
//

import UIKit

final class DeleteFrameModalViewController: KoinModalViewController {

    // MARK: - Properties
    private let onDeleteButtonTapped: (FrameDto) -> Void
    private let frame: FrameDto

    // MARK: - Initializer
    init(
        frame: FrameDto,
        onDeleteButtonTapped: @escaping (FrameDto) -> Void
    ) {
        self.onDeleteButtonTapped = onDeleteButtonTapped
        self.frame = frame

        let frameName = frame.timetableName
        let title = "\(frameName)\(frameName.hasFinalConsonant() ? "을" : "를") 삭제하시겠어요?"
        let attributedTitle = NSMutableAttributedString(string: title, attributes: [
            .font: UIFont.appFont(.pretendardMedium, size: 16),
            .foregroundColor: UIColor.appColor(.neutral800)
        ])
        attributedTitle.addAttribute(.font, value: UIFont.appFont(.pretendardSemiBold, size: 16), range: (title as NSString).range(of: "삭제", options: .backwards))
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
        let frame = frame
        dismiss(animated: true) {
            onDelete(frame)
        }
    }
}
