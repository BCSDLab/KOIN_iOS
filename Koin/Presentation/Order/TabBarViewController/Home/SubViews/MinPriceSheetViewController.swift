

import UIKit
import SnapKit

final class MinPriceSheetViewController: UIViewController {
    
    // MARK: - Properties
    var onOptionSelected: ((Int?) -> Void)?
    private var currentPrice: Int?
    private let priceSteps = [5000, 10000, 15000, 20000, 0]
    private var stepLabels: [UILabel] = []

    // MARK: UI Component
    private let titleLabel = UILabel().then {
        $0.text = "최소주문금액"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = UIColor.appColor(.new500)
    }
    
    private let closeButton = UIButton(type: .system).then {
        let img = UIImage.appImage(asset: .cancel)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(img, for: .normal)
        $0.tintColor = .black
    }
    
    private let seperateView1 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let priceSlider = UISlider().then {
        $0.minimumValue = 0
        $0.maximumValue = 4
        $0.isContinuous = true
        $0.tintColor = UIColor.appColor(.new500)
    }
    
    private let stepStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private let confirmButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.filled()
        var titleAttr = AttributedString("적용하기")
        titleAttr.font = UIFont.appFont(.pretendardBold, size: 18)
        config.attributedTitle = titleAttr
        config.baseBackgroundColor = UIColor.appColor(.new500)
        config.baseForegroundColor = .white
        config.background.cornerRadius = 12
        $0.configuration = config
    }
    
    private let seperateView2 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
        
    // MARK: Lifecycle
    init(current: Int?) {
        self.currentPrice = current
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addTargets()
        createStepLabels()
        setupSlider()
        updateStepLabels(value: priceSlider.value)
    }
    
    private func setupSlider() {
        let initialStep: Float
        if let currentPrice = currentPrice, let index = priceSteps.firstIndex(of: currentPrice) {
            initialStep = Float(index)
        } else {
            initialStep = 0 // "전체"
        }
        priceSlider.setValue(initialStep, animated: false)
    }
    
    private func addTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        priceSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    private func createStepLabels() {
        for price in priceSteps {
            let label = UILabel()
            if price == 0 {
                label.text = "전체"
            } else {
                label.text = "\(price)"
            }
            label.font = UIFont.appFont(.pretendardRegular, size: 14)
            label.textColor = UIColor.appColor(.neutral400)
            label.textAlignment = .center
            stepLabels.append(label)
            stepStackView.addArrangedSubview(label)
        }
    }
    
    private func updateStepLabels(value: Float) {
        let step = Int(round(value))
        
        for (index, label) in stepLabels.enumerated() {
            if index == step {
                label.font = UIFont.appFont(.pretendardBold, size: 16)
                label.textColor = UIColor.appColor(.neutral800)
            } else {
                label.font = UIFont.appFont(.pretendardRegular, size: 14)
                label.textColor = UIColor.appColor(.neutral400)
            }
        }
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        updateStepLabels(value: sender.value)
    }
    
    @objc private func confirmButtonTapped() {
        let step = Int(round(priceSlider.value))
        let price = priceSteps[step]
        let selectedValue = (price == 0) ? nil : price
        
        dismiss(animated: true) {
            self.onOptionSelected?(selectedValue)
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

private extension MinPriceSheetViewController {
    private func setUpLayOuts() {
        [titleLabel, closeButton, seperateView1, priceSlider, stepStackView, confirmButton, seperateView2].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(29)
        }
        
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.trailing.equalToSuperview().inset(14.5)
            $0.centerY.equalTo(titleLabel)
        }
        
        seperateView1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        priceSlider.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(38)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        
        stepStackView.snp.makeConstraints {
            $0.top.equalTo(priceSlider.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(priceSlider)
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(49)
        }
        
        seperateView2.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = .white
    }
}


