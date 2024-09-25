//
//  NoticeListViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/14/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class NoticeListViewController: CustomViewController, UIGestureRecognizerDelegate {
    // MARK: - Properties
    
    private let viewModel: NoticeListViewModel
    private let inputSubject: PassthroughSubject<NoticeListViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let noticeTableView = NoticeListTableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .white
        $0.separatorStyle = .singleLine
    }
    
    private let tabBarCollectionView = TabBarCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    
    private let searchButton = UIButton().then {
        $0.setImage(.appImage(symbol: .magnifyingGlass), for: .normal)
        $0.tintColor = .appColor(.neutral800)
    }
    
    private let noticeToolTipImageView = CancelableImageView(frame: .zero)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle(title: "공지사항")
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        configureView()
        bind()
        inputSubject.send(.changeBoard(.all))
        inputSubject.send(.getUserKeywordList())
        configureSwipeGestures()
        tabBarCollectionView.tag = 0
        setUpNavigationBar()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.getUserKeywordList())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Initialization
    
    init(viewModel: NoticeListViewModel) {
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
            case let .updateBoard(noticeList, noticeListPages, noticeListType):
                self?.updateBoard(noticeList: noticeList, pageInfos: noticeListPages, noticeListType: noticeListType)
            case let .updateUserKeywordList(noticeKeywordList, keywordIdx):
                self?.updateUserKeywordList(keywords: noticeKeywordList, keywordIdx: keywordIdx)
            case let .isLogined(isLogined):
                self?.checkAndShowToolTip(isLogined: isLogined)
            }
        }.store(in: &subscriptions)
        
        tabBarCollectionView.selectTabPublisher.sink { [weak self] boardType in
            self?.inputSubject.send(.changeBoard(boardType))
        }.store(in: &subscriptions)
    
        noticeTableView.pageBtnPublisher.sink { [weak self] page in
            self?.inputSubject.send(.changePage(page))
        }.store(in: &subscriptions)
        
        noticeTableView.tapNoticePublisher.sink { [weak self] noticeId in
            let noticeListService = DefaultNoticeService()
            let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
            let fetchNoticeDataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: noticeListRepository)
            let downloadNoticeAttachmentUseCase = DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: noticeListRepository)
            let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: noticeListRepository)
            let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: downloadNoticeAttachmentUseCase, noticeId: noticeId)
            let noticeDataVc = NoticeDataViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(noticeDataVc, animated: true)
        }.store(in: &subscriptions)
        
        noticeTableView.keywordAddBtnTapPublisher
            .sink { [weak self] in
                let noticeListService = DefaultNoticeService()
                let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
                let addNotificationKeywordUseCase = DefaultAddNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
                let deleteNotificationKeywordUseCase = DefaultDeleteNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
                let fetchNotificationKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
                let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))
                let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))
                let fetchRecommendedKeywordUseCase = DefaultFetchRecommendedKeywordUseCase(noticeListRepository: noticeListRepository)
                let viewModel = ManageNoticeKeywordViewModel(addNotificationKeywordUseCase: addNotificationKeywordUseCase, deleteNotificationKeywordUseCase: deleteNotificationKeywordUseCase, fetchNotificationKeywordUseCase: fetchNotificationKeywordUseCase, fetchRecommendedKeywordUseCase: fetchRecommendedKeywordUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUseCase: fetchNotiListUseCase)
            let viewController = ManageNoticeKeywordViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        noticeTableView.keywordTapPublisher
            .sink { [weak self] keyword in
                self?.inputSubject.send(.getUserKeywordList(keyword))
        }.store(in: &subscriptions)
        
        noticeToolTipImageView.onXButtonTapped = { [weak self] in
            self?.noticeToolTipImageView.isHidden = true
        }
    }
}

extension NoticeListViewController {
    @objc private func searchButtonTapped() {
        let repository = DefaultNoticeListRepository(service: DefaultNoticeService())
        let fetchHotKeywordUseCase = DefaultFetchHotSearchingKeywordUseCase(noticeListRepository: repository)
        let searchNoticeArticlesUseCase = DefaultSearchNoticeArticlesUseCase(noticeRepository: repository)
        let manageRecentSearchedWordUseCase = DefaultManageRecentSearchedWordUseCase(noticeListRepository: repository)
        let fetchRecentSearchedWordUseCase = DefaultFetchRecentSearchedWordUseCase(noticeListRepository: repository)
        let viewModel = NoticeSearchViewModel(fetchHotKeywordUseCase: fetchHotKeywordUseCase, manageRecentSearchedWordUseCase: manageRecentSearchedWordUseCase, searchNoticeArticlesUseCase: searchNoticeArticlesUseCase, fetchRecentSearchedWordUseCase: fetchRecentSearchedWordUseCase)
        let vc = NoticeSearchViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let noticeListType = NoticeListType.allCases
        if gesture.direction == .right {
            if tabBarCollectionView.tag > 0 {
                inputSubject.send(.changeBoard(noticeListType[tabBarCollectionView.tag - 1]))
            }
        } else if gesture.direction == .left {
            if tabBarCollectionView.tag < noticeListType.count - 1 {
                inputSubject.send(.changeBoard(noticeListType[tabBarCollectionView.tag + 1]))
            }
        }
        
    }
    
    private func checkAndShowToolTip(isLogined: Bool) {
        let hasShownImage = UserDefaults.standard.bool(forKey: "hasShownNoticeTooltip")
        if !hasShownImage {
            noticeToolTipImageView.isHidden = false
            if isLogined {
                noticeToolTipImageView.setUpImage(image: .appImage(asset: .noticeLoginToolTip) ?? UIImage())
            }
            else {
                noticeToolTipImageView.setUpImage(image: .appImage(asset: .noticeNotLoginToolTip) ?? UIImage())
            }
            UserDefaults.standard.set(true, forKey: "hasShownNoticeTooltip")
        }
    }
    
    private func updateBoard(noticeList: [NoticeArticleDTO], pageInfos: NoticeListPages, noticeListType: NoticeListType) {
        tabBarCollectionView.updateBoard(noticeList: noticeList, noticeListType: noticeListType)
        noticeTableView.updateNoticeList(noticeArticleList: noticeList, pageInfos: pageInfos)
        tabBarCollectionView.tag = noticeListType.rawValue - 4
    }
 
    private func updateUserKeywordList(keywords: [NoticeKeywordDTO], keywordIdx: Int) {
        noticeTableView.updateKeywordList(keywordList: keywords, keywordIdx: keywordIdx)
    }
    
    private func configureSwipeGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        noticeTableView.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        noticeTableView.addGestureRecognizer(swipeRightGesture)
    }
}

extension NoticeListViewController {
    private func setUpLayouts() {
        [navigationBarWrappedView, tabBarCollectionView, noticeTableView, noticeToolTipImageView, searchButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        searchButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(95)
        }
        
        tabBarCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationBarWrappedView.snp.bottom)
            $0.height.equalTo(50)
        }
        
        noticeTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(tabBarCollectionView.snp.bottom).offset(1)
            $0.bottom.equalToSuperview()
        }
        
        noticeToolTipImageView.snp.makeConstraints {
            $0.top.equalTo(tabBarCollectionView.snp.bottom).offset(56)
            $0.height.equalTo(44)
            $0.width.equalTo(248)
            $0.trailing.equalToSuperview().inset(46)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .appColor(.neutral400)
    }
}
