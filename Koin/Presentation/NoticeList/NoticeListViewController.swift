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
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
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
    }
}

extension NoticeListViewController {
    private func updateBoard(noticeList: [NoticeArticleDTO], pageInfos: NoticeListPages, noticeListType: NoticeListType) {
        tabBarCollectionView.updateBoard(noticeList: noticeList, noticeListType: noticeListType)
        pageCollectionView.updateBoard(noticeList: noticeList, noticeListPages: pageInfos, noticeListType: noticeListType)
    }
    
    func moveIndicator(at position: CGFloat, width: CGFloat) {
        // 전달된 위치와 너비를 사용해 인디케이터 이동
        UIView.animate(withDuration: 0.2, animations: {[weak self] in
            self?.indicatorView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(position)
                $0.width.equalTo(width)
            }
            self?.view.layoutIfNeeded()
        })
    }
}

extension NoticeListViewController {
    private func setUpLayouts() {
        [tabBarCollectionView, pageCollectionView, indicatorView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        tabBarCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
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
