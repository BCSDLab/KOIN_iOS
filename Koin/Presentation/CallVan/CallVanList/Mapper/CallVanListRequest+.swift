//
//  CallVanListRequest+.swift
//  koin
//
//  Created by 홍기정 on 8/28/26.
//

import Foundation

extension CallVanListRequest {
    func toFilterGroupModels() -> [FilterGroupModel] {
        var filterGroupModels = [
            FilterGroupModel(
                title: "목록",
                hasAllButton: true,
                items: [
                    CallVanMineOrJoined.mine.rawValue,
                    CallVanMineOrJoined.joined.rawValue
                ],
                behavior: .single
            ),
            FilterGroupModel(
                title: "정렬",
                hasAllButton: false,
                items: [
                    CallVanListSort.latestDesc.rawValue,
                    CallVanListSort.departureDesc.rawValue
                ],
                behavior: .single
            ),
            FilterGroupModel(
                title: "모집 상태",
                hasAllButton: true,
                items: [
                    CallVanRecruitmentState.recruiting.rawValue,
                    CallVanRecruitmentState.closed.rawValue
                ],
                behavior: .single
            ),
            FilterGroupModel(
                title: "출발지",
                description: "기타 장소는 검색창을 이용해주세요.",
                hasAllButton: true,
                items: [
                    CallVanPlace.frontGate.rawValue,
                    CallVanPlace.backGate.rawValue,
                    CallVanPlace.terminal.rawValue,
                    CallVanPlace.dormitoryMain.rawValue,
                    CallVanPlace.dormitorySub.rawValue,
                    CallVanPlace.station.rawValue,
                    CallVanPlace.asanStation.rawValue
                ],
                behavior: .multiple
            ),
            FilterGroupModel(
                title: "도착지",
                description: "기타 장소는 검색창을 이용해주세요.",
                hasAllButton: true,
                items: [
                    CallVanPlace.frontGate.rawValue,
                    CallVanPlace.backGate.rawValue,
                    CallVanPlace.terminal.rawValue,
                    CallVanPlace.dormitoryMain.rawValue,
                    CallVanPlace.dormitorySub.rawValue,
                    CallVanPlace.station.rawValue,
                    CallVanPlace.asanStation.rawValue
                ],
                behavior: .multiple
            )
        ]
        
        filterGroupModels[0].didTap(itemAt: mineOrJoined.index)
        
        if let index = sort.index {
            filterGroupModels[1].didTap(itemAt: index)
        }
        
        filterGroupModels[2].didTap(itemAt: state.index)
        
        departure.forEach { place in
            filterGroupModels[3].didTap(itemAt: place.index)
        }
        
        arrival.forEach { place in
            filterGroupModels[4].didTap(itemAt: place.index)
        }
        
        return filterGroupModels
    }
}

extension CallVanListRequest {
    init?(from filterGroupModels: [FilterGroupModel]) {
        guard let mineOrJoined = filterGroupModels[0].selectedItems.first?.title,
              let sort = filterGroupModels[1].selectedItems.first?.title,
              let state = filterGroupModels[2].selectedItems.first?.title
        else {
            return nil
        }
        
        switch mineOrJoined {
        case CallVanMineOrJoined.mine.rawValue:
            self.mineOrJoined = .mine
        case CallVanMineOrJoined.joined.rawValue:
            self.mineOrJoined = .joined
        default:
            self.mineOrJoined = .all
        }
        
        switch sort {
        case CallVanListSort.departureDesc.rawValue:
            self.sort = .departureDesc
        default:
            self.sort = .latestDesc
        }
        
        switch state {
        case CallVanRecruitmentState.recruiting.rawValue:
            self.state = .recruiting
        case CallVanRecruitmentState.closed.rawValue:
            self.state = .closed
        default:
            self.state = .all
        }
        
        var departure: Set<CallVanPlace> = []
        for selectedItem in filterGroupModels[3].selectedItems {
            guard let selectedItem = CallVanPlace(rawValue: selectedItem.title) else {
                return
            }
            if selectedItem == .all {
                departure = Set<CallVanPlace>.init(arrayLiteral: .all)
                break
            } else {
                departure.insert(selectedItem)
                continue
            }
        }
        self.departure = departure
        
        var arrival: Set<CallVanPlace> = []
        for selectedItem in filterGroupModels[4].selectedItems {
            guard let selectedItem = CallVanPlace(rawValue: selectedItem.title) else {
                return
            }
            if selectedItem == .all {
                arrival = Set<CallVanPlace>.init(arrayLiteral: .all)
                break
            } else {
                arrival.insert(selectedItem)
                continue
            }
        }
        self.arrival = arrival
    }
}
