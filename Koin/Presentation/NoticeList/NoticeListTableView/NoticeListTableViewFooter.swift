//
//  NoticeListTableViewFooter.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/18/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class NoticeListTableViewFooter: UITableViewHeaderFooterView {
    // MARK: - Properties
    let tapBtnPublisher = PassthroughSubject<Int, Never>()
    var subscriptions = Set<AnyCancellable>()
    private var row = 0
    // MARK: - UIComponents
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 4
    }
    
    private let nextBtn = UIButton()
    
    private let previousBtn = UIButton()
    
    private let firstPageBtn = UIButton()
    
    private let secondPageBtn = UIButton()
    
    private let thirdPageBtn = UIButton()
    
    private let fourthPageBtn = UIButton()
    
    private let fifthPageBtn = UIButton()
    
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    override func prepareForReuse() {
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
}

extension NoticeListTableViewFooter {
    func configure(pageInfo: NoticeListPages) {
        [previousBtn, firstPageBtn, secondPageBtn, thirdPageBtn, fourthPageBtn, fifthPageBtn, nextBtn].forEach {
            $0.isHidden = true
        }
        
        let buttons = [firstPageBtn, secondPageBtn, thirdPageBtn, fourthPageBtn, fifthPageBtn]
        
        for (index, page) in pageInfo.pages.enumerated() {
            if index < buttons.count {
                buttons[index].isHidden = false
                buttons[index].setTitle("\(page)", for: .normal)
                buttons[index].setTitleColor(.appColor(.neutral600), for: .normal)
                buttons[index].backgroundColor = .appColor(.neutral300)
            }
        }
        if pageInfo.pages.count > 0 {
            row = (pageInfo.pages[0] - 1) / 5
        }
        if let selectedIndex = pageInfo.selectedIndex as Int?, selectedIndex > 0 {
            let selectedButton = buttons[(selectedIndex-1) % 5]
            selectedButton.setTitleColor(.appColor(.neutral0), for: .normal)
            selectedButton.backgroundColor = .appColor(.primary500)
        }
        if let isNextPage = pageInfo.isNextPage {
            nextBtn.isHidden = false
            nextBtn.setTitle(isNextPage.rawValue, for: .normal)
        }
        if let isPreviousPage = pageInfo.isPreviousPage {
            previousBtn.isHidden = false
            previousBtn.setTitle(isPreviousPage.rawValue, for: .normal)
        }
    }

    
    @objc private func tapPageBtn(sender: UIButton) {
        switch sender {
        case previousBtn:
            tapBtnPublisher.send(row * 5)
        case firstPageBtn:
            tapBtnPublisher.send(row * 5 + 1)
        case secondPageBtn:
            tapBtnPublisher.send(row * 5 + 2)
        case thirdPageBtn:
            tapBtnPublisher.send(row * 5 + 3)
        case fourthPageBtn:
            tapBtnPublisher.send(row * 5 + 4)
        case fifthPageBtn:
            tapBtnPublisher.send(row * 5 + 5)
        default:
            tapBtnPublisher.send(row * 5 + 6)
        }
    }
}

extension NoticeListTableViewFooter {
    private func setUpButtons() {
        [firstPageBtn, secondPageBtn, thirdPageBtn, fourthPageBtn, fifthPageBtn].forEach {
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 12)
            $0.layer.cornerRadius = 4
        }
        [previousBtn, nextBtn].forEach {
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 12)
            $0.setTitleColor(.appColor(.neutral600), for: .normal)
            $0.backgroundColor = .clear
        }
        [previousBtn, firstPageBtn, secondPageBtn, thirdPageBtn, fourthPageBtn, fifthPageBtn, nextBtn].forEach {
            $0.addTarget(self, action: #selector(tapPageBtn), for: .touchUpInside)
        }
    }
    
    private func setUpLayouts() {
        contentView.addSubview(stackView)
        [previousBtn, firstPageBtn, secondPageBtn, thirdPageBtn, fourthPageBtn, fifthPageBtn, nextBtn].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        [previousBtn, firstPageBtn, secondPageBtn, thirdPageBtn, fourthPageBtn, fifthPageBtn, nextBtn].forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(32)
                $0.height.equalTo(31)
            }
        }
    }
    
    private func configureView() {
        setUpButtons()
        setUpLayouts()
        setUpConstraints()
    }
}
