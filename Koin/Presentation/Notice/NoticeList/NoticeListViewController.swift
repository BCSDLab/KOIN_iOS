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

final class NoticeListViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Properties
    private let viewModel: NoticeListViewModel
    private let inputSubject: PassthroughSubject<NoticeListViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let noticeTableView = NoticeListTableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
    }
    
    private let tabBarCollectionView = TabBarCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }.then {
        $0.backgroundColor = .clear
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral400)
    }
    
    private let noticeToolTipImageView = CancelableImageView(frame: .zero).then {
        $0.isHidden = true
    }
    
    // MARK: - Initialization
    
    init(viewModel: NoticeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        configureSwipeGestures()
        tabBarCollectionView.tag = 0
        inputSubject.send(.changeBoard(viewModel.noticeListType))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.getUserKeywordList())
    }
    
    // MARK: - Bind
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateBoard(noticeList, noticeListPages, noticeListType):
                self?.updateBoard(noticeList: noticeList, pageInfos: noticeListPages, noticeListType: noticeListType)
            case let .updateUserKeywordList(noticeKeywordList, selectedKeyword):
                self?.updateUserKeywordList(keywords: noticeKeywordList, selectedKeyword: selectedKeyword)
            case .showToolTip:
                self?.checkAndShowToolTip()
            }
        }.store(in: &subscriptions)
        
        tabBarCollectionView.selectTabPublisher.sink { [weak self] boardType in
            self?.inputSubject.send(.changeBoard(boardType))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.noticeTab, .click, "\(boardType.displayName)"))
        }.store(in: &subscriptions)
        
        noticeTableView.isScrolledPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.noticePage, .scroll, "공지사항"))
        }.store(in: &subscriptions)
        
        noticeTableView.pageBtnPublisher.sink { [weak self] page in
            self?.inputSubject.send(.changePage(page))
        }.store(in: &subscriptions)
        
        noticeTableView.tapNoticePublisher.sink { [weak self] item in
            self?.navigateToNoticeData(noticeId: item.0, boardId: item.1)
        }.store(in: &subscriptions)
        
        noticeTableView.searchButtonTappedPublisher
            .sink { [weak self] in
                self?.searchButtonTapped()
            }.store(in: &subscriptions)
        noticeTableView.keywordAddBtnTapPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.addKeyword, .click, "키워드추가"))
                self?.navigateToManageKeywordVC()
            }.store(in: &subscriptions)
        
        noticeTableView.keywordAllButtonTappedPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.noticeFilterAll, .click, "모두보기"))
                self?.inputSubject.send(.getUserKeywordList(nil))
            }
            .store(in: &subscriptions)
        noticeTableView.keywordTapPublisher
            .sink { [weak self] keyword in
                self?.inputSubject.send(.getUserKeywordList(keyword))
            }.store(in: &subscriptions)
        
        noticeTableView.manageKeyWordBtnTapPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.manageKeyword, .click, "키워드관리"))
            self?.navigateToManageKeywordVC()
        }.store(in: &subscriptions)
        
        noticeTableView.addButtonMinXPublisher.sink { [weak self] addButtonMinX in
            self?.moveToolTip(addButtonMinX: addButtonMinX)
        }.store(in: &subscriptions)
        
        noticeTableView.contentOffsetYPublisher.sink { [weak self] contentOffsetY in
            self?.moveToolTip(contentOffsetY: contentOffsetY)
        }.store(in: &subscriptions)
        
        noticeToolTipImageView.onXButtonTapped = { [weak self] in
            self?.noticeToolTipImageView.isHidden = true
        }
    }
}

extension NoticeListViewController {
    
    private func moveToolTip(addButtonMinX: CGFloat? = nil, contentOffsetY: CGFloat? = nil) {
        let currentTranslationX = noticeToolTipImageView.transform.tx
        let currenttranslationY = noticeToolTipImageView.transform.ty
        
        let targetTranslationX: CGFloat
        let targetTranslationY: CGFloat
        
        if let addButtonMinX {
            targetTranslationX = addButtonMinX
                + 13
                - (viewModel.isLoggedIn ? 246/2 : 223/2)
                + 22
        } else {
            targetTranslationX = currentTranslationX
        }
        
        if let contentOffsetY {
            targetTranslationY = -contentOffsetY
        } else {
            targetTranslationY = currenttranslationY
        }
        
        noticeToolTipImageView.transform = CGAffineTransform(translationX: targetTranslationX, y: targetTranslationY)
    }
}

extension NoticeListViewController {
    
    func fetchLostItems() {
        inputSubject.send(.changeBoard(viewModel.noticeListType))
    }
    func navigateToNoticeData(noticeId: Int, boardId: Int) {
        let noticeListService = DefaultNoticeService()
        let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
        let fetchNoticeDataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: noticeListRepository)
        let downloadNoticeAttachmentUseCase = DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: noticeListRepository)
        let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: noticeListRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: downloadNoticeAttachmentUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, noticeId: noticeId, boardId: boardId)
        let noticeDataVc = NoticeDataViewController(viewModel: viewModel)
       navigationController?.pushViewController(noticeDataVc, animated: true)
    }

    @objc private func searchButtonTapped() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.noticeSearch, .click, "검색"))
        let repository = DefaultNoticeListRepository(service: DefaultNoticeService())
        let fetchHotKeywordUseCase = DefaultFetchHotSearchingKeywordUseCase(noticeListRepository: repository)
        let searchNoticeArticlesUseCase = DefaultSearchNoticeArticlesUseCase(noticeRepository: repository)
        let manageRecentSearchedWordUseCase = DefaultManageRecentSearchedWordUseCase(noticeListRepository: repository)
        let fetchRecentSearchedWordUseCase = DefaultFetchRecentSearchedWordUseCase(noticeListRepository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NoticeSearchViewModel(fetchHotKeywordUseCase: fetchHotKeywordUseCase, manageRecentSearchedWordUseCase: manageRecentSearchedWordUseCase, searchNoticeArticlesUseCase: searchNoticeArticlesUseCase, fetchRecentSearchedWordUseCase: fetchRecentSearchedWordUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let vc = NoticeSearchViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let noticeListTypes = NoticeListType.allCases
            
        guard let currentIndex = noticeListTypes.firstIndex(of: viewModel.noticeListType) else { return }
            
            if gesture.direction == .right {
                if currentIndex > 0 {
                    let currentNoticeType = noticeListTypes[currentIndex - 1]
                    inputSubject.send(.changeBoard(currentNoticeType))
                }
            } else if gesture.direction == .left {
                if currentIndex < noticeListTypes.count - 1 {
                    let currentNoticeType = noticeListTypes[currentIndex + 1]
                    inputSubject.send(.changeBoard(currentNoticeType))
                }
            }
    }
    
    private func navigateToManageKeywordVC() {
        let noticeListService = DefaultNoticeService()
        let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
        let addNotificationKeywordUseCase = DefaultAddNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
        let deleteNotificationKeywordUseCase = DefaultDeleteNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
        let fetchNotificationKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))
        let fetchRecommendedKeywordUseCase = DefaultFetchRecommendedKeywordUseCase(noticeListRepository: noticeListRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = ManageNoticeKeywordViewModel(addNotificationKeywordUseCase: addNotificationKeywordUseCase, deleteNotificationKeywordUseCase: deleteNotificationKeywordUseCase, fetchNotificationKeywordUseCase: fetchNotificationKeywordUseCase, fetchRecommendedKeywordUseCase: fetchRecommendedKeywordUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUseCase: fetchNotiListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let viewController = ManageNoticeKeywordViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func checkAndShowToolTip() {
        let hasShownImage = UserDefaults.standard.bool(forKey: "hasShownNoticeTooltip")
        if !hasShownImage {
            noticeToolTipImageView.setUpImage(
                image:
                    viewModel.isLoggedIn ?
                    .appImage(asset: .noticeLoginToolTip) ?? UIImage() :
                        .appImage(asset: .noticeNotLoginToolTip) ?? UIImage()
            )
            noticeToolTipImageView.snp.remakeConstraints {
                $0.height.equalTo(44)
                $0.width.equalTo(viewModel.isLoggedIn ? 246 : 223)
                $0.leading.equalToSuperview().offset(-24)
                $0.top.equalTo(noticeTableView.snp.top).offset(44)
            }
            noticeToolTipImageView.isHidden = false
            UserDefaults.standard.set(true, forKey: "hasShownNoticeTooltip")
        }
    }
    
    private func updateBoard(
        noticeList: [NoticeArticleDto],
        pageInfos: NoticeListPages,
        noticeListType: NoticeListType
    ) {
        tabBarCollectionView.updateBoard(noticeList: noticeList, noticeListType: noticeListType)
        noticeTableView.updateNoticeList(noticeArticleList: noticeList, pageInfos: pageInfos)
        if noticeListType.rawValue < 9 {
            tabBarCollectionView.tag = noticeListType.rawValue - 4
        }
        else if noticeListType.rawValue > 11 {
            tabBarCollectionView.tag = noticeListType.rawValue - 7
        }
        else {
            tabBarCollectionView.tag = 7
        }
    }
    
    private func updateUserKeywordList(keywords: [NoticeKeywordDto], selectedKeyword: NoticeKeywordDto?) {
        noticeTableView.updateKeywordList(keywordList: keywords, selectedKeyword: selectedKeyword)
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
        [separatorView, noticeTableView, noticeToolTipImageView, tabBarCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        tabBarCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(50)
        }
        
        noticeTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(tabBarCollectionView.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(tabBarCollectionView)
            $0.height.equalTo(1)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .appColor(.neutral0)
    }
}
