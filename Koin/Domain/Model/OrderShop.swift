
import Foundation

struct OrderShop: Identifiable {
    let id = UUID()
    let shopId: Int
    let name: String
    let isOpen: Bool
    let isDeliveryAvailable: Bool
    let isTakeoutAvailable: Bool
    let minimumOrderAmount: Int
    let ratingAverage: Double
    let reviewCount: Int
    let minimumDeliveryTip: Int
    let maximumDeliveryTip: Int
    let categoryIds: [Int]
    let imageUrls: [String]
    let open: [OpenInfo]
    let openStatus: String
}

struct OpenInfo {
    let dayOfWeek: String
    let closed: Bool
    let openTime: String
    let closeTime: String
}

extension OrderShop {
    init(from dto: OrderShopDTO) {
        self.shopId = dto.shopId
        self.name = dto.name
        self.isOpen = dto.isOpen
        self.isDeliveryAvailable = dto.isDeliveryAvailable
        self.isTakeoutAvailable = dto.isTakeoutAvailable
        self.minimumOrderAmount = dto.minimumOrderAmount
        self.ratingAverage = dto.ratingAverage
        self.reviewCount = dto.reviewCount
        self.minimumDeliveryTip = dto.minimumDeliveryTip
        self.maximumDeliveryTip = dto.maximumDeliveryTip
        self.categoryIds = dto.categoryIds
        self.imageUrls = dto.imageUrls
        self.open = dto.open.map(OpenInfo.init)
        self.openStatus = dto.openStatus
    }
}

extension OpenInfo {
    init(from dto: OpenInfoDTO) {
        self.dayOfWeek = dto.dayOfWeek
        self.closed = dto.closed
        self.openTime = dto.openTime
        self.closeTime = dto.closeTime
    }
}
