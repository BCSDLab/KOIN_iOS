//
//  SortOptionSheetViewController.swift
//  koin
//
//  Created by 이은지 on 6/21/25.
//

import UIKit
import SnapKit

enum SortType: CaseIterable {
    case rating
    case review
    case basic
    
    var title: String {
        switch self {
        case .rating: return "별점 높은 순"
        case .review: return "리뷰순"
        case .basic:  return "기본순"
        }
    }

    var fetchSortType: FetchOrderShopSortType {
        switch self {
        case .rating:
            return .ratingDesc
        case .review:
            return .countDesc
        case .basic:
            return .none
        }
    }
}

final class SortOptionSheetViewController: UIViewController {
    
    // MARK: - Properties
    var onOptionSelected: ((SortType) -> Void)?
    private var current: SortType
    
    // MARK: UI Component
    private let titleLabel = UILabel().then {
        $0.text = "가게 정렬"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = UIColor.appColor(.new500)
    }
    
    private let closeButton = UIButton(type: .system).then {
        let img = UIImage.appImage(asset: .cancel)?
            .withRenderingMode(.alwaysTemplate)
        $0.setImage(img, for: .normal)
        $0.tintColor = .black
    }
    
    private let seperateView1 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let seperateView2 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let optionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }
        
    // MARK: Lifecycle
    init(current: SortType) {
        self.current = current
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        makeOptionButtons()
    }
    
    private func makeOptionButtons() {
        SortType.allCases.forEach { sort in
            let button = UIButton(type: .system)
            button.tag = sort.hashValue
            button.contentHorizontalAlignment = .leading
            
            var config = UIButton.Configuration.plain()
            
            var attribute = AttributedString(sort.title)
            attribute.font = UIFont.appFont(.pretendardRegular, size: 16)
            attribute.foregroundColor = UIColor.appColor(.neutral800)
            config.attributedTitle = attribute
            
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 24)
            config.titleAlignment = .leading
            
            config.imagePlacement = .trailing
            config.imagePadding = 8
            
            button.configuration = config
            button.tintColor = .appColor(.new500)
            button.snp.makeConstraints { $0.height.equalTo(36) }
            
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionStackView.addArrangedSubview(button)
        }
        refreshButtons()
    }
    
    private func refreshButtons() {
        for case let button as UIButton in optionStackView.arrangedSubviews {
            guard let sort = SortType.allCases
                    .first(where: { $0.hashValue == button.tag }) else { continue }
            let isSelected = sort == current
            
            var attribute = AttributedString(sort.title)
            attribute.font = UIFont.appFont(.pretendardRegular, size: 16)
            attribute.foregroundColor = isSelected ? UIColor.appColor(.new500) : UIColor.appColor(.neutral800)
            
            var config = button.configuration ?? .plain()
            config.attributedTitle = attribute
            button.configuration = config
            button.tintColor = .appColor(.new500)
            
            button.subviews.filter { $0 is UIImageView }.forEach { $0.removeFromSuperview() }

            if isSelected {
                let checkImageView = UIImageView(image: UIImage.appImage(asset: .check)?.withRenderingMode(.alwaysTemplate))
                checkImageView.tintColor = .appColor(.new500)
                button.addSubview(checkImageView)
                checkImageView.snp.makeConstraints {
                    $0.trailing.equalToSuperview().offset(-32)
                    $0.centerY.equalToSuperview()
                    $0.width.height.equalTo(24)
                }
            }
        }
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        guard let sort = SortType.allCases.first(where: { $0.hashValue == sender.tag }) else { return }
        current = sort
        refreshButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.dismiss(animated: true) {
                self.onOptionSelected?(sort)
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

private extension SortOptionSheetViewController {
    private func setUpLayOuts() {
        [titleLabel, closeButton, seperateView1, seperateView2, optionStackView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(29)
        }
        
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.trailing.equalToSuperview().inset(14.5)
            $0.centerY.equalTo(titleLabel)
        }
        
        seperateView1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        seperateView2.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        optionStackView.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(seperateView2.snp.top).offset(-12)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = .white
    }
}
