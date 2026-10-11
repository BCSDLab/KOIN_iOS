//
//  RecruitDataPopUpViewController.swift
//  koin
//
//  Created by 홍기정 on 7/6/26.
//

import UIKit
import SnapKit
import Then

final class RecruitDataPopUpViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundView = UIView()
    private let editButton = UIButton()
    private let separatorView = UIView()
    private let deleteButton = UIButton()
    
    // MARK: - Properties
    private let onEditButtonTapped: ()->Void
    private let onDeleteButtonTapped: ()->Void
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
        onEditButtonTapped: @escaping () -> Void,
        onDeleteButtonTapped: @escaping () -> Void
    ) {
        self.onEditButtonTapped = onEditButtonTapped
        self.onDeleteButtonTapped = onDeleteButtonTapped
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

extension RecruitDataPopUpViewController {
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

extension RecruitDataPopUpViewController {
    private func setAddTargets() {
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapAround)
            ).then {
                $0.cancelsTouchesInView = false
            }
        )
    }
    
    @objc private func didTapEditButton() {
        dismiss(animated: false) { [weak self] in
            self?.onEditButtonTapped()
        }
    }
    
    @objc private func didTapDeleteButton() {
        dismiss(animated: false) { [weak self] in
            self?.onDeleteButtonTapped()
        }
    }
    
    @objc private func didTapAround() {
        dismiss()
    }
}

extension RecruitDataPopUpViewController {
    
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
        
        editButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "편집하기",
                attributes: AttributeContainer([
                    .foregroundColor : UIColor.appColor(.neutral800),
                    .font : UIFont.appFont(.pretendardRegular, size: 12),
                    .paragraphStyle : NSMutableParagraphStyle().then { $0.alignment = .left }
                ]
            ))
            configuration.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 40)
            $0.configuration = configuration
        }
        
        separatorView.do {
            $0.backgroundColor = .appColor(.neutral200)
        }
        
        deleteButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "삭제하기",
                attributes: AttributeContainer([
                    .font : UIFont.appFont(.pretendardRegular, size: 12),
                    .foregroundColor : UIColor.appColor(.danger700),
                    .paragraphStyle : NSMutableParagraphStyle().then { $0.alignment = .left }
                ])
            )
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 40)
            $0.configuration = configuration
        }
    }
    
    private func setUpLayouts() {
        [editButton, deleteButton, separatorView].forEach {
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
        
        editButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(35)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom)
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
