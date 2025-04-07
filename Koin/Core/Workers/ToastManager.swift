//
//  ToastManager.swift
//  koin
//
//  Created by 김나훈 on 3/14/25.
//

import UIKit

final class ToastManager {
    static let shared = ToastManager()
    
    private var isVisited: [(yPosition: CGFloat, height: CGFloat)] = [] // 🔥 Y 위치 + 높이 저장
    private let toastSpacing: CGFloat = 16
    private let maxToastAreaHeight: CGFloat = 200 // 🔥 고정된 토스트 영역 높이
    private let displayDuration: TimeInterval = 5.0 // 🕒 토스트 표시 시간
    private let progressDuration: TimeInterval = 5.0 // ⏳ 진행 애니메이션 시간

    private init() {}

    /// 🔥 고정된 영역 내에서 토스트 메시지를 출력
    func showToast(parameters: [String: Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        let backgroundColor = UIColor.appColor(.primary800)
        
        // 🔥 고정된 출력 순서 지정
        let orderedKeys: [String] = [
            "event_label", "event_category", "value",
            "user_id", "gender", "major",
            "previous_page", "current_page", "duration_time"
        ]

        // 🔥 고정된 순서로 문자열 변환
        let logMessage = orderedKeys.compactMap { key -> String? in
            guard let value = parameters[key] else { return nil }
            return "\(key): \(value)"
        }.joined(separator: "\n")

        // 🔥 라벨 높이 계산
        let maxWidth = window.frame.width - 80
        let toastLabel = PaddingLabel()
        toastLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        toastLabel.textAlignment = .center
        toastLabel.text = logMessage
        toastLabel.numberOfLines = 0
        toastLabel.textColor = UIColor.appColor(.neutral0)
        toastLabel.frame = CGRect(x: 16, y: 0, width: maxWidth, height: 0)
        toastLabel.sizeToFit()
        
        // 🔥 라벨 높이를 고려하여 고정 영역 안에서 중앙 정렬
        let labelHeight = min(toastLabel.frame.height, maxToastAreaHeight - 40)
        toastLabel.frame = CGRect(x: 16, y: (maxToastAreaHeight - labelHeight) / 2, width: maxWidth, height: labelHeight)

        // 🔥 새로운 토스트의 Y 위치 계산 (빈 자리 찾아서 넣기)
        let newYPosition = findEmptyPosition(window: window)

        let toastView = UIView(frame: CGRect(x: 16, y: newYPosition, width: window.frame.width - 20, height: maxToastAreaHeight))
        toastView.layer.cornerRadius = 10
        toastView.clipsToBounds = true
        toastView.backgroundColor = backgroundColor
        toastView.isUserInteractionEnabled = false // ✅ 터치 이벤트 허용

        toastView.addSubview(toastLabel)

        // 🔥 원형 프로그레스 뷰 추가
        let progressSize: CGFloat = 30
        let progressView = CircularProgressView(frame: CGRect(x: toastView.frame.width - progressSize - 16, y: (maxToastAreaHeight - progressSize) / 2, width: progressSize, height: progressSize))
        progressView.isUserInteractionEnabled = false
        toastView.addSubview(progressView)

        window.addSubview(toastView)
        
        // 🔥 `isVisited` 배열에 추가 (Y 위치 + 고정 높이 함께 저장)
        isVisited.append((yPosition: newYPosition, height: maxToastAreaHeight))

        // 🔥 진행 애니메이션 시작
        progressView.startProgressAnimation(duration: progressDuration)

        // 🕒 지정된 시간 후에 제거
        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) { [weak self] in
            toastView.removeFromSuperview()
            self?.removeToastYPosition(yPosition: newYPosition)
        }
    }

    /// 🔥 고정된 영역 내에서 빈 자리를 찾아 Y 위치 반환
    private func findEmptyPosition(window: UIWindow) -> CGFloat {
        let baseY = window.frame.height - 200 // ✅ 하단에서 시작
        
        // 🔍 빈 공간 찾기: 0번째부터 탐색하여 빈 공간이 있으면 반환
        var usedPositions = isVisited.map { $0.yPosition }
        usedPositions.sort()

        var newY = baseY
        for i in 0..<5 { // 최대 5개의 토스트까지만 허용
            let expectedY = baseY - CGFloat(i) * (maxToastAreaHeight + toastSpacing)
            if !usedPositions.contains(expectedY) {
                return expectedY
            }
        }

        // 🔥 모든 자리가 차면 가장 위에 추가
        return baseY - CGFloat(isVisited.count) * (maxToastAreaHeight + toastSpacing)
    }

    /// 🔥 토스트가 사라질 때 `isVisited`에서 해당 위치 제거
    private func removeToastYPosition(yPosition: CGFloat) {
        if let index = isVisited.firstIndex(where: { $0.yPosition == yPosition }) {
            isVisited.remove(at: index)
        }
    }
}



final class CircularProgressView: UIView {
    
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        let lineWidth: CGFloat = 5
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (bounds.width - lineWidth) / 2
        
        // 배경 원 (회색)
        let backgroundPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: true)
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.strokeColor = UIColor.gray.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = lineWidth
        layer.addSublayer(backgroundLayer)
        
        // 진행 원 (노란색)
        progressLayer.path = backgroundPath.cgPath
        progressLayer.strokeColor = UIColor.appColor(.success700).cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 1.0
        layer.addSublayer(progressLayer)
    }
    
    /// 진행률 애니메이션 (duration 동안 100% → 0% 진행)
    func startProgressAnimation(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
        
        // 지정된 시간이 지나면 색상을 회색으로 변경
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.progressLayer.strokeColor = UIColor.gray.cgColor
        }
    }
}
