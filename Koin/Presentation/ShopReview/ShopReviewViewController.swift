//
//  ShopReviewViewController.swift
//  koin
//
//  Created by 김나훈 on 7/8/24.
//

import Combine
import PhotosUI
import Then
import UIKit
import SnapKit

final class ShopReviewViewController: UIViewController, UITextViewDelegate {
    // MARK: - Properties
    
    private let viewModel: ShopReviewViewModel
    private let inputSubject: PassthroughSubject<ShopReviewViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    let writeCompletePublisher = PassthroughSubject<(Bool, Int?, WriteReviewRequest), Never>()
        
    private var reviewTextViewHeight: Constraint?
    private var minTextViewHeight: CGFloat {
        let font = UIFont.setFont(.body2)
        return ceil(font.lineHeight + 24)
    }
    private let maxTextViewHeight: CGFloat = 398
    
    private var tagHeightConstraint: Constraint?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then { _ in
    }
    
    private let shopNameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 20)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let reviewGuideLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.numberOfLines = 0
        $0.text = "리뷰를 남겨주시면 사장님과 다른 분들에게 도움이 됩니다.\n또한, 악의적인 리뷰는 관리자에 의해 삭제될 수 있습니다."
    }
    
    private let totalScoreView = ScoreView().then {
        $0.settings.starSize = 40
        $0.settings.starMargin = 2
        $0.settings.fillMode = .full
        $0.rating = 0
    }
    
    private let totalScoreLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.text = "0"
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral200)
    }
    
    private let imageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.text = "사진"
    }
    
    private let imageDescriptionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.text = "리뷰와 관련된 사진을 업로드해주세요."
    }
    
    private let uploadimageButton: DashedBorderButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .addPhotoAlternate)?.withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = UIColor.appColor(.neutral500)
        config.imagePlacement = .top
        config.imagePadding = 6
        
        var attributedString = AttributeContainer()
        attributedString.font = UIFont.appFont(.pretendardMedium, size: 12)
        attributedString.foregroundColor = UIColor.appColor(.neutral500)
        
        config.attributedTitle = AttributedString("0/3", attributes: attributedString)
        
        config.background.backgroundColor = UIColor.appColor(.neutral0)
        config.background.cornerRadius = 10
        config.contentInsets = .init(top: 18, leading: 16, bottom: 14, trailing: 16)
        
        return DashedBorderButton(configuration: config, primaryAction: nil)
    }()
    
    private let imageUploadCollectionView: ReviewImageUploadCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 21
        flowLayout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 8)
        flowLayout.scrollDirection = .horizontal
        let collectionView = ReviewImageUploadCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.appColor(.newBackground)
        return collectionView
    }()
    
    private let reviewDescriptionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.text = "내용"
    }
    
    private let reviewDescriptionWordLimitLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.text = "0/500"
    }
    
    private let reviewTextView = UITextView().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.layer.cornerRadius = 4
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 1.0
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.textContainer.lineFragmentPadding = 0
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let textViewPlaceHorderLabel = UILabel().then {
        $0.font = UIFont.setFont(.body2)
        $0.textColor = UIColor.appColor(.neutral400)
        $0.text = "리뷰를 작성해주세요."
    }
    
    private let reviewMenuLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let addMenuLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.text = "주문 메뉴"
    }
    
    private let addMenuDescriptioLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.text = "입력한 메뉴가 태그로 추가돼요"
    }

    private let addMenuCountLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.text = "0/5"
    }
    
    private let addMenuTextField = UITextField().then {
        $0.font = UIFont.setFont(.body2)
        $0.placeholder = "메뉴명을 입력해주세요."
        $0.textColor = UIColor.appColor(.neutral800)
        $0.layer.cornerRadius = 4
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 1.0
        $0.backgroundColor = UIColor.appColor(.neutral0)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
    }
    
    private let tagCollectionView: TagCollectionView = {
        let LeftAlignedFlowlayout = LeftAlignedFlowLayout()
        LeftAlignedFlowlayout.scrollDirection = .vertical
        LeftAlignedFlowlayout.minimumInteritemSpacing = 8
        LeftAlignedFlowlayout.minimumLineSpacing = 8
        let collectionView = TagCollectionView(frame: .zero, collectionViewLayout: LeftAlignedFlowlayout)
        collectionView.maxCount = 5
        return collectionView
    }()
    
    private let submitReviewButton = DebouncedButton().then {
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.setTitle("작성하기", for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.appColor(.neutral200)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.isEnabled = false
    }
    
    // MARK: - Initialization
    
    init(viewModel: ShopReviewViewModel) {
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
        configureView()
        hideKeyboardWhenTappedAround()
        reviewTextView.delegate = self
        inputSubject.send(.checkModify)
        inputSubject.send(.updateShopName)
        setUpKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        submitReviewButton.throttle(interval: .seconds(3)) { [weak self] in
            self?.submitReviewButtonTapped()
        }
        uploadimageButton.addTarget(self, action: #selector(uploadImageButtonTapped), for: .touchUpInside)
        addMenuTextField.addTarget(self, action: #selector(didTextFieldReturn), for: .primaryActionTriggered)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
        inputSubject.send(.getUserScreenAction(Date(), .enterVC, nil))
        setNavigationItem()
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .fillComponent(response):
                self?.fillComponent(response)
            case let .showToast(message, success):
                self?.showToastMessage(message: message)
                if success {
                    self?.navigationController?.popViewController(animated: true)
                }
            case let .addImage(imageUrl):
                self?.imageUploadCollectionView.addImageUrl(imageUrl)
            case let .updateShopName(shopName):
                self?.shopNameLabel.text = shopName
            case let .reviewWriteSuccess(isPost, reviewId, reviewItem):
                self?.writeCompletePublisher.send((isPost, reviewId, reviewItem))
                self?.inputSubject.send(.getUserScreenAction(Date(), .leaveVC, nil))
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewReviewWriteDone, .click, "", .leaveVC, nil))
            }
        }.store(in: &subscriptions)
        
        totalScoreView.onRatingChanged = { [weak self] score in
            self?.totalScoreLabel.text = "\(Int(score))"
            self?.submitReviewButton.titleLabel?.textColor = UIColor.appColor(.neutral0)
            self?.submitReviewButton.backgroundColor = UIColor.appColor(.new500)
            self?.submitReviewButton.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
            self?.submitReviewButton.isEnabled = true
        }
        
        imageUploadCollectionView.imageCountPublisher.sink { [weak self] count in
            self?.updateUploadMenuImage(count: count)
        }.store(in: &subscriptions)
                
        tagCollectionView.onCountChange = { [weak self] count in
            self?.addMenuCountLabel.text = "\(count)/5"
            self?.addMenuTextField.isHidden = count == self?.tagCollectionView.maxCount
        }
        
        tagCollectionView.onHeightChange = { [weak self] height in
            self?.tagHeightConstraint?.update(offset: height)
            self?.view.layoutIfNeeded()
        }
    }
}

extension ShopReviewViewController {
    @objc private func appDidEnterBackground() {
        inputSubject.send(.getUserScreenAction(Date(), .enterBackground, nil))
    }
    
    @objc private func appWillEnterForeground() {
        inputSubject.send(.getUserScreenAction(Date(), .enterForeground, nil))
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        reviewDescriptionWordLimitLabel.text = "\(characterCount)/500"
        textViewPlaceHorderLabel.isHidden = !textView.text.isEmpty
        calculateTextViewHeight()
    }
    
    private func calculateTextViewHeight() {
        let width = reviewTextView.bounds.width
        guard width > 0 else {return}
        
        let targetSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let fittedHeight = reviewTextView.sizeThatFits(targetSize).height
        
        let clampedHeight = min(max(fittedHeight, minTextViewHeight) , maxTextViewHeight)
        reviewTextView.isScrollEnabled = (fittedHeight > maxTextViewHeight)
        
        UIView.performWithoutAnimation {
            self.reviewTextViewHeight?.update(offset: clampedHeight)
        }
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 500
    }
    
    private func fillComponent(_ response: OneReviewDto) {
        totalScoreView.rating = Double(response.rating)
        imageUploadCollectionView.updateImageUrls(response.imageUrls)
        reviewTextView.text = response.content
        tagCollectionView.setTags(response.menuNames)
        syncReviewTextUI()
    }
    
    @objc private func uploadImageButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1 // 선택할 수 있는 사진 개수 설정
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func updateUploadMenuImage(count: Int){
        var config = uploadimageButton.configuration
        var attributedString = AttributeContainer()
        attributedString.font = UIFont.setFont(.caption2Strong)
        config?.attributedTitle = AttributedString("\(count)/3", attributes: attributedString)
        
        uploadimageButton.configuration = config
        
        uploadimageButton.isEnabled = count < 3
    }
    
    private func submitReviewButtonTapped() {
        let requestModel: WriteReviewRequest = .init(rating: Int(totalScoreView.rating), content: reviewTextView.text, imageUrls: imageUploadCollectionView.imageUrls, menuNames: tagCollectionView.items)
        inputSubject.send(.writeReview(requestModel))
    }
}

extension ShopReviewViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        self?.handleSelectedImage(image: selectedImage)
                    }
                }
            }
        }
    }
    
    private func handleSelectedImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        inputSubject.send(.uploadFile([imageData]))
    }
}

extension ShopReviewViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        view.addSubview(submitReviewButton)
        [shopNameLabel, reviewGuideLabel, totalScoreView, totalScoreLabel, separateView, imageLabel, imageDescriptionLabel, imageUploadCollectionView, uploadimageButton, reviewDescriptionLabel, reviewDescriptionWordLimitLabel, reviewTextView, reviewMenuLabel,addMenuLabel,addMenuDescriptioLabel,addMenuCountLabel,tagCollectionView,addMenuTextField].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
        }
        shopNameLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(24)
            $0.leading.equalTo(scrollView.snp.leading).offset(24)
        }
        reviewGuideLabel.snp.makeConstraints {
            $0.top.equalTo(shopNameLabel.snp.bottom).offset(10)
            $0.leading.equalTo(shopNameLabel.snp.leading)
            $0.trailing.equalTo(scrollView.snp.trailing)
            $0.trailing.equalTo(view.snp.trailing)
        }
        totalScoreView.snp.makeConstraints {
            $0.top.equalTo(reviewGuideLabel.snp.bottom).offset(16)
            $0.leading.equalTo(shopNameLabel.snp.leading)
            $0.width.equalTo(206.71)
            $0.height.equalTo(40)
        }
        totalScoreLabel.snp.makeConstraints {
            $0.centerY.equalTo(totalScoreView.snp.centerY)
            $0.leading.equalTo(totalScoreView.snp.trailing).offset(10)
        }
        separateView.snp.makeConstraints {
            $0.top.equalTo(totalScoreView.snp.bottom).offset(24)
            $0.leading.equalTo(scrollView.snp.leading).offset(20)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-20)
            $0.height.equalTo(1)
        }
        imageLabel.snp.makeConstraints {
            $0.top.equalTo(separateView.snp.bottom).offset(24)
            $0.leading.equalTo(shopNameLabel.snp.leading)
        }
        imageDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(imageLabel.snp.bottom)
            $0.leading.equalTo(shopNameLabel.snp.leading)
        }
        imageUploadCollectionView.snp.makeConstraints {
            $0.top.equalTo(imageDescriptionLabel.snp.bottom).offset(6)
            $0.leading.equalTo(uploadimageButton.snp.trailing).offset(16)
            $0.trailing.equalTo(scrollView.snp.trailing)
            $0.height.equalTo(98)
        }
        uploadimageButton.snp.makeConstraints {
            $0.top.equalTo(imageDescriptionLabel.snp.bottom).offset(12)
            $0.leading.equalTo(scrollView.snp.leading).offset(24)
            $0.height.width.equalTo(92)
        }
        reviewDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(uploadimageButton.snp.bottom).offset(27)
            $0.leading.equalTo(shopNameLabel.snp.leading)
        }
        reviewDescriptionWordLimitLabel.snp.makeConstraints {
            $0.bottom.equalTo(reviewDescriptionLabel.snp.bottom)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-32)
        }
        reviewTextView.snp.makeConstraints {
            $0.top.equalTo(reviewDescriptionLabel.snp.bottom).offset(5)
            $0.leading.equalTo(scrollView.snp.leading).offset(24)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-24)
            self.reviewTextViewHeight = $0.height.equalTo(minTextViewHeight).constraint
        }
        reviewTextView.addSubview(textViewPlaceHorderLabel)
        textViewPlaceHorderLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        reviewMenuLabel.snp.makeConstraints {
            $0.top.equalTo(reviewTextView.snp.bottom).offset(27)
            $0.leading.equalTo(scrollView.snp.leading).offset(32)
        }
        
        addMenuLabel.snp.makeConstraints {
            $0.top.equalTo(reviewTextView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
        }
        addMenuDescriptioLabel.snp.makeConstraints{
            $0.top.equalTo(addMenuLabel.snp.bottom)
            $0.leading.equalTo(addMenuLabel.snp.leading)
        }
        addMenuCountLabel.snp.makeConstraints{
            $0.bottom.equalTo(addMenuDescriptioLabel.snp.bottom)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-32)
        }
        tagCollectionView.snp.makeConstraints{
            $0.top.equalTo(addMenuDescriptioLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            tagHeightConstraint = $0.height.greaterThanOrEqualTo(1).constraint
        }
        addMenuTextField.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(12)
            $0.leading.equalTo(scrollView.snp.leading).offset(24)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-24)
            $0.height.equalTo(46)
            $0.bottom.equalTo(scrollView.snp.bottom).offset(-200)
        }
        submitReviewButton.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.height.equalTo(48)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = UIColor.appColor(.newBackground)
        scrollView.backgroundColor = UIColor.appColor(.newBackground)
    }
}


extension ShopReviewViewController {
    @objc private func didTextFieldReturn(_ textField: UITextField) {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        tagCollectionView.add(text)
        textField.text = nil
    }
    
    private func syncReviewTextUI() {
        let text = reviewTextView.text ?? ""
        textViewPlaceHorderLabel.isHidden = !text.isEmpty
        
        let count = text.count
        reviewDescriptionWordLimitLabel.text = "\(count)/500"
        
        calculateTextViewHeight()
    }
    
    @objc private func backButtonTapped(){
        if viewModel.isEdit {
            presentExitConfirm()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func presentExitConfirm() {
        guard presentedViewController == nil,
              navigationController?.transitionCoordinator == nil else { return }
        
        let viewController = BackButtonPopUpViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        viewController.onStop = { [weak self, weak viewController] in
            viewController?.dismiss(animated: false)
            self?.navigationController?.popViewController(animated: true)
        }
        present(viewController, animated: false)
    }
    
    private func setNavigationItem() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.appImage(asset: .arrowBack), style: .plain, target: self, action: #selector(backButtonTapped)
        )
    }
}


extension ShopReviewViewController {
    func setUpKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrameValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrameInView = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        let coveredHeight = max(0, keyboardFrameInView.height - view.safeAreaInsets.bottom)
        UIView.animate(withDuration: 0.2) {
            self.additionalSafeAreaInsets.bottom = coveredHeight
            self.view.layoutIfNeeded()
        }
        if let activeView = UIResponder.currentResponder as? UIView {
            let targetRect = scrollView.convert(activeView.bounds, from: activeView).insetBy(dx: 0, dy: -16)
            scrollView.scrollRectToVisible(targetRect, animated: true)
        }
    }

    @objc func keyboardWillHide(_ sender: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.additionalSafeAreaInsets.bottom = 0
            self.view.layoutIfNeeded()
        }
    }
}

extension UIResponder {

    private struct Static {
        static weak var responder: UIResponder?
    }

    static var currentResponder: UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func _trap() {
        Static.responder = self
    }
}

