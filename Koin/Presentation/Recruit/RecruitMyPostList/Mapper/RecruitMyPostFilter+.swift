//
//  RecruitMyPostFilter+.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

extension RecruitMyPostFilter {
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
            )
        ]

        groupModels[0].didTap(itemAt: state.index)
        groupModels[1].didTap(itemAt: sort.index)
        return groupModels
    }

    init?(from groupModels: [FilterGroupModel]) {
        guard groupModels.count == 2,
              let state = RecruitState(rawValue: groupModels[0].selectedItems.first?.title ?? ""),
              let sort = RecruitListSort(rawValue: groupModels[1].selectedItems.first?.title ?? "") else {
            return nil
        }

        self.state = state
        self.sort = sort
    }
}

extension RecruitMyPostFilter {
    static func logEvent(groupIndex: Int, title: String) -> (label: EventParameter.EventLabel.Campus, value: String)? {
        switch groupIndex {
        case 0:
            guard let state = RecruitState(rawValue: title) else {
                return nil
            }
            return (.teamRecruitmentCreatedPostFilterStatus, state == .closed ? "모집 마감" : state.logValue)
        case 1:
            guard let sort = RecruitListSort(rawValue: title) else {
                return nil
            }
            return (.teamRecruitmentCreatedPostFilterSort, sort.logValue)
        default:
            return nil
        }
    }
}
