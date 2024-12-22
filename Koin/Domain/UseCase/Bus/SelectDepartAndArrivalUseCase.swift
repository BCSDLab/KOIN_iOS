//
//  SelectDepartAndArrivalUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/24/24.
//

import Combine

protocol SelectDepartAndArrivalUseCase {
    func execute(busAreaIdx: Int, busRouteType: BusAreaButtonState) -> (BusAreaButtonState, BusPlace?)
}

final class DefaultSelectDepartAndArrivalUseCase: SelectDepartAndArrivalUseCase {
    func execute(busAreaIdx: Int, busRouteType: BusAreaButtonState) -> (BusAreaButtonState, BusPlace?) {
        let buttonState: BusAreaButtonState = busRouteType == .departureSelect ? .departureSelect : .arrivalSelect
        if busAreaIdx == 0 {
            return (buttonState, nil)
        }
        return (buttonState, BusPlace.allCases[busAreaIdx - 1])
    }
}
