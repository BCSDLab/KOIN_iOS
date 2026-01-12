//
//  DashedBorderButton.swift
//  koin
//
//  Created by 김성민 on 11/12/25.
//

import UIKit

final class DashedBorderButton: UIButton {

    private let dashedBorderLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    override func updateConfiguration() {
        super.updateConfiguration()
        setupLayer()
    }
    
    private func setupLayer() {
        if dashedBorderLayer.superlayer == nil {
            dashedBorderLayer.strokeColor = UIColor.appColor(.neutral300).cgColor
            dashedBorderLayer.fillColor = UIColor.clear.cgColor
            dashedBorderLayer.lineWidth = 1
            dashedBorderLayer.lineDashPattern = [4, 4]
            layer.insertSublayer(dashedBorderLayer, at: 0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        dashedBorderLayer.frame = self.bounds
        let rect = self.bounds.insetBy(dx: 0.5, dy: 0.5)
        dashedBorderLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath
        
        CATransaction.commit()
    }
}
