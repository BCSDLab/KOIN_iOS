//
//  GetBusFiltersUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/29/24.
//

import Combine

protocol GetShuttleBusFilterUseCase {
    func execute() -> [String]
}

protocol GetExpressFilterUseCase {
    func execute() -> [String]
}

protocol GetCityFiltersUseCase {
    func execute() -> ([String], [String])
}

final class DefaultGetShuttleBusFilterUseCase: GetShuttleBusFilterUseCase {
    func execute() -> [String] {
        return ["전체", "순환노선", "주말노선", "주중노선"]
    }
}

final class DefaultGetExpressFilterUseCase: GetExpressFilterUseCase {
    func execute() -> [String] {
        return ["병천방면", "천안방면"]
    }
}

final class DefaultGetCityFiltersUseCase: GetCityFiltersUseCase {
    func execute() -> ([String], [String]) {
        return (["병천방면", "천안방면"], ["400번", "402번", "405번"])
    }
}
