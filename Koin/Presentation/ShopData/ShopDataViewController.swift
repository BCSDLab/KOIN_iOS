//
//  ShopDataViewController.swift
//  koin
//
//  Created by 김나훈 on 3/13/24.
//

import Combine
import UIKit

final class ShopDataViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ShopDataViewModel
    private let inputSubject: PassthroughSubject<ShopDataViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var isSwipedToPopView: Bool = false
    private var scrollDirection: ScrollLog = .scrollToDown
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let menuTitleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var hiddenMenuTitleImageView: [UIImageView] = []
    
    private let shopTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardBold, size: 20)
        return label
    }()
    
    private let stickyShopTitleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        label.layer.borderWidth = 1.0
        label.backgroundColor = UIColor.appColor(.neutral0)
        label.font = UIFont.appFont(.pretendardBold, size: 20)
        return label
    }()
    
    private let phoneGuideLabel: GuideLabel = {
        let label = GuideLabel(frame: .zero, text: "전화번호")
        return label
    }()
    
    private let timeGuideLabel: GuideLabel = {
        let label = GuideLabel(frame: .zero, text: "운영시간")
        return label
    }()
    
    private let addressGuideLabel: GuideLabel = {
        let label = GuideLabel(frame: .zero, text: "주소정보")
        return label
    }()
    
    private let deliveryGuideLabel: GuideLabel = {
        let label = GuideLabel(frame: .zero, text: "배달금액")
        return label
    }()
    
    private let etcGuideLabel: GuideLabel = {
        let label = GuideLabel(frame: .zero, text: "기타정보")
        return label
    }()
    
    private let deliveryPossibilityLabel: UILabel = {
        let label = UILabel()
        label.text = "# 배달 가능"
        return label
    }()
    
    private let cardPossibilityLabel: UILabel = {
        let label = UILabel()
        label.text = "# 카드 가능"
        return label
    }()
    
    private let bankPossibilityLabel: UILabel = {
        let label = UILabel()
        label.text = "# 계좌이체 가능"
        return label
    }()
    
    private let lastUpdateDayLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let grayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral100)
        return view
    }()
    
    private let menuImageCollectionView: MenuImageCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 150, height: 150)
        flowLayout.minimumLineSpacing = 10
        flowLayout.scrollDirection = .horizontal
        let collectionView = MenuImageCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let categorySelectSegmentControl: UISegmentedControl = UISegmentedControl()
    
    private lazy var underlineView: UIView = {
        let width = UIScreen.main.bounds.width / CGFloat(categorySelectSegmentControl.numberOfSegments)
        let height = 2.0
        let xPosition = CGFloat(categorySelectSegmentControl.selectedSegmentIndex) * width
        let yPosition = categorySelectSegmentControl.frame.maxY + 37
        let view = UIView(frame: CGRect(x: xPosition, y: yPosition, width: width, height: height))
        view.backgroundColor = UIColor.appColor(.primary500)
        return view
    }()
    
    private let stickySelectSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.backgroundColor = UIColor.appColor(.neutral0)
        segment.isHidden = true
        return segment
    }()
    
    private lazy var stickyUnderlineView: UIView = {
        let width = UIScreen.main.bounds.width / CGFloat(stickySelectSegmentControl.numberOfSegments)
        let height = 2.0
        let xPosition = CGFloat(stickySelectSegmentControl.selectedSegmentIndex) * width
        let yPosition = stickySelectSegmentControl.frame.maxY + 37
        let view = UIView(frame: CGRect(x: xPosition, y: yPosition, width: width, height: height))
        view.backgroundColor = UIColor.appColor(.primary500)
        return view
    }()
    
    private let emptyWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral0)
        view.isHidden = true
        return view
    }()
    
    private let stickyButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor.appColor(.neutral0)
        stackView.axis = .horizontal
        stackView.isHidden = true
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let pageViewController = ShopDataPageViewController()
    
    // MARK: - Initialization
    
    init(viewModel: ShopDataViewModel) {
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
        makeSegment()
        bind()
        configureView()
        inputSubject.send(.viewDidLoad)
        addButtonItems()
        scrollView.delegate = self
        categorySelectSegmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        stickySelectSegmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        menuTitleImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.appImage(asset: .call), style: .plain, target: self, action: #selector(callButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enablePopGestureRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disablePopGestureRecognizer()
        if self.isMovingFromParent {
            if isSwipedToPopView == false {
                inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopBackButton, .click, shopTitleLabel.text ?? ""))
            }
            else {
                inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopSwipeBack, .swipe, shopTitleLabel.text ?? ""))
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categorySelectSegmentControl.addSubview(underlineView)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .showShopData(shopData):
                self?.showShopData(data: shopData)
            case let .showShopMenuList(shopMenuList):
                self?.pageViewController.setMenuCategories(shopMenuList)
                self?.updateButtons(for: strongSelf.pageViewController.menuListViewController.buttonStackView, with: shopMenuList)
                self?.updateButtons(for: strongSelf.stickyButtonStackView, with: shopMenuList)
            case let .showShopEventList(eventList):
                self?.pageViewController.setEventList(eventList)
            case let .showShopReviewList(shopReviewList, shopId, fetchStandard, isMine):
                self?.pageViewController.setReviewList(shopReviewList, shopId, fetchStandard, isMine)
            case let .showShopReviewStatistics(statistics):
                self?.pageViewController.setReviewStatistic(statistics)
            case let .showToast(message, success):
                self?.showToast(message: message, success: success)
            case let .updateReviewCount(count):
                self?.categorySelectSegmentControl.setTitle("리뷰 (\(count))", forSegmentAt: 2)
            case let .disappearReview(reviewId, shopId):
                self?.pageViewController.disappearReview(reviewId, shopId: shopId)
            }
        }.store(in: &subscriptions)
        
        pageViewController.viewControllerHeightPublisher.sink { [weak self] height in
            self?.pageViewController.view.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }.store(in: &subscriptions)
        
        pageViewController.fetchStandardPublisher.sink { [weak self] tuple in
            self?.inputSubject.send(.changeFetchStandard(tuple.0, tuple.1))
        }.store(in: &subscriptions)
        
        pageViewController.deleteReviewPublisher.sink { [weak self] tuple in
            self?.inputSubject.send(.deleteReview(tuple.0, tuple.1))
        }.store(in: &subscriptions)
        
        pageViewController.reviewCountFetchRequestPublisher.sink { [weak self] in
            self?.inputSubject.send(.updateReviewCount)
        }.store(in: &subscriptions)
        
        menuImageCollectionView.didSelectImage.sink { [weak self] image in
            let imageWidth: CGFloat = UIScreen.main.bounds.width - 48
            let imageHeight: CGFloat = imageWidth * 1.2
            let zoomedImageViewController = ZoomedImageViewController(imageWidth: imageWidth, imageHeight: imageHeight)
            zoomedImageViewController.setImage(image)
            self?.present(zoomedImageViewController, animated: true, completion: nil)
        }.store(in: &subscriptions)
        
    }
}


extension ShopDataViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        
        let labelPosition = shopTitleLabel.frame.origin.y
        let segmentPosition = categorySelectSegmentControl.frame.origin.y
        stickyShopTitleLabel.isHidden = !(scrollViewContentOffsetY > labelPosition)
        stickySelectSegmentControl.isHidden = !(scrollViewContentOffsetY > segmentPosition)
        if categorySelectSegmentControl.selectedSegmentIndex == 0 {
            stickyButtonStackView.isHidden = !(scrollViewContentOffsetY > 600)
            emptyWhiteView.isHidden = !(scrollViewContentOffsetY > 600)
        }

    }
    
    private func addButtonItems() {
        let categories = ["추천 메뉴", "메인 메뉴", "세트 메뉴", "사이드 메뉴"]
        let widthSize: [CGFloat] = [73, 73, 73, 84]
        
        for (index, categoryTitle) in categories.enumerated() {
            let button1 = UIButton(type: .system)
            configureButton(button: button1, title: categoryTitle, width: widthSize[index])
            stickyButtonStackView.addArrangedSubview(button1)
            
            let button2 = UIButton(type: .system)
            configureButton(button: button2, title: categoryTitle, width: widthSize[index])
            pageViewController.menuListViewController.buttonStackView.addArrangedSubview(button2)
        }
    }
    private func configureButton(button: UIButton, title: String, width: CGFloat) {
        button.setTitle(title, for: .normal)
        button.layer.borderWidth = 1.0
        button.clipsToBounds = true
        button.isEnabled = false
        button.layer.cornerRadius = 4
        button.tintColor = .clear
        button.tag = -1
        button.layer.borderColor = UIColor.appColor(.neutral100).cgColor
        button.setTitleColor(UIColor.appColor(.neutral400), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        scrollToMenuSection(at: sender.tag)
        changeCategoryButtonColor(sender)
    }
    
    private func changeCategoryButtonColor(_ sender: UIButton) {
        if !sender.isSelected {
            sender.backgroundColor = UIColor.appColor(.primary500)
            sender.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
            sender.layer.borderWidth = 0
            sender.isSelected = true
        }
        
        [stickyButtonStackView, pageViewController.menuListViewController.buttonStackView].forEach { stackView in
            stackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { button in
                if button.titleLabel?.text == sender.titleLabel?.text && button != sender {
                    button.backgroundColor = UIColor.appColor(.primary500)
                    button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
                    button.layer.borderWidth = 0
                    button.isSelected = true
                } else if button != sender {
                    button.backgroundColor = .systemBackground
                    button.setTitleColor(button.tag == -1 ? UIColor.appColor(.neutral400) : UIColor.appColor(.neutral500), for: .normal)
                    button.layer.borderWidth = 1.0
                    button.isSelected = false
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview)
        if velocity.y > 0 {
            scrollDirection = .scrollToTop
        }
        else {
            if scrollDirection != .scrollChecked {
                scrollDirection = .scrollToDown
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetY = self.scrollView.contentOffset.y
        let screenHeight = self.scrollView.frame.height
        if scrollDirection == .scrollToDown && contentOffsetY > screenHeight * 0.7 && scrollDirection != .scrollChecked {
            scrollDirection = .scrollChecked
            inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailView, .scroll, shopTitleLabel.text ?? ""))
        }
    }
}
extension ShopDataViewController {
    private func updateButtons(for stackView: UIStackView, with categories: [MenuCategory]) {
        var findFirstButton = false
        var tagCounter = 0
        
        for category in categories {
            if let button = stackView.arrangedSubviews.compactMap({ $0 as? UIButton }).first(where: { $0.titleLabel?.text == category.name }) {
                button.isEnabled = true
                button.layer.borderColor = UIColor.appColor(.neutral400).cgColor
                button.backgroundColor = UIColor.appColor(.neutral0)
                button.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
                button.tag = tagCounter
                tagCounter += 1
                
                if !findFirstButton {
                    findFirstButton = true
                    button.backgroundColor = UIColor.appColor(.primary500)
                    button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
                }
            }
        }
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageWidth: CGFloat = UIScreen.main.bounds.width - 48
        let imageHeight: CGFloat = imageWidth
        let zoomedImageViewController = ZoomedImageViewController(imageWidth: imageWidth, imageHeight: imageHeight)
        if hiddenMenuTitleImageView.isEmpty { zoomedImageViewController.setImage(menuTitleImageView.image) }
        else {
            let images = hiddenMenuTitleImageView.compactMap { $0.image }
            zoomedImageViewController.setImages(images)
        }
        present(zoomedImageViewController, animated: true, completion: nil)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopPicture, .click, shopTitleLabel.text ?? ""))
    }
    
    @objc func handlePopGesture() {
        if let gestureRecognizer = navigationController?.interactivePopGestureRecognizer, gestureRecognizer.state == .began {
            isSwipedToPopView = true
        }
        else { isSwipedToPopView = false }
    }
    
    private func zoomImage(image: UIImage?) {
        let imageWidth: CGFloat = UIScreen.main.bounds.width - 48
        let imageHeight: CGFloat = imageWidth
        let zoomedImageViewController = ZoomedImageViewController(imageWidth: imageWidth, imageHeight: imageHeight)
        zoomedImageViewController.setImage(image)
        present(zoomedImageViewController, animated: true, completion: nil)
    }
    
    @objc private func callButtonTapped() {
        if let phoneNumber = phoneGuideLabel.rightLabel.text,
           let url = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCall, .click, shopTitleLabel.text ?? ""))
    }
    
    private func showShopData(data: ShopData) {
        shopTitleLabel.text = data.name
        stickyShopTitleLabel.text = data.name
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 24
        paragraphStyle.headIndent = 24
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.appFont(.pretendardBold, size: 20)
        ]
        let attributedString = NSAttributedString(string: data.name, attributes: attributes)
        stickyShopTitleLabel.attributedText = attributedString
        phoneGuideLabel.configure(text: data.phone)
        setTimeGuideLabel(data.open)
        addressGuideLabel.configure(text: data.address)
        deliveryGuideLabel.configure(text: "\(data.deliveryPrice)원")
        etcGuideLabel.configure(text: data.description)
        
        for (condition, label) in [(data.delivery, deliveryPossibilityLabel),
                                   (data.payCard, cardPossibilityLabel),
                                   (data.payBank, bankPossibilityLabel)] {
            if condition {
                label.textColor = UIColor.appColor(.primary300)
                label.layer.borderColor = UIColor.appColor(.primary300).cgColor
            }
        }
        setUpLastUpdateLabel(data.updatedAt)
        
        data.imageUrls.forEach { urlString in
            let imageView = UIImageView()
            imageView.isHidden = true
            imageView.loadImage(from: urlString)
            hiddenMenuTitleImageView.append(imageView)
        }
        if !data.imageUrls.isEmpty { menuTitleImageView.loadImage(from: data.imageUrls[0]) }
        else { menuTitleImageView.image = UIImage.appImage(asset: .defaultMenuImage) }
    }
    
    @objc private func segmentDidChange(_ sender: UISegmentedControl) {
        
        pageViewController.switchToPage(index: sender.selectedSegmentIndex)
        
        switch sender {
        case categorySelectSegmentControl: stickySelectSegmentControl.selectedSegmentIndex = sender.selectedSegmentIndex
        default: categorySelectSegmentControl.selectedSegmentIndex = sender.selectedSegmentIndex
        }
        switch sender.selectedSegmentIndex {
        case 0: inputSubject.send(.fetchShopMenuList)
        case 1: inputSubject.send(.fetchShopEventList)
            stickyButtonStackView.isHidden = true
            emptyWhiteView.isHidden = true
        default: inputSubject.send(.fetchShopReviewList)
            stickyButtonStackView.isHidden = true
            emptyWhiteView.isHidden = true
        }
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.underlineView.frame.origin.x = (sender.bounds.width / CGFloat(sender.numberOfSegments)) * CGFloat(sender.selectedSegmentIndex)
            self?.stickyUnderlineView.frame.origin.x = (sender.bounds.width / CGFloat(sender.numberOfSegments)) * CGFloat(sender.selectedSegmentIndex)
        })
    }
    
    
        private func scrollToMenuSection(at section: Int) {
            let indexPath = IndexPath(row: 0, section: section)
            let collectionView = pageViewController.menuListViewController.menuListCollectionView
            
            guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }
    
            let scrollViewSpacing: CGFloat = stickyButtonStackView.isHidden ? 150 : 140
    
            let itemOffset = attributes.frame.origin.y + collectionView.frame.origin.y - scrollView.contentInset.top - pageViewController.menuListViewController.buttonStackView.frame.height - scrollViewSpacing + 650
            if #available(iOS 17.0, *) {
                UIView.animate {
                    scrollView.setContentOffset(CGPoint(x: 0, y: itemOffset), animated: false)
                }
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: itemOffset), animated: false)
            }
    
        }
    //
    
}


extension ShopDataViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        addChild(pageViewController)
        
        pageViewController.didMove(toParent: self)
        [menuTitleImageView, shopTitleLabel, phoneGuideLabel, timeGuideLabel, addressGuideLabel, etcGuideLabel, deliveryGuideLabel, deliveryPossibilityLabel, cardPossibilityLabel, bankPossibilityLabel, lastUpdateDayLabel, grayView, menuImageCollectionView, categorySelectSegmentControl, pageViewController.view].forEach {
            scrollView.addSubview($0)
        }
        [emptyWhiteView, stickyShopTitleLabel, stickySelectSegmentControl, stickyButtonStackView].forEach { component in
            view.addSubview(component)
        }
        categorySelectSegmentControl.addSubview(underlineView)
        stickySelectSegmentControl.addSubview(stickyUnderlineView)
    }
    
    private func setUpConstraints() {
        
        stickyShopTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.height.equalTo(56)
            make.trailing.equalTo(view.snp.trailing)
        }
        
        stickySelectSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(stickyShopTitleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(39)
        }
        
        stickyButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(stickySelectSegmentControl.snp.bottom).offset(9)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.height.equalTo(32)
        }
        emptyWhiteView.snp.makeConstraints { make in
            make.top.equalTo(stickySelectSegmentControl.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        menuTitleImageView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(255)
        }
        
        shopTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(menuTitleImageView.snp.bottom).offset(20)
            make.leading.equalTo(scrollView.snp.leading).offset(24)
        }
        
        phoneGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(shopTitleLabel.snp.bottom).offset(12)
            make.leading.equalTo(shopTitleLabel.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        
        timeGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneGuideLabel.snp.bottom).offset(12)
            make.leading.equalTo(shopTitleLabel.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        
        addressGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(timeGuideLabel.snp.bottom).offset(12)
            make.leading.equalTo(shopTitleLabel.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        
        deliveryGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(addressGuideLabel.snp.bottom).offset(12)
            make.leading.equalTo(shopTitleLabel.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        
        etcGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(deliveryGuideLabel.snp.bottom).offset(12)
            make.leading.equalTo(shopTitleLabel.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        
        deliveryPossibilityLabel.snp.makeConstraints { make in
            make.top.equalTo(etcGuideLabel.snp.bottom).offset(16)
            make.leading.equalTo(shopTitleLabel.snp.leading)
            make.width.equalTo(75)
            make.height.equalTo(22)
        }
        
        cardPossibilityLabel.snp.makeConstraints { make in
            make.top.equalTo(etcGuideLabel.snp.bottom).offset(16)
            make.leading.equalTo(deliveryPossibilityLabel.snp.trailing).offset(10)
            make.width.equalTo(75)
            make.height.equalTo(22)
        }
        
        bankPossibilityLabel.snp.makeConstraints { make in
            make.top.equalTo(etcGuideLabel.snp.bottom).offset(16)
            make.leading.equalTo(cardPossibilityLabel.snp.trailing).offset(10)
            make.width.equalTo(96)
            make.height.equalTo(22)
        }
        
        lastUpdateDayLabel.snp.makeConstraints { make in
            make.top.equalTo(bankPossibilityLabel.snp.bottom).offset(48)
            make.leading.equalTo(etcGuideLabel.snp.leading)
            make.height.equalTo(16)
        }
        
        grayView.snp.makeConstraints { make in
            make.top.equalTo(lastUpdateDayLabel.snp.bottom).offset(16)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.height.equalTo(12)
        }
        
        categorySelectSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(grayView.snp.bottom)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.height.equalTo(39)
        }
        
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(categorySelectSegmentControl.snp.bottom)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.height.equalTo(1)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
    }
    
    private func setUpLabel() {
        [deliveryPossibilityLabel, cardPossibilityLabel, bankPossibilityLabel].forEach { label in
            label.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            label.layer.borderWidth = 1.0
            label.textColor = UIColor.appColor(.neutral300)
            label.font = UIFont.appFont(.pretendardRegular, size: 12)
            label.clipsToBounds = true
            label.layer.cornerRadius = 5
            label.textAlignment = .center
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpLabel()
        self.view.backgroundColor = .systemBackground
    }
}

extension ShopDataViewController {
    
    private func setTimeGuideLabel(_ data: [Open]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = Date()
        let calendar = Calendar.current
        let weekDay = (calendar.component(.weekday, from: todayDate) + 5) % 7
        
        let daysOfWeek = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
        let currentDay = daysOfWeek[weekDay]
        
        if let todayData = data.first(where: { $0.dayOfWeek == currentDay }) {
            let todayOpenTime = todayData.openTime
            let todayCloseTime = todayData.closeTime
            if let openTime = todayOpenTime, let closeTime = todayCloseTime {
                timeGuideLabel.configure(text: "\(openTime) ~ \(closeTime)")
            } else {
                timeGuideLabel.configure(text: "-")
            }
        } else {
            timeGuideLabel.configure(text: "-")
        }
        
        
    }
    private func setUpLastUpdateLabel(_ date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let originalDate = dateFormatter.date(from: date) else { return }
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = "\(dateFormatter.string(from: originalDate)) 업데이트"
        
        let attributeString = NSMutableAttributedString(string: "")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.neutral400),
            .baselineOffset: 0
        ]
        
        let imageAttachment = NSTextAttachment(image: UIImage.appImage(asset: .noticeWarning) ?? UIImage())
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
        attributeString.append(NSAttributedString(attachment: imageAttachment))
        attributeString.append(NSAttributedString(string: " "))
        attributeString.append(NSAttributedString(string: formattedDate))
        attributeString.addAttributes(attributes, range: NSRange(location: 0, length: attributeString.length))
        lastUpdateDayLabel.attributedText = attributeString
    }
    
    private func makeSegment() {
        [categorySelectSegmentControl, stickySelectSegmentControl].forEach { segment in
            segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
            segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            segment.insertSegment(withTitle: "메뉴", at: 0, animated: true)
            segment.insertSegment(withTitle: "이벤트/공지", at: 1, animated: true)
  //          segment.insertSegment(withTitle: "리뷰", at: 2, animated: true)
            segment.selectedSegmentIndex = 0
            segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500).withAlphaComponent(0.2), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 16)], for: .normal)
            segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 16)], for: .selected)
        }
    }
}

extension ShopDataViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func enablePopGestureRecognizer() {
        guard let navigationController = navigationController else { return }
        let popGestureRecognizer = navigationController.interactivePopGestureRecognizer
        popGestureRecognizer?.delegate = self
        popGestureRecognizer?.addTarget(self, action: #selector(handlePopGesture))
    }
    
    private func disablePopGestureRecognizer() {
        guard let navigationController = navigationController else { return }
        let popGestureRecognizer = navigationController.interactivePopGestureRecognizer
        popGestureRecognizer?.delegate = nil
        popGestureRecognizer?.removeTarget(self, action: #selector(handlePopGesture))
    }
}
