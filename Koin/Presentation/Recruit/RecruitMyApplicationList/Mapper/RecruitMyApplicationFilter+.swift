//
//  RecruitMyApplicationFilter+.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

extension RecruitMyApplicationFilter {
    func toGroupModels() -> [FilterGroupModel] {
        var groupModels = [
            FilterGroupModel(
                title: "지원 상태",
                hasAllButton: true,
                items: RecruitApplicationStatus.allCases.map(\.rawValue),
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
            )
        ]

        if let status,
           let statusIndex = RecruitApplicationStatus.allCases.firstIndex(of: status) {
            groupModels[0].didTap(itemAt: statusIndex + 1)
        }
        groupModels[1].didTap(itemAt: sort.index)
        return groupModels
    }

    init?(from groupModels: [FilterGroupModel]) {
        guard groupModels.count == 2,
              let sort = RecruitListSort(rawValue: groupModels[1].selectedItems.first?.title ?? "") else {
            return nil
        }

        status = RecruitApplicationStatus(
            rawValue: groupModels[0].selectedItems.first?.title ?? ""
        )
        self.sort = sort
    }
}
