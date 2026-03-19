//
//  BottomSheetViewControllerB.swift
//  koin
//
//  Created by 홍기정 on 3/8/26.
//

import UIKit
import SnapKit
import Then

protocol BottomSheetViewControllerBDelegate: AnyObject {
    func present()
    func dismiss()
}

final class BottomSheetViewControllerB: UIViewController {
    
    // MARK: - Properties
    private var contentViewBottomConstraint: Constraint?
    private var safeAreaHeightConstraint: Constraint?
    private var alpha: CGFloat
    
    // MARK: - UI Components
    private let dimView = UIView().then { $0.alpha = 0 }
    private let contentView: UIView
    private let safeAreaView = UIView()
    
    // MARK: - Initializer
    init(contentView: UIView, dimColor: UIColor, dimAlpha: CGFloat, backgroundColor: UIColor) {
        self.contentView = contentView
        self.alpha = dimAlpha
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        
        dimView.do {
            $0.backgroundColor = dimColor
        }
        safeAreaView.do {
            $0.backgroundColor = backgroundColor
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setGesture()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        safeAreaHeightConstraint?.update(offset: view.safeAreaInsets.bottom)
        present()
    }
}

extension BottomSheetViewControllerB: BottomSheetViewControllerBDelegate {
    
    func present() {
//        view.layoutIfNeeded()
        contentViewBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }
            dimView.alpha = alpha
            view.layoutIfNeeded()
        }
    }
    
    func dismiss() {
        contentViewBottomConstraint?.update(offset: contentView.bounds.height)
        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                guard let self else { return }
                dimView.alpha = 0
                view.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                self?.dismiss(animated: false)
            })
    }
}

extension BottomSheetViewControllerB {
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped))
        dimView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dimViewTapped() {
        dismissKeyboard()
        dismiss()
    }
}

extension BottomSheetViewControllerB {
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        [dimView, contentView, safeAreaView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            contentView.layoutIfNeeded()
            contentViewBottomConstraint = $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(contentView.bounds.height).constraint
            $0.leading.trailing.equalToSuperview()
        }
        safeAreaView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(contentView.snp.bottom)
            safeAreaHeightConstraint = $0.height.equalTo(0).constraint
        }
    }
}
