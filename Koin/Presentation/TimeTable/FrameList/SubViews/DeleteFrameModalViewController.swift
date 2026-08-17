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
        onDeleteButtonTapped: @escaping (FrameDto) -> Void,
    ) {
        self.onDeleteButtonTapped = onDeleteButtonTapped
        self.frame = frame

        let attributedString = {
            let frameName = frame.timetableName
            let text = "\(frameName)\(frameName.hasFinalConsonant() ? "을":"를") 삭제하시겠어요?"
            let attributedString = NSMutableAttributedString(
                string: text,
                attributes: [
                    .font: UIFont.appFont(.pretendardMedium, size: 16),
                    .foregroundColor: UIColor.appColor(.neutral800)
                ]
            )
            let range = (text as NSString).range(of: "삭제")
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
            onDeleteButtonTapped(frame)
        }
    }
}
