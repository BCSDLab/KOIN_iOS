//
//  SubstituteTimetableModalViewController.swift
//  koin
//
//  Created by 김나훈 on 12/4/24.
//

import Combine
import UIKit

final class SubstituteTimetableModalViewController: UIViewController {
    
    let substituteButtonPublisher = PassthroughSubject<Any, Never>()
    private var lectureData: LectureData?
    private var customLecture: (String, [Int])?
    
    private let messageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.text = "시간표가 중복돼요."
    }
    
    private let subMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral600)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let text = "추가하시려는 시간에 이미 다른 강의가\n있어요. 새로운 강의로 대체하시겠어요?"
        let attributedString = NSMutableAttributedString(string: text)
        let loginRange = (text as NSString).range(of: "새로운 강의로 대체")
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.warning500), range: loginRange)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.textAlignment = .center
        $0.numberOfLines = 2
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
    
    private let substituteButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("대체하기", for: .normal)
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
        configureView()
        substituteButton.addTarget(self, action: #selector(substituteButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func substituteButtonTapped() {
        dismiss(animated: true, completion: nil)
        if let lectureData = lectureData {
                substituteButtonPublisher.send(lectureData)
            } else if let customLecture = customLecture {
                substituteButtonPublisher.send(customLecture)
            } 
    }
    
    func configure(lectureData: LectureData) {
        self.lectureData = nil
        self.customLecture = nil
        
        self.lectureData = lectureData
    }
    func configure(customLecture: (String, [Int])) {
        self.lectureData = nil
        self.customLecture = nil
        
        self.customLecture = customLecture
    }
}

extension SubstituteTimetableModalViewController {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [messageLabel, subMessageLabel, closeButton, substituteButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(301)
            make.height.equalTo(198)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(24)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        subMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(16)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            make.trailing.equalTo(containerView.snp.centerX).offset(-2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
        substituteButton.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
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
