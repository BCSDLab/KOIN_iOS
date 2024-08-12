//
//  ShopReviewViewController.swift
//  koin
//
//  Created by 김나훈 on 7/8/24.
//

import Combine
import Then
import UIKit

final class ShopReviewViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: ShopReviewViewModel
    private let inputSubject: PassthroughSubject<ShopReviewViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
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
    }
    
    private let totalScoreLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.text = "3"
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral200)
    }
    
    private let photoLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.text = "사진"
    }
    
    private let photoDescriptionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.text = "리뷰와 관련된 사진을 업로드해주세요."
    }
    
    private let photoNumberLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.text = "0/3"
    }
    
    private let uploadPhotoView = UIView().then {
        $0.isHidden = true
    }
    
    private let uploadPhotoButton = UIButton().then {
        $0.setTitle("사진 등록하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    private let reviewDescriptionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
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
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let reviewMenuLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let addMenuButton = UIButton().then {
        $0.setTitle("메뉴 추가하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    private let addMyselfButton = UIButton().then {
        $0.setTitle("직접 추가하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    private let submitReviewButton = UIButton().then {
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.titleLabel?.textColor = UIColor.appColor(.neutral0)
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("작성하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
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
        submitReviewButton.addTarget(self, action: #selector(submitReviewButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
                
            }
        }.store(in: &subscriptions)
        
        totalScoreView.didFinishTouchingCosmos = { [weak self] score in
            self?.totalScoreLabel.text = "\(Int(score))"
        }
    }
}

extension ShopReviewViewController {
    @objc private func submitReviewButtonTapped() {
        inputSubject.send(.writeReview)
    }
    
}

extension ShopReviewViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        [shopNameLabel, reviewGuideLabel, totalScoreView, totalScoreLabel, separateView, photoLabel, photoDescriptionLabel, photoNumberLabel, uploadPhotoView, uploadPhotoButton, reviewDescriptionLabel, reviewDescriptionWordLimitLabel, reviewTextView, reviewMenuLabel, addMenuButton, addMyselfButton, submitReviewButton].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        shopNameLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(24)
            $0.leading.equalTo(scrollView.snp.leading).offset(24)
        }
        reviewGuideLabel.snp.makeConstraints {
            $0.top.equalTo(shopNameLabel.snp.bottom).offset(5)
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
        photoLabel.snp.makeConstraints {
            $0.top.equalTo(separateView.snp.bottom).offset(19)
            $0.leading.equalTo(shopNameLabel.snp.leading)
        }
        photoDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(photoLabel.snp.bottom)
            $0.leading.equalTo(shopNameLabel.snp.leading)
        }
        photoNumberLabel.snp.makeConstraints {
            $0.top.equalTo(photoDescriptionLabel.snp.top)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-32)
        }
        uploadPhotoButton.snp.makeConstraints {
            $0.top.equalTo(photoDescriptionLabel.snp.bottom).offset(5)
            $0.leading.equalTo(scrollView.snp.leading).offset(24)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-24)
            $0.height.equalTo(46)
        }
        reviewDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(uploadPhotoButton.snp.bottom).offset(27)
            $0.leading.equalTo(scrollView.snp.leading).offset(32)
        }
        reviewDescriptionWordLimitLabel.snp.makeConstraints {
            $0.bottom.equalTo(reviewDescriptionLabel.snp.bottom)
            $0.trailing.equalTo(photoNumberLabel.snp.trailing)
        }
        reviewTextView.snp.makeConstraints {
            $0.top.equalTo(reviewDescriptionLabel.snp.bottom).offset(5)
            $0.leading.equalTo(scrollView.snp.leading).offset(24)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-24)
            $0.height.equalTo(46)
        }
        reviewMenuLabel.snp.makeConstraints {
            $0.top.equalTo(reviewTextView.snp.bottom).offset(27)
            $0.leading.equalTo(scrollView.snp.leading).offset(32)
        }
        addMenuButton.snp.makeConstraints {
            $0.top.equalTo(reviewMenuLabel.snp.bottom).offset(5)
            $0.leading.equalTo(scrollView.snp.leading).offset(24)
            $0.trailing.equalTo(scrollView.snp.centerX).offset(-2)
            $0.height.equalTo(46)
        }
        addMyselfButton.snp.makeConstraints {
            $0.top.equalTo(reviewMenuLabel.snp.bottom).offset(5)
            $0.leading.equalTo(scrollView.snp.centerX).offset(2)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-24)
            $0.height.equalTo(46)
        }
        submitReviewButton.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.height.equalTo(48)
            $0.bottom.equalTo(view.snp.bottom).offset(-20)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

