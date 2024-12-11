//
//  DeleteFrameModalViewController.swift
//  koin
//
//  Created by 김나훈 on 12/10/24.
//

import Combine
import UIKit

final class DeleteFrameModalViewController: UIViewController {
    
    let deleteButtonPublisher = PassthroughSubject<FrameDTO, Never>()
    private var frame: FrameDTO? = nil
    
    private let messageLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let deleteButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.danger700)
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }

    private let cancelButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let containerView = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
  
    @objc private func deleteButtonTapped() {
        if let frame = frame {
            deleteButtonPublisher.send(frame)
        }
        dismiss(animated: true, completion: nil)
    }
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func configure(frame: FrameDTO) {
        self.frame = frame
        
        let frameName = frame.timetableName
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center
        let text = "\(frameName)\(frameName.hasFinalConsonant() ? "을":"를") 삭제하시겠어요?"
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "삭제")
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.danger700), range: range)
           attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        messageLabel.attributedText = attributedString
    }
   
}

extension DeleteFrameModalViewController {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [deleteButton, messageLabel, cancelButton, deleteButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(327)
            make.height.equalTo(216)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(47)
            make.centerX.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom).offset(-47)
            make.trailing.equalTo(containerView.snp.centerX).offset(-2)
            make.width.equalTo(127.5)
            make.height.equalTo(48)
        }
        deleteButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom).offset(-47)
            make.leading.equalTo(containerView.snp.centerX).offset(2)
            make.width.equalTo(127.5)
            make.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
