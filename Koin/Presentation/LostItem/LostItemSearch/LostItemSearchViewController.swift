//
//  LostItemSearchViewController.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit
import Combine

final class LostItemSearchViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: LostItemSearchViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
    private let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 40))
    private lazy var searchTextField = UITextField().then {
        $0.leftView = leftView
        $0.rightView = rightView
        $0.leftViewMode = .always
        $0.rightViewMode = .always
        $0.attributedPlaceholder = NSAttributedString(string: "검색어를 입력해주세요.", attributes: [
            .font : UIFont.appFont(.pretendardRegular, size: 14),
            .foregroundColor : UIColor.appColor(.gray)
        ])
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.backgroundColor = .appColor(.neutral100)
    }
    private let searchButton = UIButton().then {
        $0.setImage(.appImage(asset: .search), for: .normal)
        $0.tintColor = .appColor(.neutral600)
    }
    
    private let recentSearchedTitleLabel = UILabel().then {
        $0.text = "최근 검색기록"
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.isHidden = true
    }
    private let resetRecentSearchedButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(string: "전체 삭제", attributes: [
            .font : UIFont.appFont(.pretendardMedium, size: 14),
            .foregroundColor : UIColor.appColor(.neutral500)
        ]), for: .normal)
        $0.isHidden = true
    }
    private let recentSearchedTableView = RecentSearchedLostItemTableView().then {
        $0.isScrollEnabled = false
        $0.separatorStyle = .none
        $0.backgroundColor = .white
    }
    private let searchedLostItemTableView = LostItemListTableView().then {
        $0.isHidden = true
        $0.backgroundColor = .white
    }
    private let emptyResultLabel = UILabel().then {
        $0.setLineHeight(lineHeight: 1.40, text: "일치하는 공지글이 없습니다.\n다른 키워드로 다시 시도해주세요.")
        $0.contentMode = .center
        $0.isHidden = true
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral500)
    }
    
    // MARK: - Initializer
    init(viewModel: LostItemSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setAddTarget()
        hideKeyboardWhenTappedAround()
        configureView()
        title = "분실물 검색"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    private func bind() {
        recentSearchedTableView.deleteRecentSearchedLostItemPublisher.sink { [weak self] keyword in
            // coreData에서 키워드 삭제
        }.store(in: &subscriptions)
        
        searchedLostItemTableView.cellTappedPublisher.sink { [weak self] id in
            let viewModel = LostItemDataViewModel()
            let viewController = LostItemDataViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension LostItemSearchViewController {
    
    func setAddTarget() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        resetRecentSearchedButton.addTarget(self, action: #selector(resetRecentSearchedButtonTapped), for: .touchUpInside)
    }
    @objc private func searchButtonTapped() {
        [recentSearchedTitleLabel, resetRecentSearchedButton, recentSearchedTableView].forEach {
            $0.isHidden = true
        }
        
        if searchedLostItemTableView.isHidden {
            searchedLostItemTableView.isHidden = false
            emptyResultLabel.isHidden = true
        } else {
            searchedLostItemTableView.isHidden = true
            emptyResultLabel.isHidden = false
        }
    }
    @objc private func resetRecentSearchedButtonTapped() {
        recentSearchedTableView.isHidden = true
        // coreData에서 키워드 전체 삭제
    }
    
}

extension LostItemSearchViewController {
    
    private func setUpLayouts() {
        [searchTextField, searchButton,
         recentSearchedTitleLabel, resetRecentSearchedButton, recentSearchedTableView,
         searchedLostItemTableView, emptyResultLabel].forEach {
            view.addSubview($0)
        }
    }
    private func setConstraints() {
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }
        searchButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalTo(searchTextField)
            $0.trailing.equalTo(searchTextField).offset(-16)
        }
        recentSearchedTitleLabel.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(22)
        }
        resetRecentSearchedButton.snp.makeConstraints {
            $0.centerY.equalTo(recentSearchedTitleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        recentSearchedTableView.snp.makeConstraints {
            $0.top.equalTo(recentSearchedTitleLabel.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        searchedLostItemTableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        emptyResultLabel.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setConstraints()
        view.backgroundColor = .white
    }
}
