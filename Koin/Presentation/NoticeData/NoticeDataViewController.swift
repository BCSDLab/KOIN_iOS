//
//  NoticeDataViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import Then
import UIKit

final class NoticeDataViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: NoticeDataViewModel
    private let inputSubject: PassthroughSubject<NoticeDataViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let titleWrappedView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let titleGuideLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 14)
        $0.textColor = .appColor(.primary600)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 16)
        $0.numberOfLines = 0
        $0.textColor = .appColor(.neutral800)
    }
    
    private let nickName = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral500)
    }
    
    private let createdDate = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral500)
    }
    
    private let separatorDot = UILabel().then {
        $0.text = "·"
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral500)
    }
    
    private let contentWrappedView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let inventoryButton = UIButton().then {
        $0.setTitle("목록", for: .normal)
    }
    
    private let previousButton = UIButton().then {
        $0.setTitle("이전 글", for: .normal)
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("다음 글", for: .normal)
    }
    
    private let popularNoticeWrappedView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let popularNoticeGuideLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.text = "인기있는 공지"
    }
    
    private let hotNoticeArticlesTableView = HotNoticeArticlesTableView(frame: .zero, style: .plain)
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    
    private let contentLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    private let contentImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    // MARK: - Initialization
    
    init(viewModel: NoticeDataViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        inputSubject.send(.getNoticeData)
        inputSubject.send(.getPopularNotices)
        configureView()
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateNoticeData(noticeData):
                self?.updateNoticeData(noticeData: noticeData)
            case let .updatePopularArticles(notices):
                self?.updatePopularArticle(notices: notices)
            }
        }.store(in: &subscriptions)
    }
}

extension NoticeDataViewController {
    private func updateNoticeData(noticeData: NoticeDataInfo) {
        titleGuideLabel.text = NoticeListType(rawValue: noticeData.boardId)?.displayName
        titleLabel.text = noticeData.title
        nickName.text = noticeData.nickName
        createdDate.text = noticeData.createdAt
        contentLabel.attributedText = noticeData.content.extractFromHtmlTag(regularFont: UIFont.appFont(.pretendardRegular, size: 14), boldFont: .appFont(.pretendardBold, size: 14))
        if let imageString = noticeData.imageString {
            contentImage.loadImage(from: imageString)
        }
        else {
            contentImage.isHidden = true
            inventoryButton.snp.remakeConstraints {
                $0.top.equalTo(contentLabel.snp.bottom).offset(32)
                $0.leading.equalToSuperview().offset(24)
                $0.width.equalTo(45)
                $0.height.equalTo(31)
            }
        }
    }
    
    private func updatePopularArticle(notices: [NoticeArticleDTO]) {
        hotNoticeArticlesTableView.updatePopularArticles(notices: notices)
    }
}

extension NoticeDataViewController {
    private func setUpButtons() {
        [inventoryButton, previousButton, nextButton].forEach {
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 12)
            $0.backgroundColor = .appColor(.neutral300)
            $0.setTitleColor(.appColor(.neutral600), for: .normal)
            $0.layer.cornerRadius = 4
        }
        previousButton.backgroundColor = .appColor(.neutral400)
    }
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleWrappedView, contentWrappedView,popularNoticeWrappedView].forEach {
            contentView.addSubview($0)
        }
        [titleGuideLabel, titleLabel, createdDate, separatorDot, nickName].forEach {
            titleWrappedView.addSubview($0)
        }
        [contentLabel, contentImage, inventoryButton, previousButton, nextButton].forEach {
            contentWrappedView.addSubview($0)
        }
        [popularNoticeGuideLabel, hotNoticeArticlesTableView].forEach {
            popularNoticeWrappedView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }
        
        titleWrappedView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        titleGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(12)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(titleGuideLabel.snp.bottom)
            $0.leading.equalTo(titleGuideLabel)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        createdDate.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
        }
        
        separatorDot.snp.makeConstraints {
            $0.leading.equalTo(createdDate.snp.trailing).offset(2)
            $0.top.equalTo(createdDate)
        }
        
        nickName.snp.makeConstraints {
            $0.leading.equalTo(separatorDot.snp.trailing).offset(2)
            $0.top.equalTo(createdDate)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        contentWrappedView.snp.makeConstraints {
            $0.top.equalTo(titleWrappedView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        contentImage.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(32)
            $0.width.equalTo(327)
            $0.height.equalTo(457)
            $0.centerX.equalToSuperview()
        }
        
        inventoryButton.snp.makeConstraints {
            $0.top.equalTo(contentImage.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(45)
            $0.height.equalTo(31)
        }
        
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(inventoryButton)
            $0.height.equalTo(31)
            $0.width.equalTo(59)
        }
        
        previousButton.snp.makeConstraints {
            $0.trailing.equalTo(nextButton.snp.leading).offset(-8)
            $0.top.equalTo(inventoryButton)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(31)
            $0.width.equalTo(59)
        }
        
        popularNoticeWrappedView.snp.makeConstraints {
            $0.top.equalTo(contentWrappedView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        popularNoticeGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(24)
        }
        
        hotNoticeArticlesTableView.snp.makeConstraints {
            $0.top.equalTo(popularNoticeGuideLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(184)
            $0.bottom.equalToSuperview().inset(129) 
        }
    }

    
    private func configureView() {
        setUpButtons()
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}


