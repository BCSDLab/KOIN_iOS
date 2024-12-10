//
//  DeleteLectureModelViewController.swift
//  koin
//
//  Created by 김나훈 on 12/10/24.
//

import Combine
import UIKit

final class DeleteLectureModelViewController: UIViewController {
    
    let deleteButtonPublisher = PassthroughSubject<LectureData, Never>()
    private var lectureData: LectureData? = nil
    
    private let messageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 17)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.numberOfLines = 0
    }
    
    private let closeButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let deleteButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.danger700)
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        configureView()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true, completion: nil)
        if let lectureData = lectureData {
            deleteButtonPublisher.send(lectureData)
        }
        
    }
}

extension DeleteLectureModelViewController {

    func setMessageLabelText(lectureData: LectureData) {
        self.lectureData = lectureData
        let lectureName = lectureData.name
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center
        let text = "\(lectureName)\(lectureName.hasFinalConsonant() ? "을":"를") 삭제하시겠어요?\n삭제한 강의는 수업추가에서\n다시 추가할 수 있어요."
        let attributedString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "삭제")
        let range2 = (text as NSString).range(of: "수업추가")
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.danger700), range: range1)
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.primary500), range: range2)
           attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        messageLabel.attributedText = attributedString
    }
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [messageLabel, closeButton, deleteButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(301)
            make.height.equalTo(194)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(24)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        closeButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom).offset(-24)
            make.trailing.equalTo(containerView.snp.centerX).offset(-2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
        deleteButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom).offset(-24)
            make.leading.equalTo(containerView.snp.centerX).offset(2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
