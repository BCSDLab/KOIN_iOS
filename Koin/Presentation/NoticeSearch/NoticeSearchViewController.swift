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

final class NoticeSearchViewController: CustomViewController, UIGestureRecognizerDelegate {
    // MARK: - Properties
    
    private let viewModel: NoticeSearchViewModel
    private let inputSubject: PassthroughSubject<NoticeSearchViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components

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
    
    private let noticeListTableView = NoticeListTableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .white
        $0.separatorStyle = .singleLine
    }
    
    private let emptyNoticeGuideLabel = UILabel().then {
        $0.text = "일치하는 공지글이 없습니다.\n다른 키워드로 다시 시도해주세요"
        $0.textAlignment = .center
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral500)
        $0.numberOfLines = 2
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        deleteRecentSearchDataButton.addTarget(self, action: #selector(deleteAllButtonTapped), for: .touchUpInside)
        configureView()
        bind()
        hideKeyboardWhenTappedAround()
        inputSubject.send(.getHotKeyWord(5))
        inputSubject.send(.fetchRecentSearchedWord)
        textField.delegate = self
        noticeListTableView.isHidden = true
        emptyNoticeGuideLabel.isHidden = true
        setUpNavigationBar()
        setNavigationTitle(title: "공지글 검색")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
   
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
            case .updateRecentSearchedWord(words: let words):
                self?.updateRecentSearchedWord(words: words)
            case let .updateSearchedrsult(searchedResult, isLastPage):
                self?.updateSearchedResult(searchedResult: searchedResult, isLastPage: isLastPage)
            }
        }.store(in: &subscriptions)
        
        recentSearchTableView.tapDeleteButtonPublisher
            .sink { [weak self] name, date in
            print(name)
            self?.inputSubject.send(.searchWord(name, date, 1))
        }.store(in: &subscriptions)
        
        recommendedSearchCollectionView.tapRecommendedWord.sink { [weak self] word in
            self?.textField.text = word
        }.store(in: &subscriptions)
        
        noticeListTableView.tapListLoadButtnPublisher.sink { [weak self] page in
            self?.inputSubject.send(.fetchSearchedResult(page, nil))
        }.store(in: &subscriptions)
       
        noticeListTableView.tapNoticePublisher.sink { [weak self] noticeId in
            let noticeListService = DefaultNoticeService()
            let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
            let fetchNoticeDataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: noticeListRepository)
            let downloadNoticeAttachmentUseCase = DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: noticeListRepository)
            let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: noticeListRepository)
            let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: downloadNoticeAttachmentUseCase, noticeId: noticeId)
            let noticeDataVc = NoticeDataViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(noticeDataVc, animated: true)
        }.store(in: &subscriptions)
    }
}

extension NoticeSearchViewController {
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo, let _ = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            emptyNoticeGuideLabel.snp.remakeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(249)
                make.centerX.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        emptyNoticeGuideLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
   
    
    @objc private func searchButtonTapped() {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            IndicatorView.show()
            inputSubject.send(.searchWord(text, Date(), 0))
            inputSubject.send(.fetchSearchedResult(1, text))
            IndicatorView.dismiss()
        }
        textField.text = ""
    }
    
    @objc private func deleteAllButtonTapped() {
        inputSubject.send(.deleteAllSearchedWords)
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            IndicatorView.show()
            inputSubject.send(.searchWord(text, Date(), 0))
            inputSubject.send(.fetchSearchedResult(1, text))
            IndicatorView.dismiss()
        }
        textField.text = ""
        return true
    }
    
    private func updateRecommendedHotWord(keyWords: [String]) {
        recommendedSearchCollectionView.updateRecommendedKeyWords(keyWords: keyWords)
    }
    
    private func updateRecentSearchedWord(words: [RecentSearchedWordInfo]) {
        recentSearchTableView.updateRecentSearchedWords(words: words)
    }
    
    private func updateSearchedResult(searchedResult: [NoticeArticleDTO], isLastPage: Bool) {
        [popularKeyWordGuideLabel, recommendedSearchCollectionView, recentSearchDataGuideLabel, deleteRecentSearchDataButton, recentSearchTableView].forEach {
            $0.isHidden = true
        }
        if searchedResult.isEmpty {
            emptyNoticeGuideLabel.isHidden = false
            noticeListTableView.isHidden = true
        }
        else {
            emptyNoticeGuideLabel.isHidden = true
            noticeListTableView.isHidden = false
            noticeListTableView.updateSearchedResult(noticeArticleList: searchedResult)
        }
    }
}

extension NoticeSearchViewController {
    private func setUpLayouts() {
        [navigationBarWrappedView, textField, textFieldButton, popularKeyWordGuideLabel, recommendedSearchCollectionView, recentSearchDataGuideLabel, deleteRecentSearchDataButton, recentSearchTableView, noticeListTableView, emptyNoticeGuideLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(navigationBarWrappedView.snp.bottom)
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
            $0.bottom.equalToSuperview()
        }
        
        emptyNoticeGuideLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(184)
        }
        
        noticeListTableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(textField.snp.bottom).offset(12)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
