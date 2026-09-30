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
    private let markAllAsRead: ()->Void
    private let deleteAll: ()->Void
    private var minimizedTransform: CGAffineTransform {
        let scale = 0.4
        
        return CGAffineTransform(
            a: scale,
            b: 0,
            c: 0,
            d: scale,
            tx: backgroundView.bounds.width * (1 - scale) / 2,
            ty: -backgroundView.bounds.height * (1 - scale) / 2
        )
    }
    
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        backgroundView.transform = minimizedTransform
        backgroundView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(
            springDuration: 0.2,
            bounce: 0.2,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) { [weak self] in
            self?.backgroundView.transform = .identity
            self?.backgroundView.alpha = 1
        }
    }
}

extension NotificationPopUpViewController {
    private func dismiss() {
        UIView.animate(
            springDuration: 0.2,
            bounce: 0.2,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) { [weak self] in
            guard let self else { return }
            backgroundView.transform = minimizedTransform
            backgroundView.alpha = 0
        } completion: { [weak self] _ in
            self?.dismiss(animated: false)
        }
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
        dismiss()
        markAllAsRead()
    }
    
    @objc private func didTapDeleteAllButton() {
        dismiss()
        deleteAll()
    }
    
    @objc private func didTapAround() {
        dismiss()
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
                alpha: 0.04,
                x: 0,
                y: 2,
                blur: 4,
                spread: 0
            )
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.layer.masksToBounds = false
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
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString("알림 전체 삭제", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor : UIColor.appColor(.danger700),
                .paragraphStyle : paragraphStyle
            ]))
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
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
            $0.leading.equalToSuperview().inset(4)
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
