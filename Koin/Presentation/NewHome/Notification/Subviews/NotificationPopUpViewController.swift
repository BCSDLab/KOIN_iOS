//
//  NotificationPopUpViewController.swift
//  koin
//
//  Created by 홍기정 on 7/6/26.
//

import UIKit
import SnapKit
import Then

final class NotificationPopUpViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundView = UIView()
    private let markAllAsReadButton = UIButton()
    private let separatorView = UIView()
    private let deleteAllButton = UIButton()
    
    // MARK: - Properties
    @objc private let markAllAsRead: ()->Void
    @objc private let deleteAll: ()->Void
    
    // MARK: - Initializer
    init(
        markAllAsRead: @escaping () -> Void,
        deleteAll: @escaping () -> Void
    ) {
        self.markAllAsRead = markAllAsRead
        self.deleteAll = deleteAll
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTargets()
    }
}

extension NotificationPopUpViewController {
    private func setAddTargets() {
        markAllAsReadButton.addTarget(self, action: #selector(didTapMarkAllAsReadButton), for: .touchUpInside)
        deleteAllButton.addTarget(self, action: #selector(didTapDeleteAllButton), for: .touchUpInside)
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapAround)
            ).then {
                $0.cancelsTouchesInView = false
            }
        )
    }
    
    @objc private func didTapMarkAllAsReadButton() {
        dismissView()
        markAllAsRead()
    }
    
    @objc private func didTapDeleteAllButton() {
        dismissView()
        deleteAll()
    }
    
    @objc private func didTapAround() {
        dismissView()
    }
}

extension NotificationPopUpViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = .clear
        
        backgroundView.do {
            $0.backgroundColor = .appColor(.neutral50)
            $0.layer.applySketchShadow(
                color: .black,
                alpha: 0.4,
                x: 0,
                y: 2,
                blur: 4,
                spread: 0
            )
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
        
        markAllAsReadButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "모두 읽음으로 표시",
                attributes: AttributeContainer([
                    .foregroundColor : UIColor.appColor(.neutral800),
                    .font : UIFont.appFont(.pretendardRegular, size: 12),
                    .paragraphStyle : NSMutableParagraphStyle().then { $0.alignment = .left }
                ]
            ))
            configuration.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
        }
        
        separatorView.do {
            $0.backgroundColor = .appColor(.neutral200)
        }
        
        deleteAllButton.do {
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "알림 전체 삭제",
                    attributes: [
                        .foregroundColor : UIColor.appColor(.danger700),
                        .font : UIFont.appFont(.pretendardRegular, size: 12),
                        .paragraphStyle : NSMutableParagraphStyle().then { $0.alignment = .left }
                    ]),
                for: .normal)
            $0.backgroundColor = .clear
        }
    }
    
    private func setUpLayouts() {
        [markAllAsReadButton, deleteAllButton, separatorView].forEach {
            backgroundView.addSubview($0)
        }
        [backgroundView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(44)
            $0.trailing.equalToSuperview().offset(-40)
        }
        
        markAllAsReadButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(35)
        }
        
        deleteAllButton.snp.makeConstraints {
            $0.top.equalTo(markAllAsReadButton.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(35)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
    }
}
