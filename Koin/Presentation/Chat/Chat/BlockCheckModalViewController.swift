//
//  BlockCheckModalViewController.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine
import UIKit

final class BlockCheckModalViewController: UIViewController {
    let buttonPublihser = PassthroughSubject<Void, Never>()
    
    private let blockButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .block)
        var text = AttributedString("차단하기")
        text.font = UIFont.appFont(.pretendardRegular, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 27
        configuration.baseForegroundColor = UIColor.appColor(.neutral600)
        $0.contentHorizontalAlignment = .center
        $0.configuration = configuration
        $0.backgroundColor = UIColor.appColor(.neutral50)
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOutsideOfContainerView))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func blockButtonTapped() {
        buttonPublihser.send()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tapOutsideOfContainerView(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !blockButton.frame.contains(location) {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension BlockCheckModalViewController {
    
    private func setUpLayOuts() {
        [blockButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        blockButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalTo(view.snp.trailing).offset(-21)
            $0.width.equalTo(128)
            $0.height.equalTo(46)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = .clear
    }
}
