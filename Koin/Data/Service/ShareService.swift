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
        let contentText: String = "\(shareModel.menuList.joined(separator: ", "))"
        
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
        
        let monthString = String(shareModel.date.dropFirst(2).prefix(2))
        let dayString = String(shareModel.date.dropFirst(4).prefix(2))
        let formattedDate: String
        
        if let month = Int(monthString), let day = Int(dayString) {
            formattedDate = "\(month)월 \(day)일"
        }
        else {
            formattedDate = ""
        }
        
        
        let itemContent = ItemContent(
            profileText: "\(formattedDate) \(shareModel.type.name) 식단",
            items: [
                ItemInfo(item: shareModel.place.rawValue, itemOp: contentText)
            ]
        )
        let content: Content
        if let imageUrlString = shareModel.imageUrl, let imageUrl = URL(string: imageUrlString) {
            content = Content(
                imageUrl: imageUrl,
                description: " ",
                link: link
            )
        } else {
            content = Content(
                description: " ",
                link: link
            )
        }
        
        
        let template = FeedTemplate(
            content: content,
            itemContent: itemContent,
            buttons: [Button(title: "코인에서 식단 전체보기", link: link)]
        )
        
        // 메시지 템플릿 encode
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
            // 생성한 메시지 템플릿 객체를 jsonObject로 변환
            if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                // 카카오톡 앱이 있는지 체크합니다.
                if ShareApi.isKakaoTalkSharingAvailable() {
                    ShareApi.shared.shareDefault(templateObject: templateJsonObject) { (linkResult, error) in
                        if let error = error {
                            print("Error sharing: \(error.localizedDescription)")
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
