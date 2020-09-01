//
//  BusCard.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/30.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct BusCard: Decodable, Hashable, Identifiable
{
    var id: Int
    var depart: String = ""
    var arrival: String = ""
}
