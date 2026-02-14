//
//  ErrorViewController.swift
//  koin
//
//  Created by 홍기정 on 2/13/26.
//

import UIKit

final class ErrorViewController: UIViewController {
    
    // MARK: - Properties
    private let completion: ()->Void
    
    // MARK: - UI Components
    private let wrapperViewLayoutGuide = UILayoutGuide()
    
    private let wrapperView = UIView()
    
    private let warningImageView = UIImageView().then {
        let configuration = UIImage.SymbolConfiguration.init(pointSize: 60, weight: .light)
        $0.image = UIImage(systemName: "exclamationmark.triangle", withConfiguration: configuration)
        $0.tintColor = .appColor(.neutral500)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "개발 중인 페이지입니다"
        $0.font = .appFont(.pretendardSemiBold, size: 20)
        $0.textColor = .appColor(.primary500)
    }
    
    private let subTitleLabel = UILabel().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.40
        paragraphStyle.alignment = .center
        
        $0.attributedText = NSAttributedString(
            string: "죄송합니다. 현재 개발 중인 페이지입니다.\n최대한 빠르게 오픈하도록 하겠습니다.",
            attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor : UIColor.appColor(.neutral500),
                .paragraphStyle : paragraphStyle
            ])
        $0.numberOfLines = 2
    }
    
    private let navigateButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(
            string: "메인 화면 바로가기", attributes: [
                .foregroundColor : UIColor.white,
                .font : UIFont.appFont(.pretendardSemiBold, size: 15)
            ]), for: .normal)
        $0.backgroundColor = .appColor(.primary500)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Initializer
    init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        navigateButton.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
    }
}

extension ErrorViewController {
    
    @objc private func navigateButtonTapped() {
        completion()
        dismissView()
    }
}

extension ErrorViewController {
    
    private func setUpLayouts() {
        [warningImageView, titleLabel, subTitleLabel].forEach {
            wrapperView.addSubview($0)
        }
        
        [wrapperView, navigateButton].forEach {
            view.addSubview($0)
        }
        
        [wrapperViewLayoutGuide].forEach {
            view.addLayoutGuide($0)
        }
    }
    private func setUpConstraints() {
        wrapperViewLayoutGuide.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(navigateButton.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        wrapperView.snp.makeConstraints {
            $0.center.equalTo(wrapperViewLayoutGuide)
        }
        
        warningImageView.snp.makeConstraints {
            $0.top.equalTo(wrapperView)
            $0.centerX.equalTo(wrapperView)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(warningImageView.snp.bottom).offset(20)
            $0.centerX.equalTo(wrapperView)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.bottom.equalTo(wrapperView)
            $0.centerX.equalTo(wrapperView)
        }
        
        navigateButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(46)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .white
    }
}


