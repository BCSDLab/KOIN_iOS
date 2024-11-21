//
//  ModifySemesterModalViewController.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import Combine
import UIKit

final class ModifySemesterModalViewController: UIViewController {
    
    let applyButtonPublisher = PassthroughSubject<Void, Never>()
    
    var containerWidth: CGFloat
    var containerHeight: CGFloat
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    // FIXME: 이거 고정값 변경
    private let selectYearButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.setTitle("2024", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
    }
    private let messageLabel = UILabel().then {
        $0.text = "학기 편집"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
    }
    private let firstSemesterButton = UIButton().then {
        $0.setTitle("1학기", for: .normal)
    }
    private let summerSelectButton = UIButton().then {
        $0.setTitle("여름학기", for: .normal)
    }
    private let secondSemesterButton = UIButton().then {
        $0.setTitle("2학기", for: .normal)
    }
    private let winterSemesterButton = UIButton().then {
        $0.setTitle("겨울학기", for: .normal)
    }
    private let cancelButton = UIButton().then {
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.setTitle("취소", for: .normal)
    }
    private let applyButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("적용하기", for: .normal)
    }
    
    init(width: CGFloat, height: CGFloat) {
        self.containerWidth = width
        self.containerHeight = height
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        selectYearButton.addTarget(self, action: #selector(selectYearButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
}
extension ModifySemesterModalViewController {
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func applyButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func selectYearButtonTapped() {
        let years = ["2024", "2023", "2022", "2021", "2020", "2019"]
        let alert = UIAlertController(title: "연도 선택", message: nil, preferredStyle: .actionSheet)
        
        for year in years {
            let action = UIAlertAction(title: year, style: .default) { [weak self] _ in
                guard let self = self else { return }
           //     self.selectedYear = year
                self.selectYearButton.setTitle(year, for: .normal)
    //            self.updateSemesterButtons()
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [selectYearButton, messageLabel, firstSemesterButton, summerSelectButton, secondSemesterButton, winterSemesterButton, cancelButton, applyButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(containerWidth)
            make.height.equalTo(containerHeight)
        }
        selectYearButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(12)
            make.leading.equalTo(containerView.snp.leading).offset(24)
            make.width.equalTo(90)
            make.height.equalTo(24)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(selectYearButton.snp.bottom)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        firstSemesterButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(14)
            make.leading.equalTo(containerView.snp.leading).offset(24)
            make.width.equalTo(125)
            make.height.equalTo(40)
        }
        summerSelectButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(14)
            make.trailing.equalTo(containerView.snp.trailing).offset(-24)
            make.width.height.equalTo(firstSemesterButton)
        }
        secondSemesterButton.snp.makeConstraints { make in
            make.top.equalTo(firstSemesterButton.snp.bottom).offset(10)
            make.width.height.leading.equalTo(firstSemesterButton)
        }
        winterSemesterButton.snp.makeConstraints { make in
            make.top.equalTo(secondSemesterButton)
            make.width.height.trailing.equalTo(summerSelectButton)
        }
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(135.5)
            make.height.equalTo(48)
            make.trailing.equalTo(containerView.snp.centerX).offset(-4)
            make.top.equalTo(winterSemesterButton.snp.bottom).offset(10)
        }
        applyButton.snp.makeConstraints { make in
            make.width.height.bottom.equalTo(cancelButton)
            make.leading.equalTo(containerView.snp.centerX).offset(4)
        }
    }
    
    private func setUpComponents() {
        [firstSemesterButton, secondSemesterButton, summerSelectButton, winterSemesterButton, cancelButton, applyButton].forEach {
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = true
        }
        [firstSemesterButton, secondSemesterButton, summerSelectButton, winterSemesterButton].forEach {
            $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
            $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        }
        [cancelButton, applyButton].forEach {
            $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpComponents()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
