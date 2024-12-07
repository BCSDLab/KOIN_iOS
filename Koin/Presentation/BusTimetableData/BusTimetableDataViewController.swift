//
//  BusTimetableDataViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/5/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusTimetableDataViewController: CustomViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var inputSubject: PassthroughSubject<BusTimetableDataViewModel.Input, Never> = .init()
    private let viewModel: BusTimetableDataViewModel
    
    // MARK: - UI Components
    
    private var shuttleRouteTypeLabel = UILabel().then {
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
        $0.font = .appFont(.pretendardRegular, size: 11)
        $0.textAlignment = .center
        $0.text = "순환"
        $0.textColor = .appColor(.neutral0)
        $0.backgroundColor = .appColor(.fluorescentOrange)
    }
    
    private let busTimetablePlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 20)
        $0.textColor = .appColor(.neutral800)
        $0.text = "천안셔틀 주말 토, 일 노산"
        $0.textAlignment = .left
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
        configuration.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
        $0.configuration = configuration
    }
    
    private let busTimetableBorderView = UIView().then {
        $0.backgroundColor = .appColor(.neutral400)
    }
    
    private let busTimetableSeparateView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private let oneBusTimetableDataTableView = OneBusTimetableTableView(frame: .zero, style: .grouped)
    
    private let manyBusTimetableDataTableView = ManyBusTimetableTableView(frame: .zero, style: .grouped)
    
    private let manyBusTimetableDataCollectionView = ManyBusTimetableCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.collectionViewLayout = layout
    }
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let segmentControl = UISegmentedControl().then {
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.insertSegment(withTitle: "등교", at: 0, animated: true)
        $0.insertSegment(withTitle: "하교", at: 1, animated: true)
        $0.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500), NSAttributedString.Key.font: UIFont.appFont(.pretendardRegular, size: 16)], for: .normal)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardBold, size: 16)], for: .selected)
        $0.layer.masksToBounds = false
    }
    
    private let shadowView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral400)
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.02, x: 0, y: 1, blur: 1, spread: 0)
    }
    
    private let selectedUnderlineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
    }
    
    // MARK: - Initialization
    init(viewModel: BusTimetableDataViewModel) {
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
        setUpNavigationBar()
        setNavigationTitle(title: "천안셔틀 주말 시간표")
        scrollView.isHidden = true
        segmentControl.addTarget(self, action: #selector(changeSegmentControl), for: .valueChanged)
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            
        }.store(in: &subscriptions)
    }
  }

extension BusTimetableDataViewController {
    @objc private func changeSegmentControl(sender: UISegmentedControl) {
        moveUnderLineView()
    }
    
    private func moveUnderLineView() {
        let newXPosition = (segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)) * CGFloat(segmentControl.selectedSegmentIndex)
        selectedUnderlineView.snp.updateConstraints {
            $0.leading.equalTo(segmentControl).offset(newXPosition)
        }
        UIView.animate (
            withDuration: 0.4,
            animations: { [weak self] in
                guard let self = self
                else { return }
                self.view.layoutIfNeeded()
            }
        )
    }
}

extension BusTimetableDataViewController {
    private func setUpLayouts() {
        [navigationBarWrappedView, shuttleRouteTypeLabel, incorrectBusInfoButton, busTimetablePlaceLabel, scrollView, segmentControl, shadowView, selectedUnderlineView, oneBusTimetableDataTableView].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        [busTimetableBorderView, manyBusTimetableDataTableView, manyBusTimetableDataCollectionView, busTimetableSeparateView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(45)
        }
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(incorrectBusInfoButton.snp.bottom).offset(16)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1000)
        }
        shuttleRouteTypeLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBarWrappedView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(28)
            $0.height.equalTo(18)
        }
        busTimetablePlaceLabel.snp.makeConstraints {
            $0.leading.equalTo(shuttleRouteTypeLabel)
            $0.top.equalTo(shuttleRouteTypeLabel.snp.bottom).offset(4)
            $0.height.equalTo(32)
        }
        incorrectBusInfoButton.snp.makeConstraints {
            $0.leading.equalTo(shuttleRouteTypeLabel)
            $0.top.equalTo(busTimetablePlaceLabel.snp.bottom).offset(4)
            $0.height.equalTo(19)
        }
        oneBusTimetableDataTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(selectedUnderlineView.snp.bottom)
            $0.height.equalTo(500)
        }
        busTimetableBorderView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(1)
        }
        manyBusTimetableDataTableView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.width.equalTo(152)
            $0.top.equalTo(busTimetableBorderView.snp.bottom).offset(1)
        }
        manyBusTimetableDataCollectionView.snp.makeConstraints {
            $0.leading.equalTo(manyBusTimetableDataTableView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(busTimetableBorderView.snp.bottom).offset(1)
            $0.bottom.equalToSuperview()
        }
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(incorrectBusInfoButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        shadowView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(segmentControl.snp.bottom)
            $0.height.equalTo(1)
        }
        selectedUnderlineView.snp.makeConstraints {
            $0.leading.equalTo(segmentControl.snp.leading)
            $0.height.equalTo(2)
            $0.top.equalTo(segmentControl.snp.bottom)
            $0.width.equalTo(segmentControl.snp.width).dividedBy(segmentControl.numberOfSegments)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .systemBackground
    }
}

