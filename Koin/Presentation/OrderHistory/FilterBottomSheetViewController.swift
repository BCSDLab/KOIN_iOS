//
//  FilterBottomSheetViewController.swift
//  koin
//
//  Created by 김성민 on 9/6/25.
//

import UIKit
import SnapKit

final class FilterBottomSheetViewController: UIViewController {

    var initial: OrderFilter
    var onApply: ((OrderFilter) -> Void)?
    
    private var work: OrderFilter
    
    private let backdrop = UIControl()
    private let container = UIView()
    private var bottomConstraint: Constraint!
    
    private let body = UIStackView()
    private let bottomBar = UIStackView()
        
    private let m3Button = FilteringButton()
    private let m6Button = FilteringButton()
    private let y1Button = FilteringButton()
    private let deliveryButton = FilteringButton()
    private let takeoutButton = FilteringButton()
    private let doneButton = FilteringButton()
    private let cancelButton = FilteringButton()
    
    private let periodRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .leading
        row.distribution = .fill
        row.spacing = 12
        return row
    }()
    
    private let stateRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .leading
        row.distribution = .fill
        row.spacing = 12
        return row
    }()
    
    private let infoRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .leading
        row.distribution = .fill
        row.spacing = 12
        return row
    }()
    
    
    private let filterUnderLineView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appColor(.neutral300)
        return v
    }()
    
    private let periodUnderLineView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appColor(.neutral300)
        return v
    }()
    
    private let containerUnderLineView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appColor(.neutral300)
        return v
    }()
    
    private let resetButton: UIButton = {
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

        let b = UIButton(configuration: config)
        return b
    }()
    
    private let applyButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "적용하기"
        config.baseForegroundColor = UIColor.appColor(.neutral0)
        config.baseBackgroundColor = UIColor.appColor(.new500)
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 80, bottom: 11, trailing: 80)

        let b = UIButton(configuration: config)
        b.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 16)
        return b
    }()
    
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        let icon = UIImage.appImage(asset: .delete)
        b.setImage(icon, for: .normal)
        b.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 24, weight: .bold),
            forImageIn: .normal
        )
        
        b.tintColor = UIColor.appColor(.neutral800)
        b.backgroundColor = .clear
        return b
    }()
    
    private let periodLabel: UILabel = {
        let l = UILabel()
        l.text = "조회 기간"
        l.font = UIFont.appFont(.pretendardBold, size: 16)
        l.textColor = UIColor.appColor(.neutral600)
        return l
    }()
    
    private let stateLabel: UILabel = {
        let l = UILabel()
        l.text = "주문 상태"
        l.font = UIFont.appFont(.pretendardBold, size: 16)
        l.textColor = UIColor.appColor(.neutral600)
        return l
    }()
    
    private let infoLabel: UILabel = {
        let l = UILabel()
        l.text = "주문 정보"
        l.font = UIFont.appFont(.pretendardBold, size: 16)
        l.textColor = UIColor.appColor(.neutral600)
        return l
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "필터"
        l.font = UIFont.appFont(.pretendardBold, size: 18)
        l.textColor = UIColor.appColor(.new500)
        return l
    }()
    
    init(initial: OrderFilter) {
        self.initial = initial
        self.work = initial
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatePresent()
    }
    
    private func configureButtons(){
        m3Button.setTitle("최근 3개월")
        m6Button.setTitle("최근 6개월")
        y1Button.setTitle("최근 1년")
        deliveryButton.setTitle("배달")
        takeoutButton.setTitle("포장")
        doneButton.setTitle("완료")
        cancelButton.setTitle("취소")

        [m3Button, m6Button, y1Button,deliveryButton, takeoutButton, doneButton, cancelButton].forEach {
                $0.applyFilter(false)
                changeSheetInButton($0)
            }
    }
    
    
    private func setUpLayOuts(){
        [backdrop, container].forEach {
            view.addSubview($0)
        }
        backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        container.backgroundColor = UIColor.appColor(.newBackground)
        container.layer.cornerRadius = 32
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        [titleLabel,periodLabel,infoLabel,stateLabel,filterUnderLineView,periodUnderLineView,periodRow,stateRow,infoRow, resetButton, applyButton ,containerUnderLineView, closeButton].forEach {
            container.addSubview($0)
        }
        
        
        [m3Button, m6Button, y1Button].forEach{
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
        container.snp.makeConstraints {
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
            $0.bottom.equalTo(container.safeAreaLayoutGuide)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        configureButtons()
        view.backgroundColor = .clear
        container.backgroundColor = UIColor.appColor(.neutral0)
        bind()
    }
    
    private func bind() {
        [m3Button, m6Button, y1Button].forEach {
            $0.addTarget(self, action: #selector(periodTapped(_:)), for: .touchUpInside)
        }
        [deliveryButton, takeoutButton].forEach {
            $0.addTarget(self, action: #selector(methodTapped(_:)), for: .touchUpInside)
        }
        [doneButton, cancelButton].forEach {
            $0.addTarget(self, action: #selector(infoTapped(_:)), for: .touchUpInside)
        }

        [m3Button, m6Button, y1Button,
         deliveryButton, takeoutButton, doneButton, cancelButton].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        backdrop.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        
        render()
    }
    
    private func render() {
        m3Button.applyFilter(work.period == .m3)
        m6Button.applyFilter(work.period == .m6)
        y1Button.applyFilter(work.period == .y1)

        deliveryButton.applyFilter(work.method == .delivery)
        takeoutButton.applyFilter(work.method == .takeout)

        doneButton.applyFilter(work.info.contains(.completed))
        cancelButton.applyFilter(work.info.contains(.canceled))
    }
    
    
    //MARK: -Button
    
    @objc private func closeTapped() {
        animateDismiss()
    }
    
    @objc private func resetTapped() {
        work = .empty
        render()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func applyTapped() {
        onApply?(work)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        animateDismiss()
    }
    
    @objc private func periodTapped(_ sender: FilteringButton) {
        let cur = work.period
        if sender === m3Button { work.period = (cur == .m3) ? nil : .m3 }
        if sender === m6Button { work.period = (cur == .m6) ? nil : .m6 }
        if sender === y1Button { work.period = (cur == .y1) ? nil : .y1 }
        render()
    }
    
    @objc private func methodTapped(_ sender: FilteringButton) {
        let cur = work.method
        if sender === deliveryButton { work.method = (cur == .delivery) ? nil : .delivery }
        if sender === takeoutButton  { work.method = (cur == .takeout)  ? nil : .takeout  }
        render()
    }
    
    @objc private func infoTapped(_ sender: FilteringButton) {
        if sender === doneButton {
            work.info.formSymmetricDifference(.completed)
        } else {
            work.info.formSymmetricDifference(.canceled)
        }
        render()
    }
    
    private func animatePresent() {
        view.layoutIfNeeded()
        bottomConstraint.update(offset: 0)
        let d: TimeInterval = UIAccessibility.isReduceMotionEnabled ? 0.0 : 0.22
        UIView.animate(withDuration: d, delay: 0, options: [.curveEaseOut]) {
            self.backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateDismiss() {
        bottomConstraint.update(offset: 320)
        let d: TimeInterval = UIAccessibility.isReduceMotionEnabled ? 0.0 : 0.20
        UIView.animate(withDuration: d, delay: 0, options: [.curveEaseIn]) {
            self.backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    private func changeSheetInButton(_ b: FilteringButton) {
        var config = b.configuration ?? .plain()
        config.image = nil
        config.imagePadding = 0
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8, leading: 12, bottom: 8, trailing: 12
        )
        b.configuration = config

        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
}
