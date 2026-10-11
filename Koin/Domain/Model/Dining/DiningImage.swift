//
//  DiningImage.swift
//  koin
//

enum DiningImage {
    case imageUrl(String)
    case empty(ImageAsset)
    case none

    init(from imageUrl: String?, place: DiningPlace, type: DiningType, isWeekend: Bool) {
        if place == .special || place == .secondCampus {
            self = .none
            return
        }
        if type == .breakfast && imageUrl == nil {
            self = .none
            return
        }
        if let imageUrl {
            self = .imageUrl(imageUrl)
            return
        }
        self = .empty(isWeekend ? .nonMenuWeekendImage : .nonMenuImage)
    }
}
