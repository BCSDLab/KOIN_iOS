//
//  ReviewsDTO.swift
//  koin
//
//  Created by 김나훈 on 7/8/24.
//

struct ReviewsDTO: Decodable {
    let totalCount, currentCount, totalPage, currentPage: Int
    let statistics: StatisticsDTO
    let reviews: [ReviewDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
        case statistics, reviews
    }
}

struct MyReviewDTO: Decodable {
    let count: Int
    let reviews: [ReviewDTO]
}

// MARK: - Review
struct ReviewDTO: Decodable {
    let reviewId, rating: Int
    let nickName, content: String
    let imageUrls: [String]
    let menuNames: [String]
    let isMine, isModified, isReported: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case rating
        case nickName = "nick_name"
        case content
        case imageUrls = "image_urls"
        case menuNames = "menu_names"
        case isMine = "is_mine"
        case isModified = "is_modified"
        case isReported = "is_reported"
        case createdAt = "created_at"
    }
}

extension MyReviewDTO {
    func toDomain(shopId: Int) -> [Review] {
        return self.reviews.map { $0.toDomain(shopId: shopId) }
    }
}

struct OneReviewDTO: Decodable {
    let reviewId, rating: Int
    let nickName, content: String
    let imageUrls: [String]
    let menuNames: [String]
    let isModified: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case rating
        case nickName = "nick_name"
        case content
        case imageUrls = "image_urls"
        case menuNames = "menu_names"
        case isModified = "is_modified"
        case createdAt = "created_at"
    }
}

struct StatisticsDTO: Decodable {
    let averageRating: Double
    let ratings: [String: Int]

    enum CodingKeys: String, CodingKey {
        case averageRating = "average_rating"
        case ratings
    }
}

extension ReviewDTO {
    func toDomain(shopId: Int) -> Review {
        return Review(
            nickName: nickName,
            rating: rating,
            content: content,
            imageUrls: imageUrls,
            menuNames: menuNames,
            createdAt: createdAt,
            isMine: isMine,
            isModified: isModified,
            isReported: isReported,
            shopId: shopId,
            reviewId: reviewId
        )
    }
}

extension ReviewsDTO {
    func toDomain(shopId: Int) -> ShopReview {
        return ShopReview(
            reviewStatistics: statistics,
            totalPage: totalPage,
            currentPage: currentPage,
            totalCount: totalCount,
            review: reviews.map { $0.toDomain(shopId: shopId) }
        )
    }
}
