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

final class NoticeListViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: NoticeListViewModel
    private let inputSubject: PassthroughSubject<NoticeListViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let pageCollectionView = PageCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    
    private let tabBarCollectionView = TabBarCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .appColor(.primary500)
    }
    
    private let navigationTitle = UILabel().then {
        $0.text = "공지사항"
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .arrowBack), for: .normal)
        $0.tintColor = .appColor(.neutral800)
    }
    
    private let navigationBarWrappedView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        super.viewDidLoad()
        configureView()
        bind()
        inputSubject.send(.getUserKeyWordList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
            case let .updateUserKeyWordList(noticeKeyWordList, noticeListType):
                self?.updateUserKeyWordList(keyWords: noticeKeyWordList, noticeListType: noticeListType)
            }
        }.store(in: &subscriptions)
        
        tabBarCollectionView.selectTabPublisher.sink { [weak self] boardType in
            self?.inputSubject.send(.changeBoard(boardType))
        }.store(in: &subscriptions)
        
        tabBarCollectionView.indicatorInfoPublisher.sink { [weak self] indicatorLocation in
            self?.moveIndicator(at: indicatorLocation.0, width: indicatorLocation.1)
        }.store(in: &subscriptions)
        
        pageCollectionView.scrollBoardPublisher.sink { [weak self] boardType in
            self?.inputSubject.send(.changeBoard(boardType))
        }.store(in: &subscriptions)
        
        pageCollectionView.pageBtnPublisher
            .throttle(for: .milliseconds(300), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] page in
            self?.inputSubject.send(.changePage(page))
        }.store(in: &subscriptions)
        
        pageCollectionView.tapNoticePublisher
            .throttle(for: .milliseconds(300), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] noticeId in
            let noticeListService = DefaultNoticeService()
            let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
            let fetchNoticeDataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: noticeListRepository)
            let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: noticeListRepository)
                let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, noticeId: noticeId)
            let noticeDataVc = NoticeDataViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(noticeDataVc, animated: true)
        }.store(in: &subscriptions)
    }
}

extension NoticeListViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func updateBoard(noticeList: [NoticeArticleDTO], pageInfos: NoticeListPages, noticeListType: NoticeListType) {
        tabBarCollectionView.updateBoard(noticeList: noticeList, noticeListType: noticeListType)
        pageCollectionView.updateBoard(noticeList: noticeList, noticeListPages: pageInfos, noticeListType: noticeListType)
    }
    
    private func moveIndicator(at position: CGFloat, width: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: {[weak self] in
            self?.indicatorView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(position)
                $0.width.equalTo(width)
            }
            self?.view.layoutIfNeeded()
        })
    }
    
    private func updateUserKeyWordList(keyWords: [NoticeKeyWordDTO], noticeListType: NoticeListType) {
        pageCollectionView.updateKeyWordList(keyWordList: keyWords, noticeListType: noticeListType)
    }
}

extension NoticeListViewController {
    private func setUpLayouts() {
        [navigationBarWrappedView, tabBarCollectionView, pageCollectionView, indicatorView].forEach {
            view.addSubview($0)
        }
        [backButton, navigationTitle].forEach {
            navigationBarWrappedView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(backButton).offset(13)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        navigationTitle.snp.makeConstraints {
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        tabBarCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationBarWrappedView.snp.bottom)
            $0.height.equalTo(50)
        }
        
        pageCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(tabBarCollectionView.snp.bottom).offset(1)
            $0.bottom.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints {
            $0.top.equalTo(tabBarCollectionView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(1.5)
            $0.width.equalTo(50)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .appColor(.neutral400)
    }
}
