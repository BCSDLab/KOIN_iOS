//
//  EmptyStateView.swift
//  koin
//
//  Created by 김성민 on 9/19/25.
//

import Foundation
import SnapKit

final class EmptyStateView: UIView {
    
    var onTapAction: (() -> Void)?
    private var symbolCenterY: Constraint?
    
    struct Config{
        let title: String
        let showSeeOrderHistoryButton: Bool
    }
    
    private let centerGuide = UILayoutGuide()
    
    private let symbolImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .sleepBcsdSymbol)
    }

    private let noOrderHistoryLabel = UILabel().then {
        $0.text = "주문 내역이 없어요"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = UIColor.appColor(.new500)
        $0.textAlignment = .center
    }

    private let seeOrderHistoryButton = UIButton(
        configuration: {
            var config = UIButton.Configuration.plain()
            config.attributedTitle = AttributedString("과거 주문 내역 보기", attributes: .init([
                .font: UIFont.appFont(.pretendardBold, size: 13)
            ]))
            config.baseForegroundColor = UIColor.appColor(.neutral500)

            var background = UIBackgroundConfiguration.clear()
            background.cornerRadius = 8
            background.backgroundColor = UIColor.appColor(.neutral0)
            config.background = background

            config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
            return config
        }()
    ).then {
        $0.layer.masksToBounds = false
        $0.layer.shadowColor   = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset  = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius  = 4
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        configureView()
        setAddTarget()
        isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


// MARK: - Set UI

extension EmptyStateView {
    
    private func configureView() {
        backgroundColor = UIColor.appColor(.newBackground)
        setLayout()
    }
    
    private func setLayout(){
        [symbolImageView, noOrderHistoryLabel, seeOrderHistoryButton].forEach{
            addSubview($0)
        }
        
        addLayoutGuide(centerGuide)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let host = superview else { return }
        
        symbolImageView.snp.remakeConstraints {
            $0.centerX.equalTo(host.snp.centerX)
            $0.centerY.equalTo(host.snp.centerY)
            $0.width.equalTo(95)
            $0.height.equalTo(75)
        }
        
        noOrderHistoryLabel.snp.remakeConstraints {
            $0.top.equalTo(symbolImageView.snp.bottom).offset(16)
            $0.centerX.equalTo(host.snp.centerX)
        }
        
        seeOrderHistoryButton.snp.remakeConstraints {
            $0.top.equalTo(noOrderHistoryLabel.snp.bottom).offset(16)
            $0.centerX.equalTo(host.snp.centerX)
            $0.height.equalTo(35)
        }
    }


    
    private func setAddTarget(){
        seeOrderHistoryButton.addTarget(self, action: #selector(seeOrderHistoryButtonTapped), for: .touchUpInside)
    }
    
    func apply(_ config: Config){
        noOrderHistoryLabel.text = config.title
        seeOrderHistoryButton.isHidden = !config.showSeeOrderHistoryButton
        layoutIfNeeded()
    }
    
    
    //MARK: - @Objc
    @objc private func seeOrderHistoryButtonTapped() {
        onTapAction?()
    }
    

    
}
