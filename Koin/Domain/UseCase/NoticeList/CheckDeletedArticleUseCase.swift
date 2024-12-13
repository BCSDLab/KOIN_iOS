//
//  CheckDeletedArticleUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 10/27/24.
//

import Foundation

protocol CheckDeletedArticleUseCase {
    func execute(url: String, completion: @escaping (Bool) -> Void)
}

final class DefaultCheckDeletedArticleUseCase: CheckDeletedArticleUseCase {
    func execute(url: String, completion: @escaping (Bool) -> Void) {
        guard let requestUrl = URL(string: url) else {
                    completion(false) // 잘못된 URL 형식 처리
                    return
                }
                
                var request = URLRequest(url: requestUrl)
                request.httpShouldHandleCookies = false // 쿠키 처리 비활성화
                request.cachePolicy = .reloadIgnoringLocalCacheData // 캐시 무시
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    // 에러 처리
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        completion(false) // 에러 발생 시 처리
                        return
                    }
                    
                    // 응답 URL 확인
                    
                    if let responseUrl = response?.url {
                        // 리디렉션 URL이 삭제된 게시글의 경우 점검
                        print(responseUrl)
                        if responseUrl.absoluteString == "https://www.koreatech.ac.kr/kor/sitemap_12.do" {
                            completion(false) // 삭제된 경우
                        } else {
                            completion(true) // 정상 게시글
                        }
                    } else {
                        completion(false) // 응답 URL 없음
                    }
                }

                task.resume() // 네트워크 작업 시작
    }
}
