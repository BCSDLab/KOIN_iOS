//
//  KoinBottomSheetController+Layout.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit
import SnapKit
import Then

extension KoinBottomSheetController {
    func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
        attachContentViewController()
        if isModal {
            dimView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(dimTapped)
            ))
        }
    }

    /// nav·tab host는 child view에 safe area를 넘기지 않으므로 host 뷰의 가이드를 쓴다.
    func installHostGuideConstraintsIfNeeded() {
        guard heightConstraint == nil, let host = view.superview else { return }
        keyboardState.keyboardBackdropView.snp.makeConstraints {
            $0.top.equalTo(host.keyboardLayoutGuide.snp.top)
        }
        sheetView.snp.makeConstraints {
            $0.bottom.equalTo(host.keyboardLayoutGuide.snp.top)
            $0.top.greaterThanOrEqualTo(host.safeAreaLayoutGuide.snp.top)
        }
        heightConstraint = sheetView.heightAnchor.constraint(equalToConstant: 0)
        applyTargetHeight()
    }

    private func setUpStyles() {
        view.backgroundColor = .clear
        contentViewController.loadViewIfNeeded()
        let background = contentViewController.view.backgroundColor ?? .white
        [containerView, keyboardState.keyboardBackdropView].forEach {
            $0.backgroundColor = background
        }
        containerView.do {
            $0.layer.cornerRadius = configuration.cornerRadius
            $0.layer.cornerCurve = .continuous
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.clipsToBounds = true
        }
    }

    private func setUpLayouts() {
        if isModal {
            view.addSubview(dimView)
        }
        [keyboardState.keyboardBackdropView, containerView].forEach {
            view.addSubview($0)
        }
        containerView.addSubview(sheetView)
    }

    private func setUpConstraints() {
        if isModal {
            dimView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
        keyboardState.keyboardBackdropView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(sheetView.snp.top)
            // 콘텐츠 아래로 화면 끝과 시트 높이 이상의 여유를 같은 배경으로 채운다.
            $0.height.equalTo(view.snp.height).multipliedBy(3)
        }
        sheetView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(0)
        }
    }

    private func attachContentViewController() {
        addChild(contentViewController)
        sheetView.addSubview(contentViewController.view)
        contentViewController.view.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().priority(749)
        }
        contentViewController.didMove(toParent: self)
    }
}
