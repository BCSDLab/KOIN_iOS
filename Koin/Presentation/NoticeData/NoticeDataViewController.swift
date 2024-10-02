//
//  NoticeDataViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import Then
import UIKit

final class NoticeDataViewController: CustomViewController, UIGestureRecognizerDelegate {
    
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
    
    private let nickNameLabel = UILabel()
    
    private let createdDateLabel = UILabel()
    
    private let separatorDotLabel = UILabel().then {
        $0.text = "·"
    }
    private let separatorDot2Label = UILabel().then {
        $0.text = "·"
    }
    
    private let eyeImageView = UIImageView().then {
        $0.tintColor = .appColor(.neutral500)
        $0.image = UIImage.appImage(asset: .eye)
    }
    
    private let hitLabel = UILabel()
    
    private let contentWrappedView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let inventoryButton = UIButton().then {
        $0.setTitle("목록", for: .normal)
    }
    
    /* 변경된 명세로 이번 배포에서 숨김처리
    private let previousButton = UIButton().then {
        $0.setTitle("이전 글", for: .normal)
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("다음 글", for: .normal)
    } */
    
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
    
    private let contentTextView = UITextView().then {
        $0.isScrollEnabled = false
    }
    
    private let contentImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let attachmentGuideLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.text = "첨부파일"
    }

    private let noticeAttachmentsTableView = NoticeAttachmentsTableView(frame: .zero, style: .plain)
    
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
        inventoryButton.addTarget(self, action: #selector(tapInventoryButton), for: .touchUpInside)
        contentTextView.isUserInteractionEnabled = true
        contentTextView.isEditable = false
        contentTextView.delegate = self
        /*
        nextButton.isHidden = true
        previousButton.isHidden = true
        previousButton.addTarget(self, action: #selector(tapOtherNoticeBtn), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tapOtherNoticeBtn), for: .touchUpInside) */
        bind()
        setNavigationTitle(title: "공지사항")
        inputSubject.send(.getNoticeData)
        inputSubject.send(.getPopularNotices)
        configureView()
        setUpNavigationBar()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
            case let .updateActivityIndictor(isStarted, fileName):
                self?.updateActivityIndicator(isStarted: isStarted, fileName: fileName)
            }
        }.store(in: &subscriptions)
        
        hotNoticeArticlesTableView.tapHotArticlePublisher.sink { [weak self] noticeId in
            self?.navigateToOtherNoticeDataPage(noticeId: noticeId)
        }.store(in: &subscriptions)
        
        noticeAttachmentsTableView.tapDownloadButtonPublisher
            .sink { [weak self] url, title in
            self?.inputSubject.send(.downloadFile(url, title))
        }.store(in: &subscriptions)
    }
}

extension NoticeDataViewController {
    @objc private func tapInventoryButton() {
        guard let navigationController = navigationController else { return }
        if let index = navigationController.viewControllers.lastIndex(where: { $0 is NoticeListViewController }) {
            let viewControllersToKeep = Array(navigationController.viewControllers[0...index])
            navigationController.setViewControllers(viewControllersToKeep, animated: false)
        } else {
            if let index = navigationController.viewControllers.lastIndex(where: { $0 is HomeViewController }) {
                let viewControllersToKeep = Array(navigationController.viewControllers[0...index])
                navigationController.setViewControllers(viewControllersToKeep, animated: false)
                let noticeRepository = DefaultNoticeListRepository(service: DefaultNoticeService())
                let viewController = NoticeListViewController(viewModel: NoticeListViewModel(fetchNoticeArticlesUseCase: DefaultFetchNoticeArticlesUseCase(noticeListRepository: noticeRepository), fetchMyKeywordUseCase: DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeRepository)))
                navigationController.pushViewController(viewController, animated: false)
            }
        }
    }
    
    /*
    @objc private func tapOtherNoticeBtn(sender: UIButton) {
        if let noticeId = sender == previousButton ? viewModel.previousNoticeId : viewModel.nextNoticeId {
            navigateToOtherNoticeDataPage(noticeId: noticeId)
        }
    }*/
    
    private func navigateToOtherNoticeDataPage(noticeId: Int) {
        let noticeListService = DefaultNoticeService()
        let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
        let fetchNoticeDataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: noticeListRepository)
        let downloadNoticeAttachmentUseCase = DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: noticeListRepository)
        let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: noticeListRepository)
        let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: downloadNoticeAttachmentUseCase, noticeId: noticeId)
        let noticeDataVc = NoticeDataViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(noticeDataVc, animated: true)
    }
    
    private func updateNoticeData(noticeData: NoticeDataInfo) {
        titleGuideLabel.text = NoticeListType(rawValue: noticeData.boardId)?.displayName
        titleLabel.setLineHeight(lineHeight: 1.3, text: noticeData.title)
        nickNameLabel.text = noticeData.author
        createdDateLabel.text = noticeData.registeredAt
        
        contentTextView.attributedText = noticeData.content.convertToAttributedFromHTML()
        let contentTextViewHeight = contentTextView.sizeThatFits(CGSize(width: contentTextView.frame.width, height: .greatestFiniteMagnitude))
        contentTextView.snp.updateConstraints {
            $0.height.equalTo(contentTextViewHeight)
        }
        /*
        if let prevId = noticeData.prevId {
            previousButton.isHidden = false
            viewModel.previousNoticeId = prevId
        }
        
        if let nextId = noticeData.nextId {
            nextButton.isHidden = false
            viewModel.nextNoticeId = nextId
        }*/
        
        if noticeData.hit == 0 {
            [separatorDot2Label, eyeImageView, hitLabel].forEach {
                $0.isHidden = true
            }
        }
        else {
            [separatorDot2Label, eyeImageView, hitLabel].forEach {
                $0.isHidden = false
            }
            hitLabel.text = "\(noticeData.hit.formattedWithComma)"
        }
        if !noticeData.attachments.isEmpty {
            noticeAttachmentsTableView.updateNoticeAttachments(attachments: noticeData.attachments)
            attachmentGuideLabel.isHidden = false
            noticeAttachmentsTableView.isHidden = false
            let height = noticeData.attachments.count * 65
            noticeAttachmentsTableView.snp.updateConstraints {
                $0.height.equalTo(height)
            }
        }
        else {
            attachmentGuideLabel.isHidden = true
            noticeAttachmentsTableView.isHidden = true
        }
    }
    
    private func updatePopularArticle(notices: [NoticeArticleDTO]) {
        hotNoticeArticlesTableView.updatePopularArticles(notices: notices)
    }
    
    private func updateActivityIndicator(isStarted: Bool, fileName: String?) {
        if isStarted {
            IndicatorView.show()
        }
        else {
            IndicatorView.dismiss()
            if let fileName = fileName {
                presentAlert(title: "\(fileName) 다운로드 완료", preferredStyle: .alert, with: [])
            }
        }
    }
}

extension NoticeDataViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        guard let image = textAttachment.image else { return false}
        
        let imageWidth: CGFloat = UIScreen.main.bounds.width - 48
        let smallProportion: CGFloat = image.size.width / imageWidth
        let imageHeight: CGFloat = image.size.height / smallProportion
        let zoomedImageViewController = ZoomedImageViewController(imageWidth: imageWidth, imageHeight: imageHeight.isNaN ? 100 : imageHeight)
        zoomedImageViewController.setImage(image)
        self.present(zoomedImageViewController, animated: true)
        
        return true
    }
}

extension NoticeDataViewController {
    private func setUpLabels() {
        [nickNameLabel, separatorDotLabel, createdDateLabel, separatorDot2Label, hitLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textAlignment = .left
            $0.textColor = .appColor(.neutral500)
        }
    }
    
    private func setUpButtons() {
        //[inventoryButton, previousButton, nextButton]
        [inventoryButton].forEach {
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 12)
            $0.backgroundColor = .appColor(.neutral300)
            $0.setTitleColor(.appColor(.neutral600), for: .normal)
            $0.layer.cornerRadius = 4
        }
        //previousButton.backgroundColor = .appColor(.neutral400)
    }
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleWrappedView, contentWrappedView,popularNoticeWrappedView].forEach {
            contentView.addSubview($0)
        }
    
        [navigationBarWrappedView, titleGuideLabel, titleLabel, createdDateLabel, separatorDotLabel, nickNameLabel, separatorDot2Label, eyeImageView, hitLabel].forEach {
            titleWrappedView.addSubview($0)
        }
        //[contentTextView, inventoryButton, previousButton, nextButton].forEach {
        [contentTextView, inventoryButton, attachmentGuideLabel, noticeAttachmentsTableView].forEach {
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
        
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        titleGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(navigationBarWrappedView.snp.bottom).offset(9)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(titleGuideLabel.snp.bottom)
            $0.leading.equalTo(titleGuideLabel)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        createdDateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.height.equalTo(19)
        }
        
        separatorDotLabel.snp.makeConstraints {
            $0.leading.equalTo(createdDateLabel.snp.trailing).offset(3)
            $0.top.equalTo(createdDateLabel)
            $0.width.equalTo(7)
            $0.height.equalTo(19)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.leading.equalTo(separatorDotLabel.snp.trailing).offset(3)
            $0.top.equalTo(createdDateLabel)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(19)
        }
        
        separatorDot2Label.snp.makeConstraints {
            $0.leading.equalTo(nickNameLabel.snp.trailing).offset(3)
            $0.top.equalTo(nickNameLabel)
            $0.width.equalTo(7)
        }
        
        eyeImageView.snp.makeConstraints {
            $0.leading.equalTo(separatorDot2Label.snp.trailing).offset(2)
            $0.centerY.equalTo(nickNameLabel)
            $0.width.equalTo(16)
            $0.height.equalTo(13)
        }
        
        hitLabel.snp.makeConstraints {
            $0.leading.equalTo(eyeImageView.snp.trailing)
            $0.top.equalTo(nickNameLabel)
            $0.height.equalTo(19)
        }
        
        contentWrappedView.snp.makeConstraints {
            $0.top.equalTo(titleWrappedView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(100)
        }
        
        attachmentGuideLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(14)
            $0.leading.equalTo(contentTextView)
            $0.height.equalTo(26)
        }
        
        noticeAttachmentsTableView.snp.makeConstraints {
            $0.top.equalTo(attachmentGuideLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        if attachmentGuideLabel.isHidden {
            inventoryButton.snp.makeConstraints {
                $0.top.equalTo(contentTextView.snp.bottom).offset(22)
                $0.leading.equalToSuperview().offset(24)
                $0.width.equalTo(45)
                $0.height.equalTo(31)
                $0.bottom.equalToSuperview().inset(16)
            }
        }
        else {
            inventoryButton.snp.makeConstraints {
                $0.top.equalTo(noticeAttachmentsTableView.snp.bottom).offset(8)
                $0.leading.equalToSuperview().offset(24)
                $0.width.equalTo(45)
                $0.height.equalTo(31)
                $0.bottom.equalToSuperview().inset(16)
            }
        }
        
        /*
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(inventoryButton)
            $0.height.equalTo(31)
            $0.width.equalTo(59)
        }
        
        previousButton.snp.makeConstraints {
            $0.trailing.equalTo(nextButton.snp.leading).offset(-8)
            $0.top.equalTo(inventoryButton)
            $0.height.equalTo(31)
            $0.width.equalTo(59)
        }*/
        
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
        setUpLabels()
        setUpButtons()
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}


