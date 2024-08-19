//
//  NoticeListTableViewFooter.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/18/24.
//

import SnapKit
import Then
import UIKit

final class NoticeListTableViewFooter: UITableViewHeaderFooterView {
    // MARK: - UIComponents
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 4
    }
    
    private let nextBtn = UIButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    private let previousBtn = UIButton().then {
        $0.setTitle("이전", for: .normal)
    }
    
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
        let pageBtn =  [firstPageBtn, secondPageBtn, thirdPageBtn, fourthPageBtn, fifthPageBtn]
        for page in pageInfo.pages {
            pageBtn[page-1].isHidden = false
            pageBtn[page-1].setTitle("\(page)", for: .normal)
        }
        if let isNextPage = pageInfo.isNextPage {
            nextBtn.isHidden = false
        }
        if let isPreviousPage = pageInfo.isPreviousPage {
            previousBtn.isHidden = false
        }
    }
}

extension NoticeListTableViewFooter {
    private func setUpButtons() {
        [firstPageBtn, secondPageBtn, thirdPageBtn, fourthPageBtn, fifthPageBtn].forEach {
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 12)
            $0.setTitleColor(.appColor(.neutral600), for: .normal)
            $0.backgroundColor = .appColor(.neutral300)
            $0.layer.cornerRadius = 4
        }
        [previousBtn, nextBtn].forEach {
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 12)
            $0.setTitleColor(.appColor(.neutral600), for: .normal)
            $0.backgroundColor = .clear
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
