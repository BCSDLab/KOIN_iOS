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
    private var dismissContentViewConstraint: Constraint?
    private var presentContentViewConstraint: Constraint?
    private let dimAlpha: CGFloat
    
    // MARK: - UI Components
    private let dimView = UIView().then { $0.alpha = 0 }
    private let contentView: UIView
    private let safeAreaView = UIView()
    
    // MARK: - LayoutGuide
    private let safeAreaLayoutGuide = UILayoutGuide()
    
    // MARK: - Initializer
    init(
        contentView: UIView,
        dimAlpha: CGFloat = 0.7
    ) {
        self.contentView = contentView
        self.dimAlpha = dimAlpha
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        
        dimView.do {
            $0.backgroundColor = .appColor(.neutral800)
        }
        safeAreaView.do {
            $0.backgroundColor = contentView.backgroundColor
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        present()
    }
}

extension BottomSheetViewControllerB: BottomSheetViewControllerBDelegate {
    
    func present() {
        view.layoutIfNeeded()
        
        dismissContentViewConstraint?.deactivate()
        presentContentViewConstraint?.activate()
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }
            dimView.alpha = dimAlpha
            view.layoutIfNeeded()
        }
    }
    
    func dismiss() {
        dismissContentViewConstraint?.activate()
        presentContentViewConstraint?.deactivate()
        
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
        [safeAreaLayoutGuide].forEach {
            view.addLayoutGuide($0)
        }
    }
    
    private func setUpConstraints() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.height)
            $0.leading.trailing.equalToSuperview()
            dismissContentViewConstraint = $0.top.equalTo(view.snp.bottom).constraint
            presentContentViewConstraint = $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).constraint
        }
        presentContentViewConstraint?.deactivate()
        
        safeAreaLayoutGuide.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.keyboardLayoutGuide.snp.top)
            $0.bottom.equalToSuperview()
        }
        safeAreaView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(contentView.snp.bottom)
            $0.height.equalTo(safeAreaLayoutGuide.snp.height)
        }
    }
}
