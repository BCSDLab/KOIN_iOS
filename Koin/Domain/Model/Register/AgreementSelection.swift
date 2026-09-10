//
//  AgreementSelection.swift
//  koin
//
//  Created by 이은지 on 9/10/26.
//

import Foundation

struct AgreementSelection: Equatable {

    var personalInformation: Bool = false
    var koin: Bool = false
    var marketing: Bool = false

    var isRequiredSatisfied: Bool {
        return personalInformation && koin
    }

    var isAllSelected: Bool {
        return isRequiredSatisfied && marketing
    }

    subscript(agreement: AgreementText) -> Bool {
        get {
            switch agreement {
            case .personalInformation: return personalInformation
            case .koin: return koin
            case .marketing: return marketing
            }
        }
        set {
            switch agreement {
            case .personalInformation: personalInformation = newValue
            case .koin: koin = newValue
            case .marketing: marketing = newValue
            }
        }
    }

    mutating func toggle(_ agreement: AgreementText) -> Bool {
        self[agreement].toggle()
        return agreement == .marketing && marketing
    }

    mutating func toggleAll() -> Bool {
        let next = !isAllSelected
        let marketingNewlyAgreed = next && !marketing

        personalInformation = next
        koin = next
        marketing = next

        return marketingNewlyAgreed
    }
}
