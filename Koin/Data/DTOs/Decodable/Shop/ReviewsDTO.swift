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

// MARK: - Review
struct ReviewDTO: Decodable {
    let reviewId, rating: Int
    let nickName, content: String
    let imageUrls: [String]
    let menuNames: [String]
    let isMine, isModified: Bool
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
    func toDomain() -> Review {
        return Review(
            nickName: nickName,
            rating: rating,
            content: content,
            imageUrls: imageUrls,
            menuNames: menuNames,
            createdAt: createdAt,
            isMine: isMine,
            isModified: isModified
        )
    }
}

extension StatisticsDTO {
    func toDomain() -> StatisticsDTO {
        return StatisticsDTO(
            averageRating: averageRating,
            ratings: ratings
        )
    }
}

extension ReviewsDTO {
    func toDomain() -> ShopReview {
        return ShopReview(
            reviewStatistics: statistics.toDomain(),
            review: reviews.map { $0.toDomain() }
        )
    }
}
