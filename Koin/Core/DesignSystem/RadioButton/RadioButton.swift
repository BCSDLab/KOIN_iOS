//
//  RadioButton.swift
//  koin
//
//  Created by 이은지 on 11/9/25.
//

import UIKit

final class RadioButton: UIControl {
    
    // MARK: - State
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    var isEmphasized: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    private var isHovered: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - UI Components
    private let focusRingView = UIView()
    private let circleView = UIView()
    private let innerCircleView = UIView()
    private let label = UILabel()
    
    // MARK: - Constants
    private enum Metric {
        static let circleSize: CGFloat = 24
        static let innerCircleSize: CGFloat = 12
        static let focusRingSize: CGFloat = 28
        static let spacing: CGFloat = 8
    }
    
    // MARK: - Initialization
    init(title: String) {
        super.init(frame: .zero)
        label.text = title
        setupUI()
        setupLayout()
        setupHoverGesture()
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Focus ring view
        focusRingView.isUserInteractionEnabled = false
        focusRingView.layer.borderWidth = 2
        focusRingView.layer.borderColor = UIColor.systemPurple.cgColor
        focusRingView.alpha = 0
        addSubview(focusRingView)
        
        // Circle view
        circleView.isUserInteractionEnabled = false
        circleView.layer.borderWidth = 2
        addSubview(circleView)
        
        // Inner circle view
        innerCircleView.isUserInteractionEnabled = false
        innerCircleView.alpha = 0
        circleView.addSubview(innerCircleView)
        
        // Label
        label.font = .systemFont(ofSize: 16)
        label.isUserInteractionEnabled = false
        addSubview(label)
        
        // Touch handling
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    private func setupLayout() {
        focusRingView.translatesAutoresizingMaskIntoConstraints = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        innerCircleView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Focus ring view
            focusRingView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            focusRingView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            focusRingView.widthAnchor.constraint(equalToConstant: Metric.focusRingSize),
            focusRingView.heightAnchor.constraint(equalToConstant: Metric.focusRingSize),
            
            // Circle view
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: Metric.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: Metric.circleSize),
            
            // Inner circle view
            innerCircleView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            innerCircleView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            innerCircleView.widthAnchor.constraint(equalToConstant: Metric.innerCircleSize),
            innerCircleView.heightAnchor.constraint(equalToConstant: Metric.innerCircleSize),
            
            // Label
            label.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: Metric.spacing),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        focusRingView.layer.cornerRadius = Metric.focusRingSize / 2
        circleView.layer.cornerRadius = Metric.circleSize / 2
        innerCircleView.layer.cornerRadius = Metric.innerCircleSize / 2
    }
    
    // MARK: - Hover Support
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
    
    // MARK: - Focus Support
    override var canBecomeFocused: Bool {
        return isEnabled
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        updateAppearance()
    }
    
    // MARK: - Touch Handling (Toggle 기능)
    @objc private func handleTap() {
        guard isEnabled else { return }
        isSelected.toggle()
        sendActions(for: .valueChanged)
    }
    
    // MARK: - Appearance Update
    private func updateAppearance() {
        let state = getCurrentState()
        let colors = getColors(for: state)
        
        // 애니메이션 제거 - 직접 업데이트
        circleView.layer.borderColor = colors.border.cgColor
        circleView.backgroundColor = colors.background
        innerCircleView.backgroundColor = colors.innerCircle
        innerCircleView.alpha = isSelected ? 1 : 0
        label.textColor = colors.text
        focusRingView.alpha = isFocused ? 1 : 0
    }
    
    private func getCurrentState() -> RadioButtonState {
        if !isEnabled {
            return .disabled
        } else if isFocused {
            return isSelected ? (isEmphasized ? .focusSelectedEmphasized : .focusSelected) : .focus
        } else if isHighlighted {
            return isSelected ? (isEmphasized ? .touchSelectedEmphasized : .touchSelected) : .touch
        } else if isHovered {
            return isSelected ? (isEmphasized ? .hoverSelectedEmphasized : .hoverSelected) : .hover
        } else if isSelected {
            return isEmphasized ? .selectedEmphasized : .selected
        } else {
            return .normal
        }
    }
    
    private func getColors(for state: RadioButtonState) -> RadioButtonColors {
        switch state {
        // Not Selected States
        case .normal:
            return RadioButtonColors(
                border: UIColor.appColor(.gray),
                background: .clear,
                innerCircle: .clear,
                text: .label
            )
        case .hover:
            return RadioButtonColors(
                border: .systemGray2,
                background: .systemGray6,
                innerCircle: .clear,
                text: .label
            )
        case .touch:
            return RadioButtonColors(
                border: .systemPurple,
                background: .systemPurple.withAlphaComponent(0.1),
                innerCircle: .clear,
                text: .label
            )
        case .focus:
            return RadioButtonColors(
                border: .systemPurple,
                background: .clear,
                innerCircle: .clear,
                text: .label
            )
            
        // Selected States
        case .selected:
            return RadioButtonColors(
                border: .systemPurple,
                background: .clear,
                innerCircle: .systemPurple,
                text: .label
            )
        case .selectedEmphasized:
            return RadioButtonColors(
                border: .systemPurple,
                background: .systemPurple.withAlphaComponent(0.15),
                innerCircle: .systemPurple,
                text: .label
            )
            
        // Selected + Interactive States
        case .hoverSelected:
            return RadioButtonColors(
                border: .systemPurple,
                background: .systemPurple.withAlphaComponent(0.05),
                innerCircle: .systemPurple,
                text: .label
            )
        case .hoverSelectedEmphasized:
            return RadioButtonColors(
                border: .systemPurple,
                background: .systemPurple.withAlphaComponent(0.2),
                innerCircle: .systemPurple,
                text: .label
            )
        case .touchSelected:
            return RadioButtonColors(
                border: .systemPurple,
                background: .systemPurple.withAlphaComponent(0.15),
                innerCircle: .systemPurple,
                text: .label
            )
        case .touchSelectedEmphasized:
            return RadioButtonColors(
                border: .systemPurple,
                background: .systemPurple.withAlphaComponent(0.25),
                innerCircle: .systemPurple,
                text: .label
            )
        case .focusSelected:
            return RadioButtonColors(
                border: .systemPurple,
                background: .clear,
                innerCircle: .systemPurple,
                text: .label
            )
        case .focusSelectedEmphasized:
            return RadioButtonColors(
                border: .systemPurple,
                background: .systemPurple.withAlphaComponent(0.15),
                innerCircle: .systemPurple,
                text: .label
            )
            
        // Disabled
        case .disabled:
            return RadioButtonColors(
                border: .systemGray4,
                background: .clear,
                innerCircle: .systemGray4,
                text: .systemGray3
            )
        }
    }
}

// MARK: - Supporting Types
enum RadioButtonState {
    // Not Selected
    case normal
    case hover
    case touch
    case focus
    
    // Selected
    case selected
    case selectedEmphasized
    
    // Selected + Interactive
    case hoverSelected
    case hoverSelectedEmphasized
    case touchSelected
    case touchSelectedEmphasized
    case focusSelected
    case focusSelectedEmphasized
    
    // Disabled
    case disabled
}

struct RadioButtonColors {
    let border: UIColor
    let background: UIColor
    let innerCircle: UIColor
    let text: UIColor
}

final class RadioButtonGroup {
    private var buttons: [RadioButton] = []
    var selectedButton: RadioButton?
    
    var onSelectionChanged: ((RadioButton?) -> Void)?
    
    func addButton(_ button: RadioButton) {
        buttons.append(button)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .valueChanged)
    }
    
    @objc private func buttonTapped(_ button: RadioButton) {
        if button.isSelected {
            // 선택된 버튼을 다시 눌렀을 때 - 다른 버튼들은 해제
            buttons.forEach {
                if $0 != button {
                    $0.isSelected = false
                }
            }
            selectedButton = button
        } else {
            // 선택 해제된 경우
            if selectedButton == button {
                selectedButton = nil
            }
        }
        onSelectionChanged?(selectedButton)
    }
    
    func deselectAll() {
        buttons.forEach { $0.isSelected = false }
        selectedButton = nil
    }
}
