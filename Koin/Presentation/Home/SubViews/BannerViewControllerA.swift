//
//  BannerViewControllerA.swift
//  koin
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class BannerViewControllerA: UIViewController {
    
    // MARK: - properties
    
    private let whiteView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let noShowButton = UIButton().then {
        $0.setTitle("일주일 동안 그만 보기", for: .normal)
    }
    
    private let closeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
    }
    
    private let collectionView = UIView()
    
    private let countLabel = UILabel()
    
    
    // MARK: - UI Components
   

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        noShowButton.addTarget(self, action: #selector(noShowButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

}

extension BannerViewControllerA {
    @objc private func noShowButtonTapped() {
        dismiss(animated: true)
    }
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension BannerViewControllerA {
    
    private func setUpLayOuts() {
       
        [whiteView].forEach {
            view.addSubview($0)
        }
        [noShowButton, closeButton, collectionView, countLabel].forEach {
            whiteView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        whiteView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        noShowButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalToSuperview().offset(22.5)
            $0.width.equalTo(120)
            $0.height.equalTo(22)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.trailing.equalToSuperview().offset(-22.5)
            $0.width.equalTo(25)
            $0.height.equalTo(22)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(13)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(293)
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.top).offset(8)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.equalTo(50)
            $0.height.equalTo(20)
        }
    }
    
    private func setUpComponents() {
        noShowButton.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        noShowButton.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        closeButton.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        closeButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        whiteView.layer.masksToBounds = true
        whiteView.layer.cornerRadius = 8
    }

    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpComponents()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
