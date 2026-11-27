//
//  LandMapZoomControlView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import Combine
import SnapKit

final class LandMapZoomControlView: UIView {

    // MARK: - Properties
    let zoomInTappedPublisher = PassthroughSubject<Void, Never>()
    let zoomOutTappedPublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components
    private let zoomInButton = UIButton()
    private let zoomOutButton = UIButton()
    private let stackView = UIStackView()

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        zoomInButton.addTarget(self, action: #selector(zoomInButtonTapped), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(zoomOutButtonTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandMapZoomControlView {
    @objc private func zoomInButtonTapped() {
        zoomInTappedPublisher.send()
    }

    @objc private func zoomOutButtonTapped() {
        zoomOutTappedPublisher.send()
    }
}

extension LandMapZoomControlView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.appColor(.neutral400).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5

        zoomInButton.setImage(UIImage.appImage(asset: .landZoomIn), for: .normal)
        zoomInButton.accessibilityLabel = "확대"
        zoomOutButton.setImage(UIImage.appImage(asset: .landZoomOut), for: .normal)
        zoomOutButton.accessibilityLabel = "축소"

        stackView.axis = .vertical
        stackView.spacing = 8
    }

    private func setUpLayouts() {
        addSubview(stackView)
        [zoomInButton, zoomOutButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
        [zoomInButton, zoomOutButton].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(24)
            }
        }
    }
}
