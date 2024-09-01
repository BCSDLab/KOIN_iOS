//
//  NoticeSearchViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class NoticeSearchViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: NoticeSearchViewModel
    private let inputSubject: PassthroughSubject<NoticeSearchViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    private let navigationTitle = UILabel().then {
        $0.text = "공지글 검색"
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .arrowBack), for: .normal)
        $0.tintColor = .appColor(.neutral800)
    }
    
    private let textField = UITextField().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.placeholder = "검색어를 입력해주세요."
        $0.backgroundColor = .appColor(.neutral100)
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: $0.frame.height))
        $0.rightView = rightPaddingView
        $0.rightViewMode = .always
        $0.layer.cornerRadius = 4
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftView = leftPaddingView
        $0.leftViewMode = .always
    }
    
    private let textFieldButton = UIButton().then {
        $0.setImage(UIImage.appImage(symbol: .magnifyingGlass), for: .normal)
        $0.tintColor = .appColor(.neutral600)
    }
    
    private let popularKeyWordGuideLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = "많이 검색되는 키워드"
    }
    
    private let recentSearchDataGuideLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = "최근 검색기록"
    }
    
    private let deleteRecentSearchDataButton = UIButton().then {
        $0.setTitle("전체 삭제", for: .normal)
        $0.setTitleColor(.appColor(.neutral500), for: .normal)
        $0.titleLabel?.font = .appFont(.pretendardMedium, size: 14)
    }
    
    private let recommendedSearchCollectionView = RecommendedSearchCollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout()).then {
        $0.isScrollEnabled = false
    }
    
    private let recentSearchTableView = RecentSearchTableView(frame: .zero, style: .plain).then {
        $0.isScrollEnabled = false
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        inputSubject.send(.getHotKeyWord(5))
    }
    
    // MARK: - Initialization
    
    init(viewModel: NoticeSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateHotKeyWord(keyWords):
                self?.updateRecommendedHotWord(keyWords: keyWords)
            }
        }.store(in: &subscriptions)
    }
}

extension NoticeSearchViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func updateRecommendedHotWord(keyWords: [String]) {
        recommendedSearchCollectionView.updateRecommendedKeyWords(keyWords: keyWords)
    }
}

extension NoticeSearchViewController {
    private func setUpLayouts() {
        [backButton, navigationTitle, textField, textFieldButton, popularKeyWordGuideLabel, recommendedSearchCollectionView, recentSearchDataGuideLabel, deleteRecentSearchDataButton, recentSearchTableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationTitle.snp.makeConstraints {
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(navigationTitle.snp.bottom).offset(16)
            $0.height.equalTo(40)
        }
        
        textFieldButton.snp.makeConstraints {
            $0.trailing.equalTo(textField.snp.trailing).inset(16)
            $0.centerY.equalTo(textField)
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }
        
        popularKeyWordGuideLabel.snp.makeConstraints {
            $0.leading.equalTo(textField)
            $0.top.equalTo(textField.snp.bottom).offset(20)
        }
        
        recommendedSearchCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(popularKeyWordGuideLabel.snp.bottom).offset(8)
            $0.height.equalTo(76)
        }
        
        recentSearchDataGuideLabel.snp.makeConstraints {
            $0.leading.equalTo(popularKeyWordGuideLabel)
            $0.top.equalTo(recommendedSearchCollectionView.snp.bottom).offset(16)
        }
        
        deleteRecentSearchDataButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(52)
            $0.height.equalTo(22)
            $0.top.equalTo(recentSearchDataGuideLabel)
        }
        
        recentSearchTableView.snp.makeConstraints {
            $0.top.equalTo(recentSearchDataGuideLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(126)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .white
    }
}
