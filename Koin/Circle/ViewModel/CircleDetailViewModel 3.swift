//
//  CircleDetailViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class CircleDetailViewModel: ObservableObject {
    var item: CircleDetail? = nil
    let circleFetcher: CircleFetcher = CircleFetcher()
    private var disposables = Set<AnyCancellable>()
    @Published var progress: Bool = true
    init(id: Int) {
        load(id: id)
        
    }
    
    func load(id: Int) {
        progress = true
        self.circleFetcher.getDetailCircle(id: id)
        .receive(on: DispatchQueue.main)
        .print()
        .sink(receiveCompletion: { value in
            switch value {
                case .failure:
                    self.item = nil
                case .finished:
                    break
            }
        }, receiveValue: { circle in
            self.item = circle
            self.progress = false
        })
            .store(in: &disposables)
    }
    
    var id: Int {
        return item?.id ?? 0
    }
    
    var logoUrl: String {
        return item?.logo_url ?? ""
    }
    
    var backgroundUrl: String {
        return item?.background_img_url ?? ""
    }
    
    var lineDescription: String {
        return item?.line_description ?? ""
    }
    
    var name: String {
        return item?.name ?? ""
    }
    
    var location: String {
        return item?.location ?? ""
    }
    
    var majorBusiness: String {
        return item?.major_business ?? ""
    }
    
    var professor: String {
        return item?.professor ?? ""
    }
    
    var introduceUrl: String {
        return item?.introduce_url ?? ""
    }
    
    var introduce: String {
        return item?.description ?? ""
    }
    
    var facebookUrl: String {
        if((item?.link_urls?.contains {e in
            e.type == "facebook"
            }) != nil) {
            return item?.link_urls?.first { e in
                e.type == "facebook"
            }?.link ?? ""
        } else {
            return ""
        }
    }
    
    var naverUrl: String {
        if((item?.link_urls?.contains {e in
            e.type == "naver"
            }) != nil) {
            return item?.link_urls?.first { e in
                e.type == "naver"
                }?.link ?? ""
        } else {
            return ""
        }
    }
    
    var cyworldUrl: String {
        if((item?.link_urls?.contains {e in
            e.type == "cyworld"
            }) != nil) {
            return item?.link_urls?.first { e in
                e.type == "cyworld"
                }?.link ?? ""
        } else {
            return ""
        }
    }
    
    
}
