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
        $0.separatorStyle = .singleLine
    }
    
    private let writeButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .pencil)
        var text = AttributedString("글쓰기")
        text.font = UIFont.appFont(.pretendardMedium, size: 16)
        configuration.attributedTitle = text
        configuration.imagePadding = 0
        configuration.imagePlacement = .leading
        configuration.baseForegroundColor = UIColor.appColor(.neutral600)
        $0.backgroundColor = UIColor.appColor(.neutral50)
        $0.configuration = configuration
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 18
        $0.contentHorizontalAlignment = .center
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.isHidden = true
    }
    
    private let tabBarCollectionView = TabBarCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    
    private let noticeToolTipImageView = CancelableImageView(frame: .zero)
    
    private let postLostItemLoginModalViewController = LoginModalViewController(width: 301, height: 208, paddingBetweenLabels: 15, title: "게시글을 작성하려면\n로그인이 필요해요.", subTitle: "로그인 후 분실물 주인을 찾아주세요!", titleColor: UIColor.appColor(.neutral700), subTitleColor: UIColor.appColor(.gray)).then { 
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let writeTypeModalViewController = WriteTypeModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    // MARK: - Initialization
    
    init(viewModel: NoticeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "공지사항"
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
        inputSubject.send(.checkAuth)
        let rightBarButton = UIBarButtonItem(image: .appImage(symbol: .magnifyingGlass), style: .plain, target: self, action: #selector(searchButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButton
        
        writeButton.addTarget(self, action: #selector(writeButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.getUserKeywordList())
        inputSubject.send(.changeBoard(viewModel.noticeListType))
        configureNavigationBar(style: .empty)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .updateBoard(noticeList, noticeListPages, noticeListType):
                self?.updateBoard(noticeList: noticeList, pageInfos: noticeListPages, noticeListType: noticeListType)
                self?.writeButton.isHidden = self?.viewModel.noticeListType != .lostItem
            case let .updateUserKeywordList(noticeKeywordList, keywordIdx):
                self?.updateUserKeywordList(keywords: noticeKeywordList, keywordIdx: keywordIdx)
            case let .isLogined(isLogined):
                self?.checkAndShowToolTip(isLogined: isLogined)
            case let .showIsLogined(isLogined):
                if isLogined { strongSelf.present(strongSelf.writeTypeModalViewController, animated: true) }
                else { strongSelf.present(strongSelf.postLostItemLoginModalViewController, animated: true) }
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
        
        noticeTableView.keywordAddBtnTapPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.addKeyword, .click, "키워드추가"))
                self?.navigateToManageKeywordVC()
            }.store(in: &subscriptions)
        
        noticeTableView.keywordTapPublisher
            .sink { [weak self] keyword in
                if keyword.id == -1 {
                    self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.noticeFilterAll, .click, "모두보기"))
                }
                self?.inputSubject.send(.getUserKeywordList(keyword))
            }.store(in: &subscriptions)
        
        noticeTableView.manageKeyWordBtnTapPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.manageKeyword, .click, "키워드관리"))
            self?.navigateToManageKeywordVC()
        }.store(in: &subscriptions)
        
        noticeToolTipImageView.onXButtonTapped = { [weak self] in
            self?.noticeToolTipImageView.isHidden = true
        }
        
        postLostItemLoginModalViewController.loginButtonPublisher.sink { [weak self] in
            self?.navigateToLogin()
        }.store(in: &subscriptions)
        
        writeTypeModalViewController.findButtonPublisher.sink { [weak self] in
            let viewController = PostLostItemViewController(viewModel: PostLostItemViewModel(type: .found))
            viewController.delegate = self
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.itemWrite, .click, "글쓰기"))
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        writeTypeModalViewController.lostButtonPublisher.sink { [weak self] in
            let viewController = PostLostItemViewController(viewModel: PostLostItemViewModel(type: .lost))
            viewController.delegate = self
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.itemWrite, .click, "글쓰기"))
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension NoticeListViewController {
    
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
    @objc private func writeButtonTapped() {
        inputSubject.send(.checkLogin)
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
        [tabBarCollectionView, noticeTableView, noticeToolTipImageView, writeButton].forEach {
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
            $0.top.equalTo(tabBarCollectionView.snp.bottom).offset(1)
            $0.bottom.equalToSuperview()
        }
        
        noticeToolTipImageView.snp.makeConstraints {
            $0.top.equalTo(tabBarCollectionView.snp.bottom).offset(56)
            $0.height.equalTo(44)
            $0.width.equalTo(248)
            $0.trailing.equalToSuperview().inset(46)
        }
        
        writeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-63)
            make.trailing.equalTo(view.snp.trailing).offset(-21)
            make.width.equalTo(94)
            make.height.equalTo(42)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .appColor(.neutral400)
    }
}
