//
//  AgreementSelectionTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/10/26.
//

import Foundation
import Testing
@testable import koin

@Suite("AgreementSelection - 약관 동의 상태 규칙")
struct AgreementSelectionTests {

    @Test(
        "필수 약관을 모두 동의해야 다음 단계로 넘어갈 수 있다",
        arguments: [
            (false, false, false, false),
            (true, false, false, false),
            (false, true, false, false),
            (false, false, true, false),
            (true, true, false, true),
            (true, true, true, true)
        ]
    )
    func 필수_약관을_모두_동의해야_다음_단계로_넘어갈_수_있다(
        personalInformation: Bool, koin: Bool, marketing: Bool, expected: Bool
    ) {
        let sut = AgreementSelection(personalInformation: personalInformation, koin: koin, marketing: marketing)

        #expect(sut.isRequiredSatisfied == expected)
    }

    @Test("선택 약관은 다음 단계 진입을 막지 않는다")
    func 선택_약관은_다음_단계_진입을_막지_않는다() {
        var sut = AgreementSelection(personalInformation: true, koin: true)
        #expect(sut.isRequiredSatisfied)

        _ = sut.toggle(.marketing)
        #expect(sut.isRequiredSatisfied)

        _ = sut.toggle(.marketing)
        #expect(sut.isRequiredSatisfied)
    }

    @Test("필수 약관을 해제하면 다시 진입이 막힌다")
    func 필수_약관을_해제하면_다시_진입이_막힌다() {
        var sut = AgreementSelection(personalInformation: true, koin: true, marketing: true)

        _ = sut.toggle(.personalInformation)

        #expect(sut.isRequiredSatisfied == false)
    }

    @Test("필수만 동의한 상태는 전체 동의로 보지 않는다")
    func 필수만_동의한_상태는_전체_동의로_보지_않는다() {
        let sut = AgreementSelection(personalInformation: true, koin: true)

        #expect(sut.isAllSelected == false)
    }

    @Test("모두 동의는 미선택 항목을 전부 채운다")
    func 모두_동의는_미선택_항목을_전부_채운다() {
        var sut = AgreementSelection(personalInformation: true, koin: true)

        _ = sut.toggleAll()

        #expect(sut.isAllSelected)
    }

    @Test("모두 동의를 다시 누르면 전부 해제한다")
    func 모두_동의를_다시_누르면_전부_해제한다() {
        var sut = AgreementSelection(personalInformation: true, koin: true, marketing: true)

        _ = sut.toggleAll()

        #expect(sut == AgreementSelection())
    }

    @Test("모두 동의를 두 번 누르면 원래 상태로 돌아온다")
    func 모두_동의를_두_번_누르면_원래_상태로_돌아온다() {
        var sut = AgreementSelection()

        _ = sut.toggleAll()
        _ = sut.toggleAll()

        #expect(sut == AgreementSelection())
    }

    @Test("모두 동의로 마케팅에 새로 동의하면 푸시 권한 요청을 알린다")
    func 모두_동의로_마케팅에_새로_동의하면_푸시_권한_요청을_알린다() {
        var sut = AgreementSelection(personalInformation: true, koin: true)

        let shouldRequest = sut.toggleAll()

        #expect(shouldRequest)
    }

    @Test("이미 마케팅에 동의 중이면 푸시 권한을 다시 요청하지 않는다")
    func 이미_마케팅에_동의_중이면_푸시_권한을_다시_요청하지_않는다() {
        var sut = AgreementSelection(marketing: true)

        let shouldRequest = sut.toggleAll()

        #expect(shouldRequest == false)
        #expect(sut.isAllSelected)
    }

    @Test("마케팅 약관을 개별 동의하면 푸시 권한 요청을 알린다")
    func 마케팅_약관을_개별_동의하면_푸시_권한_요청을_알린다() {
        var sut = AgreementSelection()

        let shouldRequest = sut.toggle(.marketing)

        #expect(shouldRequest)
    }

    @Test("마케팅 약관을 해제할 때는 푸시 권한을 요청하지 않는다")
    func 마케팅_약관을_해제할_때는_푸시_권한을_요청하지_않는다() {
        var sut = AgreementSelection(marketing: true)

        let shouldRequest = sut.toggle(.marketing)

        #expect(shouldRequest == false)
    }

    @Test(
        "필수 약관 동의는 푸시 권한 요청과 무관하다",
        arguments: AgreementText.required
    )
    func 필수_약관_동의는_푸시_권한_요청과_무관하다(agreement: AgreementText) {
        var sut = AgreementSelection()

        let shouldRequest = sut.toggle(agreement)

        #expect(shouldRequest == false)
    }

    @Test(
        "같은 항목을 두 번 토글하면 원래 값으로 돌아온다",
        arguments: AgreementText.allCases
    )
    func 같은_항목을_두_번_토글하면_원래_값으로_돌아온다(agreement: AgreementText) {
        var sut = AgreementSelection()

        _ = sut.toggle(agreement)
        _ = sut.toggle(agreement)

        #expect(sut == AgreementSelection())
    }
}

extension AgreementSelectionTests {
    private func storedValue(of agreement: AgreementText, in selection: AgreementSelection) -> Bool {
        switch agreement {
        case .personalInformation: return selection.personalInformation
        case .koin: return selection.koin
        case .marketing: return selection.marketing
        }
    }
}
