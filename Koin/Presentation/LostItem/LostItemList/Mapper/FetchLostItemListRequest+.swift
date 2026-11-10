//
//  FetchLostItemListRequest+.swift
//  Koin
//

import Foundation

extension FetchLostItemListRequest {
    func toFilterGroupModels() -> [FilterGroupModel] {
        var groups = [
            FilterGroupModel(
                title: "목록",
                hasAllButton: true,
                items: ["내 게시물"],
                behavior: .single
            ),
            FilterGroupModel(
                title: "물품 카테고리",
                hasAllButton: true,
                items: ["습득물", "분실물"],
                behavior: .single
            ),
            FilterGroupModel(
                title: "물품 종류",
                hasAllButton: true,
                items: ["카드", "신분증", "지갑", "전자제품", "기타"],
                behavior: .multiple
            ),
            FilterGroupModel(
                title: "물품 상태",
                hasAllButton: true,
                items: ["찾는중", "찾음"],
                behavior: .single
            )
        ]

        if author == .my {
            groups[0].didTap(itemAt: 1)
        }
        if let type {
            groups[1].didTap(itemAt: type == .found ? 1 : 2)
        }
        if !category.contains(.all) {
            for index in groups[2].items.indices {
                if let itemCategory = LostItemCategory(description: groups[2].items[index].title),
                   category.contains(itemCategory) {
                    groups[2].didTap(itemAt: index)
                }
            }
        }
        switch foundStatus {
        case .all: break
        case .notFound: groups[3].didTap(itemAt: 1)
        case .found: groups[3].didTap(itemAt: 2)
        }
        return groups
    }

    init?(from groups: [FilterGroupModel]) {
        guard groups.count == 4,
              let author = groups[0].selectedItems.first?.title,
              let type = groups[1].selectedItems.first?.title,
              let foundStatus = groups[3].selectedItems.first?.title else {
            return nil
        }
        self.author = author == "내 게시물" ? .my : .all
        switch type {
        case "습득물": self.type = .found
        case "분실물": self.type = .lost
        default: self.type = nil
        }
        category = Set(groups[2].selectedItems.compactMap { LostItemCategory(description: $0.title) })
        switch foundStatus {
        case "찾는중": self.foundStatus = .notFound
        case "찾음": self.foundStatus = .found
        default: self.foundStatus = .all
        }
    }
}

extension FetchLostItemListRequest {
    /// 물품 종류는 Set의 순서와 관계없이 필터 UI 순서로 전송한다.
    var loggingParameters: [String: String] {
        let orderedCategories: [LostItemCategory] = [.card, .id, .wallet, .electronics, .etc]
        let itemType = category.isEmpty || category.contains(.all)
            ? "전체"
            : orderedCategories.filter { category.contains($0) }.map(\.description).joined(separator: "|")
        let status: String
        switch foundStatus {
        case .all: status = "전체"
        case .notFound: status = "찾는중"
        case .found: status = "찾음"
        }
        return [
            "filter_scope": author == .my ? "내 게시물" : "전체",
            "filter_post_type": type.map { "\($0.description)물" } ?? "전체",
            "filter_item_type": itemType,
            "filter_status": status
        ]
    }
}
