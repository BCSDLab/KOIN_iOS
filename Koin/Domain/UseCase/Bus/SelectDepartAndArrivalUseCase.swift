//
//  SelectDepartAndArrivalUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/24/24.
//

import Combine

protocol SelectDepartAndArrivalUseCase {
    func selectBusPlaceOptions(selectedBusPlace: SelectedBusPlaceStatus) -> (BusPlace, BusPlace)
}

final class DefaultSelectDepartAndArrivalUseCase: SelectDepartAndArrivalUseCase {
    func selectBusPlaceOptions(selectedBusPlace: SelectedBusPlaceStatus) -> (BusPlace, BusPlace){
        let lastDepartedPlace = selectedBusPlace.lastDepartedPlace
        let lastArrivedPlace = selectedBusPlace.lastArrivedPlace
        let nowArrivedPlace = selectedBusPlace.nowArrivedPlace
        let nowDepartedPlace = selectedBusPlace.nowDepartedPlace
        
        if nowDepartedPlace != nowArrivedPlace {
            return (nowDepartedPlace, nowArrivedPlace)
        }
        else {
            if let lastDepartedPlace = lastDepartedPlace {
                return (nowDepartedPlace, lastDepartedPlace)
            }
            
            if let lastArrivedPlace = lastArrivedPlace {
                return (lastArrivedPlace, nowArrivedPlace)
            }
            
            return (nowDepartedPlace, nowArrivedPlace)
        }
    }
}
