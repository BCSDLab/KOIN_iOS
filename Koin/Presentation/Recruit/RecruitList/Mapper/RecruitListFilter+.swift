//
//  RecruitListFilter+.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

extension RecruitListFilter {
    func toGroupModels() -> [FilterGroupModel] {
        var groupModels = [
            FilterGroupModel(
                title: "모집 상태",
                hasAllButton: true,
                items: [
                    RecruitState.recruiting.rawValue,
                    RecruitState.closed.rawValue
                ],
                behavior: .single
            ),
            FilterGroupModel(
                title: "정렬",
                hasAllButton: false,
                items: [
                    RecruitListSort.latestDescending.rawValue,
                    RecruitListSort.deadlineAscending.rawValue
                ],
                behavior: .single
            ),
            FilterGroupModel(
                title: "카테고리",
                hasAllButton: true,
                items: RecruitCategory.allCases.map(\.rawValue),
                behavior: .multiple
            ),
            FilterGroupModel(
                title: "진행방식",
                hasAllButton: true,
                items: RecruitMeetingType.allCases.map(\.rawValue),
                behavior: .single
            )
        ]
        
        groupModels[0].didTap(itemAt: state.index)
        groupModels[1].didTap(itemAt: sort.index)
        
        category.forEach {
            groupModels[2].didTap(itemAt: $0.index)
        }
        
        if let meetingType {
            groupModels[3].didTap(itemAt: meetingType.index)
        }
        
        return groupModels
    }
}

extension RecruitListFilter {
    init?(from groupModels: [FilterGroupModel]) {
        guard let state = RecruitState(rawValue: groupModels[0].selectedItems.first?.title ?? ""),
              let sort = RecruitListSort(rawValue: groupModels[1].selectedItems.first?.title ?? "") else {
            return nil
        }
        self.state = state
        self.sort = sort
        
        self.category = groupModels[2].selectedItems
            .compactMap {
                RecruitCategory(rawValue: $0.title)
            }
            .reduce(into: Set<RecruitCategory>(), { (set, category) in
                set.insert(category)
            })
        
        self.meetingType = RecruitMeetingType(rawValue: groupModels[3].selectedItems.first?.title ?? "")
    }
}
