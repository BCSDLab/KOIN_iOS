//
//  SelectDepartAndArrivalUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/24/24.
//

import Combine

protocol SelectDepartAndArrivalUseCase {
    func execute(departedAreaIdx: Int, arrivalAreaIdx: Int, busRouteType: Int) -> (BusAreaButtonState, BusPlace?)
}

final class DefaultSelectDepartAndArrivalUseCase: SelectDepartAndArrivalUseCase {
    func execute(departedAreaIdx: Int, arrivalAreaIdx: Int, busRouteType: Int) -> (BusAreaButtonState, BusPlace?) {
        var buttonState: BusAreaButtonState = .allSelected
        var busPlace: BusPlace? = nil
        if departedAreaIdx == 0 && arrivalAreaIdx == 0 || (departedAreaIdx != 0 && arrivalAreaIdx != 0) {
            buttonState = .notSelected
            if departedAreaIdx != 0 && arrivalAreaIdx != 0 {
                if busRouteType == 0 {
                    busPlace = BusPlace.allCases[departedAreaIdx - 1]
                }
                else {
                    busPlace = BusPlace.allCases[arrivalAreaIdx - 1]
                }
            }
        }
        else {
            if busRouteType == 0 {
                buttonState = .arrivalSelected
                busPlace = BusPlace.allCases[departedAreaIdx - 1]
            }
            else {
                buttonState = .departureSelected
                busPlace = BusPlace.allCases[arrivalAreaIdx - 1]
            }
        }
        return (buttonState, busPlace)
    }
}
