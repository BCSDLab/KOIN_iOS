//
//  MinPriceSheetViewController.swift
//  koin
//
//  Created by 이은지 on 6/19/25.
//

import UIKit
import SnapKit

final class MinPriceSheetViewController: UIViewController {
    
    // MARK: - Properties
    var onOptionSelected: ((Int?) -> Void)?
    private var currentPrice: Int?
    private let priceSteps = [5000, 10000, 15000, 20000, 0]
    private var stepLabels: [UILabel] = []
    
    private var isLayoutConfigured = false

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
    
    private let thumbOverlayView = UIImageView()
    
    private let priceSlider = TrackPaddedSlider().then {
        $0.minimumValue = 0
        $0.maximumValue = 4
        $0.isContinuous = true
        $0.tintColor = UIColor.appColor(.new500)
    }
    
    private var dotViews: [UIView] = []
    private var dotCenterXConstraints: [NSLayoutConstraint] = []
    private let stepExtraInset: CGFloat = 8
    
    private let dotStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isLayoutConfigured && priceSlider.bounds != .zero {
            alignStacksToSliderTrack()
            isLayoutConfigured = true
        }
        layoutDotsToThumbCenters()
        layoutThumbOverlay()
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
    
    private func innerMetrics() -> (innerMinX: CGFloat, innerWidth: CGFloat, track: CGRect) {
        let track = priceSlider.trackRect(forBounds: priceSlider.bounds)
        let cap = track.height / 2
        let maxExtra = max(0, track.width/2 - cap - 1)
        let extra = min(stepExtraInset, maxExtra)

        let innerMinX = track.minX + cap + extra
        let innerWidth = track.width - 2 * (cap + extra)
        return (innerMinX, innerWidth, track)
    }
}

extension MinPriceSheetViewController {
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let step = round(sender.value)
        sender.setValue(step, animated: false)
        layoutDotsToThumbCenters()
        layoutThumbOverlay()
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
        [titleLabel, closeButton, seperateView1, priceSlider, dotStackView, stepStackView, confirmButton, seperateView2, thumbOverlayView].forEach {
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
            $0.centerY.equalTo(priceSlider.snp.centerY)
            $0.height.equalTo(8)
        }
        
        priceSlider.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(38)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(8)
        }
        
        stepStackView.snp.makeConstraints {
            $0.top.equalTo(priceSlider.snp.bottom).offset(24)
            $0.leading.equalTo(priceSlider.snp.leading).offset(14)
            $0.trailing.equalTo(priceSlider.snp.trailing).inset(20)
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
    
    private func alignStacksToSliderTrack() {
        let m = innerMetrics()

        dotStackView.snp.remakeConstraints {
            $0.leading.equalTo(priceSlider.snp.leading).offset(m.innerMinX)
            $0.trailing.equalTo(priceSlider.snp.leading).offset(m.innerMinX + m.innerWidth)
            $0.centerY.equalTo(priceSlider).offset(1)
            $0.height.equalTo(8)
        }

        stepStackView.snp.remakeConstraints {
            $0.leading.equalTo(dotStackView.snp.leading).offset(-18)
            $0.trailing.equalTo(dotStackView.snp.trailing).offset(12)
            $0.top.equalTo(priceSlider.snp.bottom).offset(24)
        }
    }

    private func setupSlider() {
        let initialStep: Float
        if let currentPrice = currentPrice, let index = priceSteps.firstIndex(of: currentPrice) {
            initialStep = Float(index)
        } else {
            initialStep = 0
        }
        priceSlider.setValue(initialStep, animated: false)

        let minTrackImage = imageWithColor(color: UIColor.appColor(.new500))
        let maxTrackImage = imageWithColor(color: UIColor.appColor(.neutral200))
        priceSlider.setMinimumTrackImage(minTrackImage, for: .normal)
        priceSlider.setMaximumTrackImage(maxTrackImage, for: .normal)

        let transparentThumb = imageWithColor(color: .clear, size: CGSize(width: 1, height: 1))
        priceSlider.setThumbImage(transparentThumb, for: .normal)
        priceSlider.setThumbImage(transparentThumb, for: .highlighted)

        if let img = UIImage.appImage(asset: .bcsdSymbolLogo) {
            thumbOverlayView.image = img
            thumbOverlayView.frame.size = img.size
        }

        view.bringSubviewToFront(thumbOverlayView)
        view.layoutIfNeeded()
        layoutDotsToThumbCenters()
        layoutThumbOverlay()
    }

    private func layoutThumbOverlay() {
        guard !priceSlider.bounds.isEmpty else { return }

        let m = innerMetrics()
        let last = max(priceSteps.count - 1, 1)
        let step = CGFloat(round(priceSlider.value))
        let t = step / CGFloat(last)
        let xInSlider = m.innerMinX + t * m.innerWidth

        let thumbRectY = priceSlider.thumbRect(forBounds: priceSlider.bounds,
                                               trackRect: m.track,
                                               value: priceSlider.value)
        let centerInSlider = CGPoint(x: xInSlider, y: thumbRectY.midY)
        let centerInView = priceSlider.convert(centerInSlider, to: view)
        thumbOverlayView.center = centerInView
    }
    
    private func setupDots() {
        dotViews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()
        dotCenterXConstraints.removeAll()

        let dotCount = priceSteps.count
        for _ in 0..<dotCount {
            let dot = UIView()
            dot.backgroundColor = .white
            dot.layer.cornerRadius = 2
            dot.translatesAutoresizingMaskIntoConstraints = false
            dotStackView.addSubview(dot)
            
            let w = dot.widthAnchor.constraint(equalToConstant: 4)
            let h = dot.heightAnchor.constraint(equalToConstant: 4)
            let cy = dot.centerYAnchor.constraint(equalTo: dotStackView.centerYAnchor, constant: 0)
            let cx = dot.centerXAnchor.constraint(equalTo: dotStackView.leadingAnchor, constant: 0)
            
            NSLayoutConstraint.activate([w, h, cy, cx])
            dotViews.append(dot)
            dotCenterXConstraints.append(cx)
        }
    }
    
    private func layoutDotsToThumbCenters() {
        guard priceSteps.count == dotViews.count,
              !dotStackView.bounds.isEmpty,
              !priceSlider.bounds.isEmpty else { return }

        let m = innerMetrics()
        let last = max(dotViews.count - 1, 1)

        for (idx, cx) in dotCenterXConstraints.enumerated() {
            let t = CGFloat(idx) / CGFloat(last)
            cx.constant = t * m.innerWidth
        }
        dotStackView.layoutIfNeeded()
    }


    private func imageWithColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 8)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    private func configureView() {
        view.backgroundColor = .white
        setUpLayOuts()
        setUpConstraints()
        setupSlider()
        setupDots()
        dotStackView.isUserInteractionEnabled = false
        thumbOverlayView.isUserInteractionEnabled = false
    }
}
