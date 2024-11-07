//
//  BusTimetableViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/03/30.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusTimetableViewController: CustomViewController {
    
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    private var inputSubject: PassthroughSubject<BusTimetableViewModel.Input, Never> = .init()
    private let viewModel: BusTimetableViewModel
    
    // MARK: - UI Components
    private let timetableHeaderView = UIView()
    
    private let typeOftimetableLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 20)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.text = "셔틀버스 시간표"
    }
    
    private let incorrectBusInfoButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .incorrectInfo)
        let title = AttributedString("정보가 정확하지 않나요?", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.neutral500)
        ]))
        configuration.attributedTitle = title
        configuration.imagePadding = 4
        $0.configuration = configuration
    }
    
    private let busNoticeWrappedView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.info100)
        $0.layer.cornerRadius = 8
    }
    
    private let busNoticeLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingTail 
        $0.text = "[긴급] 9.27(금) 대학등교방향 천안셔틀버스 터미널"
    }
    
    private let deleteNoticeButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .delete), for: .normal)
    }
    
    private let busTypeSegmentControl = UISegmentedControl().then {
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.insertSegment(withTitle: "셔틀", at: 0, animated: true)
        $0.insertSegment(withTitle: "대성", at: 1, animated: true)
        $0.insertSegment(withTitle: "시내", at: 2, animated: true)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500), NSAttributedString.Key.font: UIFont.appFont(.pretendardRegular, size: 16)], for: .normal)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardBold, size: 16)], for: .selected)
    }

    
    // MARK: - Initialization
    init(viewModel: BusTimetableViewModel) {
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
        setNavigationTitle(title: "버스 시간표")
        setUpNavigationBar()
    }
    
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
    }
    
   
}

extension BusTimetableViewController {
    private func setUpLayouts() {
        view.addSubview(navigationBarWrappedView)
        view.addSubview(timetableHeaderView)
        [typeOftimetableLabel, incorrectBusInfoButton, busNoticeWrappedView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(95)
        }
        
        timetableHeaderView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationBarWrappedView.snp.bottom)
            $0.height.equalTo(139)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .systemBackground
    }
}