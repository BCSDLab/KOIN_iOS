//
//  FetchKeywordNoticePhraseUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/19/24.
//

import Foundation

protocol FetchKeywordNoticePhraseUseCase {
    func execute(date: Date) -> ((String, String), Int)
}

final class DefaultFetchKeywordNoticePhraseUseCase: FetchKeywordNoticePhraseUseCase {
    func execute(date: Date) -> ((String, String), Int) {
        return makeKeywordNoticePhrase(date: date)
    }
    
    private func makeKeywordNoticePhrase(date: Date) -> ((String, String), Int) {
        let titles = ["자취방 양도글, 가장 먼저 확인하고 싶을 때?", "키워드가 포함된 공지가 업로드 되면\n가장 먼저 알림을 보내드려요!", "근로 공지, 놓치고 싶지 않다면?", "해외탐방 공지, 놓치고 싶지 않다면?"]
        let subTitles = ["공지가 업로드 되면 바로 알려주는\n키워드 알림 설정하러가기", "키워드 알림 설정 바로가기", "공지가 업로드 되면 바로 알려주는\n키워드 알림 설정하러가기", "공지가 업로드 되면 바로 알려주는\n키워드 알림 설정하러가기"]
        var noticePhrases: [(String, String)] = []
        
        for (index, title) in titles.enumerated() {
            if index < subTitles.count {
                noticePhrases.append((title, subTitles[index]))
            }
        }
        let userDefaultsKey = "keywordBannerRegisteredAt"
    
        if let registeredDate = UserDefaults.standard.object(forKey: userDefaultsKey) as? Date {
            let calendar = Calendar.current
            if let daysDifference = calendar.dateComponents([.day], from: registeredDate, to: date).day {
                let difference = daysDifference % 7 == 0 ? daysDifference - 1 : daysDifference
                let index = ((difference + 1) / 7) % 4
                return (noticePhrases[index], index)
            }
        } else {
            UserDefaults.standard.set(Date(), forKey: userDefaultsKey)
        }
        return (noticePhrases[0], 0)
    }
}
