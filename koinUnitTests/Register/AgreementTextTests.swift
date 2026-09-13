//
//  AgreementTextTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/10/26.
//

import Foundation
import Testing
@testable import koin

@Suite("AgreementText - 약관 메타데이터")
struct AgreementTextTests {

    @Test(
        "필수 약관의 제목에는 (필수)가 표기된다",
        arguments: AgreementText.required
    )
    func 필수_약관의_제목에는_필수가_표기된다(agreement: AgreementText) {
        #expect(agreement.title.contains("(필수)"))
    }

    @Test("선택 약관의 제목에는 (선택)이 표기된다")
    func 선택_약관의_제목에는_선택이_표기된다() {
        let optionalAgreements = AgreementText.allCases.filter { !AgreementText.required.contains($0) }

        #expect(optionalAgreements.isEmpty == false)
        for agreement in optionalAgreements {
            #expect(agreement.title.contains("(선택)"))
        }
    }

    @Test(
        "세 약관 모두 제목과 본문을 가진다",
        arguments: AgreementText.allCases
    )
    func 세_약관_모두_제목과_본문을_가진다(agreement: AgreementText) {
        #expect(agreement.title.isEmpty == false)
        #expect(agreement.description.isEmpty == false)
    }

    @Test("세 약관의 본문이 서로 다르다")
    func 세_약관의_본문이_서로_다르다() {
        let bodies = Set(AgreementText.allCases.map(\.description))

        #expect(bodies.count == AgreementText.allCases.count)
    }
}
