//
//  UIImageView+.swift
//  Koin
//
//  Created by 김나훈 on 3/13/24.
//

import UIKit

// TODO: NS Cache는 앱이 실행되는 동안에만 캐싱. 앱이 종료되면 메모리에서 해제
// URL 캐시, KingFisher,FileManager등을 통해서 구현해볼것
extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // 이미지 캐시됐는지 확인
        if let cachedImage = ImageCacher.shared.image(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        // 캐시 안됐다면 다운로드
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                print("Error: Image data is corrupted or invalid")
                return
            }
            ImageCacher.shared.save(image: downloadedImage, forKey: urlString)
            
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }.resume()
    }
}
