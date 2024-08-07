//
//  ImageCacher.swift
//  Koin
//
//  Created by 김나훈 on 3/13/24.
//

import UIKit
// 이미지 캐싱.
final class ImageCacher {
    static let shared = ImageCacher()
    private init() {}
    
    private var cache = NSCache<NSString, UIImage>()
    
    func save(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}
