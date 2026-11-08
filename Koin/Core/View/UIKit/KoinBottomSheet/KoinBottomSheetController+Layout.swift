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
        dimView.receivesTouch = { [weak self] point in
            self?.dimReceivesTouch(at: point) ?? false
        }
        dimView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(dimTapped)
        ))
    }

    /// 하단은 host의 키보드 가이드를, 상단 한계는 owner 화면의 safe area를 쓴다.
    func installHostGuideConstraintsIfNeeded() {
        guard heightConstraint == nil, let host = view.superview, let topGuide = topLimitGuide else { return }
        keyboardState.keyboardBackdropView.snp.makeConstraints {
            $0.top.equalTo(host.keyboardLayoutGuide.snp.top)
        }
        sheetView.snp.makeConstraints {
            $0.bottom.equalTo(host.keyboardLayoutGuide.snp.top)
            $0.top.greaterThanOrEqualTo(topGuide.snp.top)
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
        // 그림자가 잘리지 않도록 콘텐츠 clip은 sheetView가, 둥근 배경은 containerView가 맡는다.
        [containerView, sheetView].forEach {
            $0.layer.cornerRadius = configuration.cornerRadius
            $0.layer.cornerCurve = .continuous
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        sheetView.clipsToBounds = true
        if configuration.showsShadow {
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.15
            containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
            containerView.layer.shadowRadius = 10
        }
    }

    private func setUpLayouts() {
        [dimView, keyboardState.keyboardBackdropView, containerView].forEach {
            view.addSubview($0)
        }
        containerView.addSubview(sheetView)
    }

    private func setUpConstraints() {
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }
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
            $0.leading.trailing.equalToSuperview()
            contentBottomConstraint = $0.bottom.equalToSuperview().constraint
            $0.top.equalToSuperview().priority(749)
        }
        contentViewController.didMove(toParent: self)
    }
}
