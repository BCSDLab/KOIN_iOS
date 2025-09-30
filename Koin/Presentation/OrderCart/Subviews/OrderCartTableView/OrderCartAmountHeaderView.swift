//
//  OrderCartAmountHeaderView.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

 import UIKit
 
final class OrderCartAmountHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    // MARK: - Components
    let label = UILabel().then {
        $0.text = "결제금액을 확인해주세요"
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
    }
    
    // MARK: - Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
extension OrderCartAmountHeaderView {
    
    private func configureView() {
        backgroundView = nil
        
        [label].forEach {
            contentView.addSubview($0)
        }
        label.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
