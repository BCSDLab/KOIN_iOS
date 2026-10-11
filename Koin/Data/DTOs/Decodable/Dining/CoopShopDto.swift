//
//  CoopShopDto.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

import Foundation

struct CoopShopDto: Decodable {
    let id: Int
    let name, semester: String
    let opens: [CoopOpenDto]?
    let phone, location: String
    let remarks: String?
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, semester, opens, phone, location, remarks
        case updatedAt = "updated_at"
    }
    
    func toDomain() -> CoopShopData {
        return .init(location: location, phone: phone, remarks: remarks ?? "", name: name, semester: semester, opens: opens?.compactMap { $0.toDomain() } ?? [], updatedAt: formatUpdatedAt(updatedAt))
    }
    
    private func formatUpdatedAt(_ updatedAt: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: updatedAt) else {
            return updatedAt
        }
        return date.formatDateToCustom()
    }
}
