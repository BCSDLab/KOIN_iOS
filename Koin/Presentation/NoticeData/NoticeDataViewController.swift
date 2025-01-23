//
//  NoticeDataViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import Then
import UIKit

final class NoticeDataViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    private let viewModel: NoticeDataViewModel
    private let inputSubject: PassthroughSubject<NoticeDataViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var noticeUrl = ""
    
    // MARK: - UI Components
    
    private let deleteArticleModalViewController = DeleteArticleModalViewController(width: 301, height: 128)
    
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
    
    private let popularNoticeWrappedView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let urlRedirectButton = UIButton()
    
    private let popularNoticeGuideLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.text = "인기있는 공지"
    }
    
    private let hotNoticeArticlesTableView = HotNoticeArticlesTableView(frame: .zero, style: .plain)
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
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
    
    private let separateView1 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let separateView2 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    private let imageCollectionView: ImageScrollCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = ImageScrollCollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.appColor(.neutral300)
        pageControl.currentPageIndicatorTintColor = UIColor.appColor(.primary400)
        pageControl.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        return pageControl
    }()
    private let contentLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let councilLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        $0.textColor = UIColor.appColor(.neutral500)
        $0.numberOfLines = 3
        let text = "분실물 수령을 희망하시는 분은 재실 시간 내에\n학생회관 320호 총학생회 사무실로 방문해 주시기 바랍니다.\n재실 시간은 공지 사항을 참고해 주시기 바랍니다."
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "학생회관 320호 총학생회 사무실")
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral700), range: range)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
    }
    
    private let deleteButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .trashcanSmall)
        var text = AttributedString("삭제")
        text.font = UIFont.appFont(.pretendardMedium, size: 12)
        configuration.attributedTitle = text
        configuration.imagePadding = 0
        configuration.imagePlacement = .trailing
        configuration.baseForegroundColor = UIColor.appColor(.neutral600)
        $0.backgroundColor = UIColor.appColor(.neutral300)
        $0.configuration = configuration
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 4
        $0.contentHorizontalAlignment = .center
        $0.isHidden = true
    }
    
    
    private let noticeAttachmentsTableView = NoticeAttachmentsTableView(frame: .zero, style: .plain)
    
    // MARK: - Initialization
    
    init(viewModel: NoticeDataViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "공지사항"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inventoryButton.addTarget(self, action: #selector(tapInventoryButton), for: .touchUpInside)
        urlRedirectButton.addTarget(self, action: #selector(tapUrlRedirectButton), for: .touchUpInside)
        contentTextView.isUserInteractionEnabled = true
        contentTextView.isEditable = false
        contentTextView.delegate = self
        bind()
        deleteButton.throttle(interval: .seconds(3)) { [weak self] in
            guard let self = self else { return }
            self.present(self.deleteArticleModalViewController, animated: false)
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.findUserDelete, .click, "삭제"))
        }
        inputSubject.send(.getPopularNotices)
        if viewModel.boardId == 14 {
            lostItemConfigureView()
            inputSubject.send(.fetchLostItem(viewModel.noticeId))
            inputSubject.send(.checkAuth)
        } else {
            commonConfigureView()
            inputSubject.send(.getNoticeData)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
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
            case let .updateActivityIndictor(isStarted, fileName, downloadedPath):
                self?.updateActivityIndicator(isStarted: isStarted, fileName: fileName, downloadedPath: downloadedPath)
            case let .updateLostItem(lostItem):
                self?.updateLostItem(lostItem)
            case let .showToast(message):
                self?.showToast(message: message)
                self?.navigationController?.popViewController(animated: true)
            case let .showAuth(userType):
                self?.deleteButton.isHidden = userType.userType != .council
            }
        }.store(in: &subscriptions)
        
        hotNoticeArticlesTableView.tapHotArticlePublisher.sink { [weak self] noticeId, noticeTitle, boardId in
            self?.navigateToOtherNoticeDataPage(noticeId: noticeId, boardId: boardId)
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.popularNotice, .click, "\(noticeTitle)"))
        }.store(in: &subscriptions)
        
        noticeAttachmentsTableView.tapDownloadButtonPublisher
            .sink { [weak self] url, title in
                self?.inputSubject.send(.downloadFile(url, title))
            }.store(in: &subscriptions)
        
        imageCollectionView.currentPagePublisher.sink { [weak self] index in
            guard let self = self else { return }
            if index < self.pageControl.numberOfPages {
                self.pageControl.currentPage = index
            }
            
        }.store(in: &subscriptions)
        
        deleteArticleModalViewController.deleteButtonPublisher.sink(receiveValue: { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.findUserDeleteConfirm, .click, "확인"))
            self?.inputSubject.send(.deleteLostItem)
        }).store(in: &subscriptions)
    }
}

extension NoticeDataViewController {
    
    @objc private func deleteButtonTapped() {
        inputSubject.send(.deleteLostItem)
    }
    
    private func updateLostItem(_ item: LostArticleDetailDTO) {
        titleGuideLabel.text = NoticeListType(rawValue: item.boardId)?.displayName
        titleLabel.setLineHeight(lineHeight: 1.3, text: item.category)
        nickNameLabel.text = item.author
        createdDateLabel.text = item.registeredAt
        let imageUrls = item.image?.map { $0.imageUrl } ?? []
        imageCollectionView.setImageUrls(urls: imageUrls)
        contentLabel.text = item.content
        if imageUrls.isEmpty {
            imageCollectionView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
        imageCollectionView.isHidden = imageUrls.isEmpty
        pageControl.currentPage = 0
        pageControl.numberOfPages = imageUrls.count
        councilLabel.isHidden = item.author != "총학생회"
    }
    @objc private func tapUrlRedirectButton(sender: UIButton) {
        if let url = URL(string: noticeUrl), UIApplication.shared.canOpenURL(url) {
            inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.noticeOriginalShortcut, .click, "\(urlRedirectButton.currentTitle ?? "")"))
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func tapInventoryButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.inventory, .click, "목록"))
        guard let navigationController = navigationController else { return }
        if let index = navigationController.viewControllers.lastIndex(where: { $0 is NoticeListViewController }) {
            let viewControllersToKeep = Array(navigationController.viewControllers[0...index])
            navigationController.setViewControllers(viewControllersToKeep, animated: false)
        } else {
            if let index = navigationController.viewControllers.lastIndex(where: { $0 is HomeViewController }) {
                let viewControllersToKeep = Array(navigationController.viewControllers[0...index])
                navigationController.setViewControllers(viewControllersToKeep, animated: false)
                let noticeRepository = DefaultNoticeListRepository(service: DefaultNoticeService())
                let viewController = NoticeListViewController(viewModel: NoticeListViewModel(fetchNoticeArticlesUseCase: DefaultFetchNoticeArticlesUseCase(noticeListRepository: noticeRepository), fetchMyKeywordUseCase: DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeRepository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
                navigationController.pushViewController(viewController, animated: false)
            }
        }
    }
    
    
    private func navigateToOtherNoticeDataPage(noticeId: Int, boardId: Int) {
        let noticeListService = DefaultNoticeService()
        let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
        let fetchNoticeDataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: noticeListRepository)
        let downloadNoticeAttachmentUseCase = DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: noticeListRepository)
        let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: noticeListRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: downloadNoticeAttachmentUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, noticeId: noticeId, boardId: boardId)
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
        
        if noticeData.boardId == 12 || noticeData.boardId == 13 {
            urlRedirectButton.setTitle("아우누리 바로가기", for: .normal)
            noticeUrl = "https://portal.koreatech.ac.kr"
        }
        else if noticeData.boardId == 8 {
            urlRedirectButton.setTitle("학생종합경력개발 바로가기", for: .normal)
            noticeUrl = "https://job.koreatech.ac.kr"
        }
        else {
            if let url = noticeData.url {
                noticeUrl = url
                urlRedirectButton.setTitle("원본 글 바로가기", for: .normal)
            }
            else {
                urlRedirectButton.isHidden = true
            }
        }
    }
    
    private func updatePopularArticle(notices: [NoticeArticleDTO]) {
        hotNoticeArticlesTableView.updatePopularArticles(notices: notices)
    }
    
    private func updateActivityIndicator(isStarted: Bool, fileName: String?, downloadedPath: URL?) {
        if isStarted {
            IndicatorView.show()
        }
        else {
            IndicatorView.dismiss()
            if let fileName = fileName, let path = downloadedPath {
                presentAlert(title: "\(fileName) 다운로드 완료 \n \(path)에 저장", preferredStyle: .alert, with: [])
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
        [inventoryButton, urlRedirectButton].forEach {
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 12)
            $0.backgroundColor = .appColor(.neutral300)
            $0.setTitleColor(.appColor(.neutral600), for: .normal)
            $0.layer.cornerRadius = 4
            $0.contentEdgeInsets = .init(top: 6, left: 12, bottom: 6, right: 12)
        }
    }
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleWrappedView, contentWrappedView,popularNoticeWrappedView].forEach {
            contentView.addSubview($0)
        }
        [titleGuideLabel, titleLabel, createdDateLabel, separatorDotLabel, nickNameLabel, separatorDot2Label, eyeImageView, hitLabel].forEach {
            titleWrappedView.addSubview($0)
        }
        [contentTextView, inventoryButton, attachmentGuideLabel, noticeAttachmentsTableView, urlRedirectButton].forEach {
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
            $0.top.equalToSuperview()
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
                $0.height.equalTo(31)
                $0.bottom.equalToSuperview().inset(16)
            }
        }
        urlRedirectButton.snp.makeConstraints {
            $0.top.equalTo(inventoryButton)
            $0.height.equalTo(31)
            $0.trailing.equalToSuperview().inset(24)
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
    
    private func commonConfigureView() {
        setUpLabels()
        setUpButtons()
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
extension NoticeDataViewController {
    private func setUpLostItemLayouts() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleWrappedView, popularNoticeWrappedView, separateView1, imageCollectionView, pageControl, contentLabel, councilLabel, inventoryButton, deleteButton, separateView2].forEach {
            contentView.addSubview($0)
        }
        [titleGuideLabel, titleLabel, createdDateLabel, separatorDotLabel, nickNameLabel, separatorDot2Label].forEach {
            titleWrappedView.addSubview($0)
        }
        [popularNoticeGuideLabel, hotNoticeArticlesTableView].forEach {
            popularNoticeWrappedView.addSubview($0)
        }
    }
    private func setUpLostItemConstraints() {
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
            $0.top.equalToSuperview()
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
        separateView1.snp.makeConstraints { make in
            make.top.equalTo(titleWrappedView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(6)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separateView1.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(278)
        }
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(8)
            make.leading.trailing.equalTo(imageCollectionView)
        }
        councilLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(40)
            make.leading.trailing.equalTo(imageCollectionView)
            make.height.equalTo(89)
        }
        inventoryButton.snp.makeConstraints { make in
            make.top.equalTo(councilLabel.snp.bottom).offset(40)
            make.leading.equalTo(imageCollectionView)
            make.width.equalTo(45)
            make.height.equalTo(31)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(inventoryButton)
            make.trailing.equalTo(imageCollectionView.snp.trailing)
            make.width.equalTo(61)
            make.height.equalTo(31)
        }
        separateView2.snp.makeConstraints { make in
            make.top.equalTo(inventoryButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(6)
        }
        popularNoticeWrappedView.snp.makeConstraints {
            $0.top.equalTo(separateView2.snp.bottom).offset(6)
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
    private func lostItemConfigureView() {
        setUpLabels()
        setUpButtons()
        setUpLostItemLayouts()
        setUpLostItemConstraints()
        self.view.backgroundColor = .white
    }
}
