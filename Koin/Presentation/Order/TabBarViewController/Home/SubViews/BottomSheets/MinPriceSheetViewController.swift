

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
    
    private let dotStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
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
    }
    
    private func addTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        priceSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    private func createStepLabels() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        for price in priceSteps {
            let label = UILabel()
            if price == 0 {
                label.text = "전체"
            } else {
                label.text = formatter.string(from: NSNumber(value: price))
            }
            label.font = UIFont.appFont(.pretendardMedium, size: 14)
            label.textColor = .black
            label.textAlignment = .center
            stepLabels.append(label)
            stepStackView.addArrangedSubview(label)
        }
    }
}

extension MinPriceSheetViewController {
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let step = round(sender.value)
        sender.setValue(step, animated: false)
    }
    
    @objc private func confirmButtonTapped() {
        let step = Int(round(priceSlider.value))
        guard priceSteps.indices.contains(step) else { return }
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

extension MinPriceSheetViewController {
    private func setUpLayOuts() {
        [titleLabel, closeButton, seperateView1, dotStackView, priceSlider, stepStackView, confirmButton, seperateView2].forEach {
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
            $0.height.equalTo(0.5)
        }
        
        dotStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(priceSlider)
            $0.centerY.equalTo(priceSlider)
        }
        
        priceSlider.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(38)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(8)
        }
        
        stepStackView.snp.makeConstraints {
            $0.top.equalTo(priceSlider.snp.bottom).offset(24)
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
            $0.height.equalTo(0.5)
        }
    }
    
    // Slider UI
    private func setupSlider() {
        let initialStep: Float
        if let currentPrice = currentPrice, let index = priceSteps.firstIndex(of: currentPrice) {
            initialStep = Float(index)
        } else {
            initialStep = 0
        }
        priceSlider.setValue(initialStep, animated: false)

        let minTrackImage = roundedImageWithColor(color: UIColor.appColor(.new500))
        let maxTrackImage = roundedImageWithColor(color: UIColor.appColor(.neutral200))
        priceSlider.setMinimumTrackImage(minTrackImage, for: .normal)
        priceSlider.setMaximumTrackImage(maxTrackImage, for: .normal)
        let customThumbImage = UIImage.appImage(asset: .bcsdSymbolLogo)
        priceSlider.setThumbImage(customThumbImage, for: .normal)
    }
    
    private func setupDots() {
        dotStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let dotCount = priceSteps.count
        for _ in 0..<dotCount {
            let dot = UIView()
            dot.backgroundColor = .white
            dot.layer.cornerRadius = 2
            dot.snp.makeConstraints { $0.size.equalTo(4) }
            dotStackView.addArrangedSubview(dot)
        }
    }
    
    private func roundedImageWithColor(color: UIColor, size: CGSize = CGSize(width: 8, height: 8)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setupSlider()
        setupDots()
        view.backgroundColor = .white
    }
}


