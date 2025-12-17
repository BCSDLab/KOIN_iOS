//
//  ClubContainer.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import Foundation

protocol ClubFactory {
    func makeClub()
}

extension DIContainer: ClubFactory {
    func makeClub() {}
}
