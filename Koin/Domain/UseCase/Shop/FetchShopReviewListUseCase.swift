//
//  FetchShopReviewListUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine

protocol FetchShopReviewListUseCase {
    func execute() -> AnyPublisher<ShopReview, Error>
}

final class MockFetchShopReviewListUseCase: FetchShopReviewListUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute() -> AnyPublisher<ShopReview, Error> {
        let mockData = createMockData()
        return Just(mockData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func createMockData() -> ShopReview {
        var reviews = [Review]()
        let imageList: [String] = [
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/198e21de-ab14-47e6-ad75-ea8b28f9b667",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/691e3dc6-6250-4230-90df-0a3889165520",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/70349c64-20db-4655-99b8-18b932722ca6",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/9f835693-1e2c-4f70-85a7-3a56455776a5",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/31e3e904-387f-4588-9373-602df66c3e97",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/b9513124-c555-433e-88c6-4bfa113dc102",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/3216e140-7322-4151-a191-44cb5bf4d9dc",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/fb40c835-8461-487f-8923-f711932b6d27",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/198e21de-ab14-47e6-ad75-ea8b28f9b667",
            "https://github.com/KimNahun/algorithm-1day1solve/assets/118811606/691e3dc6-6250-4230-90df-0a3889165520"
        ]
        for i in 1...10 {
            let review = Review(
                nickName: "User\(i)",
                rating: Int.random(in: 1...5),
                content: "This is a sample review content \(i).",
                imageUrls: imageList,
                menuNames: ["Menu Item \(i)"],
                createdAt: "2024.03.24"
            )
            reviews.append(review)
        }
        
        let reviewStatistics = ReviewStatisticsDTO(
            averageRating: 2.7,
            statistics: ["1": 1, "2": 2, "3": 3, "4": 2, "5": 2]
        )
        
        let shopReview = ShopReview(reviewStatistics: reviewStatistics, review: reviews)
        
        return shopReview
    }
}
