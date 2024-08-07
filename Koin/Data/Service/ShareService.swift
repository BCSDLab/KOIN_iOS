//
//  ShareService.swift
//  koin
//
//  Created by 김나훈 on 7/20/24.
//

import Foundation
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon

protocol ShareService {
    func shareMenuList(shareModel: ShareDiningMenu)
}

final class KakaoShareService: ShareService {
    func shareMenuList(shareModel: ShareDiningMenu) {
        let contentText = "\(shareModel.menuList.joined(separator: ", "))"
        
        guard let webUrl = URL(string: "https://developers.kakao.com"),
              let mobileWebUrl = URL(string: "https://developers.kakao.com") else {
            return
        }
        
        let link = Link(
            webUrl: webUrl,
            mobileWebUrl: mobileWebUrl,
            androidExecutionParams: ["date": shareModel.date, "type": shareModel.type.rawValue, "place": shareModel.place.rawValue],
            iosExecutionParams: ["date": shareModel.date, "type": shareModel.type.rawValue, "place": shareModel.place.rawValue]
        )
        var content: Content
        if let imageUrlString = shareModel.imageUrl, let imageUrl = URL(string: imageUrlString) {
            content = Content(
                imageUrl: imageUrl,
                description: contentText,
                link: link
            )
        } else {
            content = Content(
                description: contentText,
                link: link
            )
        }
        
        let template = FeedTemplate(content: content, buttons: [Button(title: "다른 식단 보러가기", link: link)])
        
        // 메시지 템플릿 encode
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
            // 생성한 메시지 템플릿 객체를 jsonObject로 변환
            if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                // 카카오톡 앱이 있는지 체크합니다.
                if ShareApi.isKakaoTalkSharingAvailable() {
                    ShareApi.shared.shareDefault(templateObject:templateJsonObject) {(linkResult, error) in
                        if let error = error {
                        } else {
                            guard let linkResult = linkResult else { return }
                            UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                        }
                    }
                } else {
                    if let appStoreUrl = URL(string: "https://apps.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1/id362057947") {
                        UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
}
