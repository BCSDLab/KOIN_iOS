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

final class BusTimetableViewController: CustomViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var inputSubject: PassthroughSubject<BusTimetableViewModel.Input, Never> = .init()
    private let viewModel: BusTimetableViewModel
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
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
        configuration.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
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
    
    private let busTimetableRouteView = BusTimetableRouteView()
    
    private let expressOrCityTimetableTableView = ExpressOrCityTimetableTableView(frame: .zero, style: .grouped)
    
    private let shuttleTimetableTableView = ShuttleTimetableTableView(frame: .zero, style: .grouped)
    
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
        busTypeSegmentControl.selectedSegmentIndex = 0
        busTypeSegmentControl.addTarget(self, action: #selector(changeSegmentControl), for: .valueChanged)
        scrollView.delegate = self
        bind()
        inputSubject.send(.getBusRoute(.shuttleBus))
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .updateBusRoute(busType: busType, firstBusRoute: firstBusRoute, secondBusRoute: secondBusRoute):
                self?.updateBusRoute(busType: busType, firstBusRoute: firstBusRoute, secondBusRoute: secondBusRoute)
            }
        }.store(in: &subscriptions)
        
        busTimetableRouteView.busRouteContentHeightPublisher.sink { [weak self] height in
            DispatchQueue.main.async { [weak self] in
                self?.busTimetableRouteView.snp.updateConstraints {
                    $0.height.equalTo(height)
                }
            }
        }.store(in: &subscriptions)
        
        shuttleTimetableTableView.moveDetailTimetablePublisher.sink { [weak self] in
            let viewController = BusTimetableDataViewController(viewModel: BusTimetableDataViewModel())
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
    }
    
    @objc private func changeSegmentControl(sender: UISegmentedControl) {
        moveUnderLineView()
        let busType: BusType
        switch sender.selectedSegmentIndex {
        case 0:
            busType = .shuttleBus
        case 1:
            busType = .expressBus
        default:
            busType = .cityBus
        }
        inputSubject.send(.getBusRoute(busType))
    }
    
    private func moveUnderLineView() {
        let newXPosition = (busTypeSegmentControl.frame.width / CGFloat(busTypeSegmentControl.numberOfSegments)) * CGFloat(busTypeSegmentControl.selectedSegmentIndex)
        selectedUnderlineView.snp.updateConstraints {
            $0.leading.equalTo(busTypeSegmentControl).offset(newXPosition)
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
    
    private func updateBusRoute(busType: BusType, firstBusRoute: [String], secondBusRoute: [String]?) {
        busTimetableRouteView.setBusType(busType: busType, firstRouteList: firstBusRoute, secondRouteList: secondBusRoute)
        if busType == .shuttleBus {
            shuttleTimetableTableView.isHidden = false
            expressOrCityTimetableTableView.isHidden = true
            typeOftimetableLabel.text = "셔틀버스 시간표"
        }
        else {
            if busType == .expressBus {
                typeOftimetableLabel.text = "대성고속 시간표"
            }
            else {
                typeOftimetableLabel.text = "시내버스 시간표"
            }
            shuttleTimetableTableView.isHidden = true
            expressOrCityTimetableTableView.isHidden = false
        }
    }
}

extension BusTimetableViewController {
    private func setUpLayouts() {
        [navigationBarWrappedView, scrollView].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        [timetableHeaderView, shadowView, selectedUnderlineView, busTypeSegmentControl, busTimetableRouteView, expressOrCityTimetableTableView, shuttleTimetableTableView].forEach {
            contentView.addSubview($0)
        }
        [typeOftimetableLabel, incorrectBusInfoButton, busNoticeWrappedView].forEach {
            timetableHeaderView.addSubview($0)
        }
        [busNoticeLabel, deleteNoticeButton].forEach {
            busNoticeWrappedView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBarWrappedView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1000).priority(.low)
        }
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(45)
        }
        timetableHeaderView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(139)
        }
        typeOftimetableLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalTo(24)
            $0.height.equalTo(32)
        }
        incorrectBusInfoButton.snp.makeConstraints {
            $0.leading.equalTo(typeOftimetableLabel)
            $0.top.equalTo(typeOftimetableLabel.snp.bottom).offset(8)
        }
        busNoticeWrappedView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(incorrectBusInfoButton.snp.bottom).offset(8)
            $0.height.equalTo(56)
        }
        busNoticeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(40)
        }
        deleteNoticeButton.snp.makeConstraints {
            $0.centerY.equalTo(busNoticeLabel)
            $0.leading.equalTo(busNoticeLabel.snp.trailing)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        busTypeSegmentControl.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(timetableHeaderView.snp.bottom)
            $0.height.equalTo(50)
        }
        shadowView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(busTypeSegmentControl.snp.bottom)
            $0.height.equalTo(1)
        }
        selectedUnderlineView.snp.makeConstraints {
            $0.leading.equalTo(busTypeSegmentControl.snp.leading)
            $0.height.equalTo(2)
            $0.top.equalTo(busTypeSegmentControl.snp.bottom)
            $0.width.equalTo(busTypeSegmentControl.snp.width).dividedBy(busTypeSegmentControl.numberOfSegments)
        }
        busTimetableRouteView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(selectedUnderlineView.snp.bottom)
            $0.height.equalTo(62)
        }
        expressOrCityTimetableTableView.snp.makeConstraints {
            $0.top.equalTo(busTimetableRouteView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        shuttleTimetableTableView.snp.makeConstraints {
            $0.top.equalTo(busTimetableRouteView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .systemBackground
    }
}
