//
//  OrderPrepareCollectionViewCell.swift
//  koin
//
//  Created by 김성민 on 9/9/25.
//

import UIKit

final class OrderPrepareCollectionViewCell: UICollectionViewCell {
    
    static let OrderPrepareIdentifier = "OrderPrepareCollectionViewCell"
    
    private enum stateCase {
        case delivery
        case pakaging
    }
    
    private let orderInfoButton: UIButton = {
        var cf = UIButton.Configuration.plain()
        cf.attributedTitle = AttributedString("배달", attributes: .init([
            .font: UIFont.appFont(.pretendardMedium, size: 12)
        ]))
        cf.baseForegroundColor = UIColor.appColor(.new500)
        cf.imagePlacement = .leading
        cf.imagePadding = 5.5
        cf.contentInsets = .init(top: 2, leading: 6, bottom: 2, trailing: 6)
        cf.background.backgroundColor = .appColor(.new100)
        
        let base = UIImage.appImage(asset: .delivery2)?.withRenderingMode(.alwaysTemplate)
        let small = base?.preparingThumbnail(of: CGSize(width: 16, height: 16)) ?? base
        cf.image = small
        
        let b = UIButton(configuration: cf)
        b.imageView?.contentMode = .scaleAspectFit
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()
    
    private let estimatedTimeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.appFont(.pretendardMedium, size: 12)
        l.textColor = UIColor.appColor(.new500)
        l.textAlignment = .center
        return l
    }()
    
    
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}

