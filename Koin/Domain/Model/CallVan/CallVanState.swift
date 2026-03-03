//
//  CallVanState.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import UIKit

enum CallVanState: String {
    case 참여하기
    case 참여취소
    case 모집마감
    
    case 마감하기
    case 재모집
    case 이용완료
    
    var foregroundColor: UIColor {
        switch self {
        case .참여하기:
            return UIColor.appColor(.neutral0)
        case .참여취소:
            return UIColor.appColor(.new700)
        case .모집마감:
            return UIColor.appColor(.neutral500)
        case .마감하기:
            return UIColor.appColor(.new500)
        case .재모집:
            return UIColor.appColor(.new500)
        case .이용완료:
            return UIColor.appColor(.neutral0)
            
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .참여하기:
            return UIColor.appColor(.new500)
        case .참여취소:
            return UIColor.ColorSystem.Primary.purple100
        case .모집마감:
            return UIColor.appColor(.neutral0)
        case .마감하기:
            return UIColor.appColor(.neutral0)
        case .재모집:
            return UIColor.appColor(.neutral0)
        case .이용완료:
            return UIColor.ColorSystem.Primary.purple800
        }
    }
    
    var borderColor: UIColor? {
        switch self {
        case .참여하기:
            return nil
        case .참여취소:
            return nil
        case .모집마감:
            return UIColor.appColor(.neutral500)
        case .마감하기:
            return UIColor.appColor(.new500)
        case .재모집:
            return UIColor.appColor(.new500)
        case .이용완료:
            return nil
        }
    }
}
