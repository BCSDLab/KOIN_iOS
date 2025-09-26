//
//  FilterBottomSheetViewController.swift
//  koin
//
//  Created by 김성민 on 9/6/25.
//

import UIKit
import SnapKit
import Combine

final class FilterBottomSheetViewController: UIViewController {
    
    //MARK: - properties
    
    private var bottomConstraint: Constraint!
    var onApply: ((OrderHistoryQuery) -> Void)?
    private let viewModel: FilterBottomSheetViewModel
    private let inputSubject = PassthroughSubject<FilterBottomSheetViewModel.Input, Never>()
    private var subscription = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let backdrop = UIControl()
    private let filterButtonContainer = UIView()
    private let threeMonthButton = FilteringButton()
    private let sixMonthButton = FilteringButton()
    private let oneYearButton = FilteringButton()
    private let deliveryButton = FilteringButton()
    private let takeoutButton = FilteringButton()
    private let doneButton = FilteringButton()
    private let cancelButton = FilteringButton()
    
    private let periodRow = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 12
    }
    
    private let stateRow = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 12
    }
    
    private let infoRow = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 12
    }
    
    private let filterUnderLineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let periodUnderLineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let containerUnderLineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let resetButton = UIButton(configuration: {
        var config = UIButton.Configuration.plain()
        config.title = "초기화"
        config.baseForegroundColor = UIColor.appColor(.neutral500)
        config.attributedTitle?.font = UIFont.appFont(.pretendardBold, size: 16)
        
        let icon = UIImage.appImage(asset: .refresh)
        config.image = icon
        config.imagePlacement = .trailing
        config.imagePadding = 8
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16)
        config.background.strokeColor = UIColor.appColor(.neutral400)
        config.background.strokeWidth = 1
        config.background.cornerRadius = 12
        return config
    }())
    
    private let applyButton = UIButton(configuration: {
        var config = UIButton.Configuration.filled()
        config.title = "적용하기"
        config.attributedTitle?.font = UIFont.appFont(.pretendardBold, size: 16)
        config.baseForegroundColor = UIColor.appColor(.neutral0)
        
        config.baseBackgroundColor = UIColor.appColor(.new500)
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 80, bottom: 11, trailing: 80)
        
        return config
    }()).then {
        $0.titleLabel?.numberOfLines = 1
    }
    
    private let closeButton = UIButton(type: .system).then {
        let icon = UIImage.appImage(asset: .delete)
        $0.setImage(icon, for: .normal)
        $0.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 24, weight: .bold),
            forImageIn: .normal
        )
        $0.tintColor = UIColor.appColor(.neutral800)
        $0.backgroundColor = .clear
    }
    
    private let periodLabel = UILabel().then {
        $0.text = "조회 기간"
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    private let stateLabel = UILabel().then {
        $0.text = "주문 상태"
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "주문 정보"
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "필터"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = UIColor.appColor(.new500)
    }
    
    // MARK: - Initialize
    
    init(initialQuery: OrderHistoryQuery) {
        self.viewModel = FilterBottomSheetViewModel(initial: initialQuery)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatePresent()
    }
    
    // MARK: - UI Function
    
    private func configureButtons(){
        threeMonthButton.setTitle("최근 3개월")
        sixMonthButton.setTitle("최근 6개월")
        oneYearButton.setTitle("최근 1년")
        deliveryButton.setTitle("배달")
        takeoutButton.setTitle("포장")
        doneButton.setTitle("완료")
        cancelButton.setTitle("취소")
        
        [threeMonthButton, sixMonthButton, oneYearButton,deliveryButton, takeoutButton, doneButton, cancelButton].forEach {
            $0.applyFilter(false)
            changeSheetInButton($0)
        }
    }
    
    private func setUpLayOuts(){
        [backdrop, filterButtonContainer].forEach {
            view.addSubview($0)
        }
        backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        filterButtonContainer.backgroundColor = UIColor.appColor(.newBackground)
        filterButtonContainer.layer.cornerRadius = 32
        filterButtonContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        [titleLabel,periodLabel,infoLabel,stateLabel,filterUnderLineView,periodUnderLineView,periodRow,stateRow,infoRow, resetButton, applyButton ,containerUnderLineView, closeButton].forEach {
            filterButtonContainer.addSubview($0)
        }
        
        
        [threeMonthButton, sixMonthButton, oneYearButton].forEach{
            periodRow.addArrangedSubview($0)
        }
        
        [deliveryButton, takeoutButton].forEach{
            stateRow.addArrangedSubview($0)
        }
        
        [doneButton, cancelButton].forEach{
            infoRow.addArrangedSubview($0)
        }
        
    }
    
    private func setUpConstraints(){
        backdrop.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        filterButtonContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            bottomConstraint = $0.bottom.equalTo(view.snp.bottom).offset(320).constraint
            $0.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.7)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.top.equalToSuperview().offset(12)
        }
        
        closeButton.snp.makeConstraints{
            $0.centerY.equalTo(titleLabel)
            $0.height.width.equalTo(40)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        filterUnderLineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.height.equalTo(1)
        }
        
        periodLabel.snp.makeConstraints{
            $0.top.equalTo(filterUnderLineView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(32)
        }
        
        periodRow.snp.makeConstraints {
            $0.leading.equalTo(periodLabel.snp.leading)
            $0.top.equalTo(periodLabel.snp.bottom).offset(12)
            $0.height.equalTo(34)
        }
        
        periodUnderLineView.snp.makeConstraints {
            $0.top.equalTo(periodRow.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(1)
        }
        
        stateLabel.snp.makeConstraints {
            $0.top.equalTo(periodUnderLineView.snp.bottom).offset(24)
            $0.leading.equalTo(periodLabel.snp.leading)
        }
        
        stateRow.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(12)
            $0.leading.equalTo(stateLabel.snp.leading)
            $0.height.equalTo(34)
        }
        
        infoLabel.snp.makeConstraints{
            $0.top.equalTo(stateRow.snp.bottom).offset(16)
            $0.leading.equalTo(periodLabel.snp.leading)
        }
        
        infoRow.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(12)
            $0.leading.equalTo(infoLabel.snp.leading)
            $0.height.equalTo(34)
        }
        
        resetButton.snp.makeConstraints {
            $0.leading.equalTo(periodLabel.snp.leading)
            $0.top.equalTo(infoRow.snp.bottom).offset(32)
            $0.height.equalTo(48)
        }
        
        applyButton.snp.makeConstraints{
            $0.leading.equalTo(resetButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(32)
            $0.top.equalTo(resetButton.snp.top)
            $0.height.equalTo(48)
            
        }
        
        containerUnderLineView.snp.makeConstraints {
            $0.top.equalTo(resetButton.snp.bottom).offset(12)
            $0.bottom.equalTo(filterButtonContainer.safeAreaLayoutGuide)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        configureButtons()
        view.backgroundColor = .clear
        filterButtonContainer.backgroundColor = UIColor.appColor(.neutral0)
        setAddTarget()
        bind()
        
    }
    
    //MARK: - Bind
    
    private func bind() {
        let output = viewModel.transform(inputSubject.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] output in
                guard let self else {return}
                switch output {
                case .render(let state):
                    self.render(state: state)
                case .applied(let query):
                    self.onApply?(query)
                case .dismiss:
                    self.animateDismiss()
                }
            }
            .store(in: &subscription)        
    }
    
    
    private func setAddTarget() {
        [threeMonthButton, sixMonthButton, oneYearButton].forEach {
            $0.addTarget(self, action: #selector(periodTapped(_:)), for: .touchUpInside)
        }
        [deliveryButton, takeoutButton].forEach {
            $0.addTarget(self, action: #selector(methodTapped(_:)), for: .touchUpInside)
        }
        [doneButton, cancelButton].forEach {
            $0.addTarget(self, action: #selector(infoTapped(_:)), for: .touchUpInside)
        }
        
        // 3개월, 6개월 , 1년
        [threeMonthButton, sixMonthButton, oneYearButton,
         deliveryButton, takeoutButton, doneButton, cancelButton].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        backdrop.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    // MARK: - Function
    
    private func render(state: FilterBottomSheetViewModel.State) {
        threeMonthButton.applyFilter(state.period == .last3Months)
        sixMonthButton.applyFilter(state.period == .last6Months)
        oneYearButton.applyFilter(state.period == .last1Year)
    
        deliveryButton.applyFilter(state.type == .delivery)
        takeoutButton.applyFilter(state.type == .takeout)
        
        doneButton.applyFilter(state.status == .completed)
        cancelButton.applyFilter(state.status == .canceled)

    }
    
    //MARK: - @objc
    
    @objc private func closeTapped() {
        inputSubject.send(.close)
    }
    
    @objc private func resetTapped() {
        inputSubject.send(.reset)

    }
    
    @objc private func applyTapped() {
        inputSubject.send(.apply)
    }
    
    @objc private func periodTapped(_ sender: FilteringButton) {
        if sender === threeMonthButton { inputSubject.send(.togglePeriod(.last3Months)) }
        if sender === sixMonthButton   { inputSubject.send(.togglePeriod(.last6Months)) }
        if sender === oneYearButton    { inputSubject.send(.togglePeriod(.last1Year)) }
    }
    
    @objc private func methodTapped(_ sender: FilteringButton) {
        if sender === deliveryButton { inputSubject.send(.toggleType(.delivery)) }
        if sender === takeoutButton  { inputSubject.send(.toggleType(.takeout)) }
    }
    
    @objc private func infoTapped(_ sender: FilteringButton) {
        if sender === doneButton   { inputSubject.send(.toggleStatus(.completed)) }
        if sender === cancelButton { inputSubject.send(.toggleStatus(.canceled)) }
    }
}

extension FilterBottomSheetViewController {
    
    private func animatePresent() {
        view.layoutIfNeeded()
        bottomConstraint.update(offset: 0)
        let dismiss: TimeInterval = UIAccessibility.isReduceMotionEnabled ? 0.0 : 0.22
        UIView.animate(withDuration: dismiss, delay: 0, options: [.curveEaseOut]) {
            self.backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateDismiss() {
        bottomConstraint.update(offset: 320)
        let dismiss: TimeInterval = UIAccessibility.isReduceMotionEnabled ? 0.0 : 0.20
        UIView.animate(withDuration: dismiss, delay: 0, options: [.curveEaseIn]) {
            self.backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    private func changeSheetInButton(_ button: FilteringButton) {
        var config = button.configuration ?? .plain()
        config.image = nil
        config.imagePadding = 0
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8, leading: 12, bottom: 8, trailing: 12
        )
        button.configuration = config
        
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
}
