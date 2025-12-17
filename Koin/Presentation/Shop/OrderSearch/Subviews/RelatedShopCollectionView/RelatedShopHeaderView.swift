//
//  RelatedShopHeaderView.swift
//  koin
//
//  Created by 김나훈 on 11/14/24.
//

//import Combine
//import UIKit
//
//final class RelatedShopHeaderView: UICollectionReusableView {
//    
//    static let identifier = "RelatedShopHeaderView"
//    
//    private let searchTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "검색어를 입력해주세요."
//        textField.font = UIFont.appFont(.pretendardRegular, size: 14)
//        textField.tintColor = UIColor.appColor(.neutral500)
//        textField.backgroundColor = UIColor.appColor(.neutral100)
//        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
//        textField.leftView = paddingView
//        textField.leftViewMode = .always
//        let imageView = UIImageView(image: UIImage.appImage(asset: .search))
//        imageView.contentMode = .scaleAspectFit
//        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 24 + 12, height: 24))
//        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//        iconContainerView.addSubview(imageView)
//        textField.rightView = iconContainerView
//        textField.rightViewMode = .always
//        return textField
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//   
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    
//  
//}
