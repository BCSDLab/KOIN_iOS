//
//  RadioButton.swift
//  koin
//
//  Created by 이은지 on 11/9/25.
//

import UIKit
import SnapKit

final class RadioButton: UIControl {
    
    // MARK: - Properties
    
    weak var group: RadioButtonGroup?
    
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            updateAppearance(animated: true)
            updateAccessibilityValue()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else { return }
            updateAppearance(animated: false)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            updateAppearance(animated: false)
        }
    }
    
    private var isHovered: Bool = false {
        didSet {
            guard oldValue != isHovered else { return }
            updateAppearance(animated: false)
        }
    }
    
    // MARK: - Constants
    
    private enum Metric {
        static let circleSize: CGFloat = 20
        static let innerCircleSize: CGFloat = 11.67
        static let focusRingSize: CGFloat = 28
        static let spacing: CGFloat = 12
    }
    
    private enum AnimationDuration {
        static let selection: TimeInterval = 0.2
        static let focus: TimeInterval = 0.15
    }
    
    // MARK: - UI Components
    
    private let focusRingView = UIView().then {
        $0.isUserInteractionEnabled = false
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.purple700.cgColor
        $0.alpha = 0
        $0.layer.cornerRadius = Metric.focusRingSize / 2
    }
    
    private let circleView = UIView().then {
        $0.isUserInteractionEnabled = false
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = Metric.circleSize / 2
    }
    
    private let innerCircleView = UIView().then {
        $0.isUserInteractionEnabled = false
        $0.alpha = 0
        $0.layer.cornerRadius = Metric.innerCircleSize / 2
    }
    
    private let radioButtonTitleLabel = UILabel().then {
        $0.font = .setFont(.body1)
        $0.textColor = .gray800
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - Initialize
    
    init(title: String) {
        super.init(frame: .zero)
        radioButtonTitleLabel.text = title
        configureView()
        setupGestures()
        setupAccessibility()
        updateAppearance(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Gesture Handling

extension RadioButton {
    
    private func setupGestures() {
        setupTapGesture()
        setupHoverGesture()
    }
    
    private func setupTapGesture() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc private func handleTap() {
        guard isEnabled, !isSelected else { return }
        
        if let group = group {
            group.selectRadioButton(self)
        } else {
            isSelected = true
        }
        
        sendActions(for: .valueChanged)
    }
    
    private func setupHoverGesture() {
        if #available(iOS 13.4, *) {
            let hoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
            addGestureRecognizer(hoverGesture)
        }
    }
    
    @available(iOS 13.4, *)
    @objc private func handleHover(_ gesture: UIHoverGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            isHovered = true
        case .ended, .cancelled:
            isHovered = false
        default:
            break
        }
    }
}

// MARK: - Focus Handling

extension RadioButton {
    
    override var canBecomeFocused: Bool {
        return isEnabled
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        coordinator.addCoordinatedAnimations { [weak self] in
            self?.updateAppearance(animated: false)
        }
    }
}

// MARK: - Accessibility

extension RadioButton {
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = radioButtonTitleLabel.text
        updateAccessibilityValue()
    }
    
    private func updateAccessibilityValue() {
        accessibilityValue = isSelected ? "선택됨" : "선택 안 됨"
    }
}

// MARK: - Appearance Update

extension RadioButton {
    
    private func updateAppearance(animated: Bool) {
        let state = getCurrentState()
        let colors = getColors(for: state)
        
        circleView.layer.borderColor = colors.border.cgColor
        innerCircleView.backgroundColor = colors.innerCircle
        
        let innerCircleAlpha: CGFloat = isSelected ? 1 : 0
        let focusRingAlpha: CGFloat = isFocused ? 1 : 0
        
        if animated {
            UIView.animate(
                withDuration: AnimationDuration.selection,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: { [weak self] in
                    self?.innerCircleView.alpha = innerCircleAlpha
                }
            )
            
            UIView.animate(
                withDuration: AnimationDuration.focus,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: { [weak self] in
                    self?.focusRingView.alpha = focusRingAlpha
                }
            )
        } else {
            innerCircleView.alpha = innerCircleAlpha
            focusRingView.alpha = focusRingAlpha
        }
    }
    
    private func getCurrentState() -> RadioButtonState {
        if !isEnabled {
            return isSelected ? .disabledSelected : .disabled
        } else if isFocused {
            return isSelected ? .focusSelected : .focus
        } else if isHighlighted {
            return isSelected ? .touchSelected : .touch
        } else if isHovered {
            return isSelected ? .hoverSelected : .hover
        } else if isSelected {
            return .selected
        } else {
            return .normal
        }
    }
    
    private func getColors(for state: RadioButtonState) -> RadioButtonColors {
        switch state {
        case .normal:
            return RadioButtonColors(
                border: .gray700,
                innerCircle: .clear
            )
        case .selected:
            return RadioButtonColors(
                border: .purple700,
                innerCircle: .purple700
            )
            
        case .hover:
            return RadioButtonColors(
                border: .gray600,
                innerCircle: .clear
            )
        case .hoverSelected:
            return RadioButtonColors(
                border: .purple600,
                innerCircle: .purple600
            )
            
        case .touch:
            return RadioButtonColors(
                border: .gray800,
                innerCircle: .clear
            )
        case .touchSelected:
            return RadioButtonColors(
                border: .purple800,
                innerCircle: .purple800
            )
            
        case .focus:
            return RadioButtonColors(
                border: .gray600,
                innerCircle: .clear
            )
        case .focusSelected:
            return RadioButtonColors(
                border: .purple600,
                innerCircle: .purple600
            )
            
        case .disabled:
            return RadioButtonColors(
                border: .gray400,
                innerCircle: .clear
            )
        case .disabledSelected:
            return RadioButtonColors(
                border: .gray400,
                innerCircle: .gray400
            )
        }
    }
}

// MARK: - UI Functions

extension RadioButton {
    
    private func setUpLayout() {
        [focusRingView, circleView, radioButtonTitleLabel].forEach {
            addSubview($0)
        }
        
        circleView.addSubview(innerCircleView)
    }
    
    private func setUpConstraints() {
        focusRingView.snp.makeConstraints {
            $0.center.equalTo(circleView)
            $0.size.equalTo(Metric.focusRingSize)
        }
        
        circleView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(Metric.circleSize)
        }
        
        innerCircleView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Metric.innerCircleSize)
        }
        
        radioButtonTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(circleView.snp.trailing).offset(Metric.spacing)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}
