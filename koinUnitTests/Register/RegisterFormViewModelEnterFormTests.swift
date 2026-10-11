//
//  RegisterFormViewModelEnterFormTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/19/26.
//

import Combine
import Foundation
import Testing
@testable import koin

@Suite("RegisterFormViewModel - 정보 입력 요청")
struct RegisterFormViewModelEnterFormTests {

    private let loginId = "koinuser"
    private let nickname = "코인"

    // MARK: - 아이디 중복 확인

    @Test("아이디 중복 확인 입력을 UseCase로 전달한다")
    func 아이디_중복_확인_입력을_UseCase로_전달한다() {
        let spy = SpyCheckDuplicatedIdUseCase()
        let recorder = OutputRecorder(.makeForEnterForm(checkDuplicatedIdUseCase: spy))

        recorder.send(.checkDuplicatedId(loginId))

        #expect(spy.receivedLoginIds == [loginId])
    }

    @Test("사용 가능한 아이디면 확인한 아이디와 함께 성공을 알린다")
    func 사용_가능한_아이디면_확인한_아이디와_함께_성공을_알린다() {
        let spy = SpyCheckDuplicatedIdUseCase()
        spy.stubbedResult = .success(())
        let recorder = OutputRecorder(.makeForEnterForm(checkDuplicatedIdUseCase: spy))

        recorder.send(.checkDuplicatedId(loginId))

        #expect(checkedLoginIds(in: recorder) == [loginId])
    }

    @Test("중복된 아이디면 확인한 아이디와 함께 오류 문구를 전달한다")
    func 중복된_아이디면_확인한_아이디와_함께_오류_문구를_전달한다() {
        let spy = SpyCheckDuplicatedIdUseCase()
        spy.stubbedResult = .failure(ErrorResponse(statusCode: 409, code: "409", message: "이미 사용 중인 아이디입니다."))
        let recorder = OutputRecorder(.makeForEnterForm(checkDuplicatedIdUseCase: spy))

        recorder.send(.checkDuplicatedId(loginId))

        let results = recorder.outputs.compactMap { output -> [String]? in
            if case let .showIdHttpResult(loginId, message, _) = output { return [loginId, message] }
            return nil
        }
        #expect(results == [[loginId, "이미 사용 중인 아이디입니다."]])
    }

    @Test("여러 아이디를 확인하면 각 응답이 자기 아이디를 담는다")
    func 여러_아이디를_확인하면_각_응답이_자기_아이디를_담는다() {
        let spy = SpyCheckDuplicatedIdUseCase()
        spy.stubbedResult = .success(())
        let recorder = OutputRecorder(.makeForEnterForm(checkDuplicatedIdUseCase: spy))

        recorder.send(.checkDuplicatedId("koinusera"))
        recorder.send(.checkDuplicatedId("koinuserb"))

        #expect(checkedLoginIds(in: recorder) == ["koinusera", "koinuserb"])
    }

    // MARK: - 학부 목록

    @Test("학부 목록을 받아 드롭다운 목록으로 전달한다")
    func 학부_목록을_받아_드롭다운_목록으로_전달한다() {
        let spy = SpyFetchDeptListUseCase()
        spy.stubbedResult = .success(["컴퓨터공학부", "기계공학부"])
        let recorder = OutputRecorder(.makeForEnterForm(fetchDeptListUseCase: spy))

        recorder.send(.getDeptList)

        let deptLists = recorder.outputs.compactMap { output -> [String]? in
            if case let .showDeptDropDownList(list) = output { return list }
            return nil
        }
        #expect(spy.executeCallCount == 1)
        #expect(deptLists == [["컴퓨터공학부", "기계공학부"]])
    }

    @Test("학부 목록을 받지 못하면 아무것도 전달하지 않는다")
    func 학부_목록을_받지_못하면_아무것도_전달하지_않는다() {
        let spy = SpyFetchDeptListUseCase()
        spy.stubbedResult = .failure(ErrorResponse(statusCode: 500, code: "500", message: "서버 오류"))
        let recorder = OutputRecorder(.makeForEnterForm(fetchDeptListUseCase: spy))

        recorder.send(.getDeptList)

        #expect(recorder.outputs.isEmpty)
    }

    // MARK: - 닉네임 중복 확인

    @Test("닉네임 중복 확인 입력을 UseCase로 전달한다")
    func 닉네임_중복_확인_입력을_UseCase로_전달한다() {
        let spy = SpyCheckDuplicatedNicknameUseCase()
        let recorder = OutputRecorder(.makeForEnterForm(checkDuplicatedNicknameUseCase: spy))

        recorder.send(.checkDuplicatedNickname(nickname))

        #expect(spy.receivedNicknames == [nickname])
    }

    @Test("사용 가능한 닉네임이면 중복 확인 버튼 상태 변경을 알린다")
    func 사용_가능한_닉네임이면_중복_확인_버튼_상태_변경을_알린다() {
        let spy = SpyCheckDuplicatedNicknameUseCase()
        spy.stubbedResult = .success(())
        let recorder = OutputRecorder(.makeForEnterForm(checkDuplicatedNicknameUseCase: spy))

        recorder.send(.checkDuplicatedNickname(nickname))

        #expect(recorder.outputs.contains { if case .changeCheckButtonStatus = $0 { return true } else { return false } })
    }

    @Test("중복된 닉네임이면 오류 문구를 그대로 전달한다")
    func 중복된_닉네임이면_오류_문구를_그대로_전달한다() {
        let spy = SpyCheckDuplicatedNicknameUseCase()
        spy.stubbedResult = .failure(ErrorResponse(statusCode: 409, code: "409", message: "이미 존재하는 닉네임입니다."))
        let recorder = OutputRecorder(.makeForEnterForm(checkDuplicatedNicknameUseCase: spy))

        recorder.send(.checkDuplicatedNickname(nickname))

        let messages = recorder.outputs.compactMap { output -> String? in
            if case let .showNicknameHttpResult(message, _) = output { return message }
            return nil
        }
        #expect(messages == ["이미 존재하는 닉네임입니다."])
    }
}

extension RegisterFormViewModelEnterFormTests {
    private func checkedLoginIds(in recorder: OutputRecorder) -> [String] {
        recorder.outputs.compactMap { output -> String? in
            if case let .successCheckDuplicatedId(loginId) = output { return loginId }
            return nil
        }
    }
}

@Suite("RegisterFormViewModel - 가입 요청")
struct RegisterFormViewModelRegisterTests {

    // "koin1234!"의 SHA-256
    private let hashedPassword = "309ae10d45a75af9d1bd44d105e75a65acb83edb7981e43bb8ce6a36dcc5fb20"

    // MARK: - 학생 가입

    @Test("학생 가입 요청은 비밀번호를 SHA-256으로 바꿔 전달한다")
    func 학생_가입_요청은_비밀번호를_SHA256으로_바꿔_전달한다() {
        let spy = SpyRegisterFormUseCase()
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryStudentRegister(studentRequest()))

        #expect(
            spy.studentRequests == [
                .init(
                    name: "이코인",
                    phoneNumber: "01012345678",
                    loginId: "koinuser",
                    password: hashedPassword,
                    department: "컴퓨터공학부",
                    studentNumber: "2021136001",
                    gender: "1",
                    email: "koinuser@koreatech.ac.kr",
                    nickname: "코인"
                )
            ]
        )
    }

    @Test(
        "학생 이메일은 아이디 부분에 학교 도메인을 붙이고, 비어 있으면 보내지 않는다",
        arguments: [("koinuser", "koinuser@koreatech.ac.kr"), ("", nil), (nil, nil)] as [(String?, String?)]
    )
    func 학생_이메일은_학교_도메인을_붙이고_비어_있으면_보내지_않는다(email: String?, expected: String?) {
        let spy = SpyRegisterFormUseCase()
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryStudentRegister(studentRequest(email: email)))

        #expect(spy.studentRequests.first?.email == expected)
    }

    @Test("학생 가입 시 빈 닉네임은 보내지 않는다")
    func 학생_가입_시_빈_닉네임은_보내지_않는다() {
        let spy = SpyRegisterFormUseCase()
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryStudentRegister(studentRequest(nickname: "")))

        #expect(spy.studentRequests.first?.nickname == nil)
    }

    // MARK: - 외부인 가입

    @Test("외부인 가입 요청은 비밀번호를 SHA-256으로 바꿔 전달한다")
    func 외부인_가입_요청은_비밀번호를_SHA256으로_바꿔_전달한다() {
        let spy = SpyRegisterFormUseCase()
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryGeneralRegister(generalRequest()))

        #expect(
            spy.generalRequests == [
                .init(
                    name: "이코인",
                    phoneNumber: "01012345678",
                    loginId: "koinuser",
                    gender: "0",
                    password: hashedPassword,
                    email: "koin@gmail.com",
                    nickname: "코인"
                )
            ]
        )
    }

    @Test("외부인 가입 시 빈 이메일과 빈 닉네임은 보내지 않는다")
    func 외부인_가입_시_빈_이메일과_빈_닉네임은_보내지_않는다() {
        let spy = SpyRegisterFormUseCase()
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryGeneralRegister(generalRequest(email: "", nickname: "")))

        #expect(spy.generalRequests.first?.email == nil)
        #expect(spy.generalRequests.first?.nickname == nil)
    }

    // MARK: - 가입 결과

    @Test("가입에 성공하면 성공을 알린다")
    func 가입에_성공하면_성공을_알린다() {
        let spy = SpyRegisterFormUseCase()
        spy.stubbedResult = .success(())
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryStudentRegister(studentRequest()))
        recorder.send(.tryGeneralRegister(generalRequest()))

        let successCount = recorder.outputs.filter { if case .succesRegister = $0 { return true } else { return false } }.count
        #expect(successCount == 2)
    }

    @Test("학생 가입에 실패하면 오류 문구를 전달한다")
    func 학생_가입에_실패하면_오류_문구를_전달한다() {
        let spy = SpyRegisterFormUseCase()
        spy.stubbedResult = .failure(ErrorResponse(statusCode: 500, code: "500", message: "서버 오류가 발생했습니다."))
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryStudentRegister(studentRequest()))

        let messages = recorder.outputs.compactMap { output -> String? in
            if case let .failRegister(message) = output { return message }
            return nil
        }
        #expect(messages == ["서버 오류가 발생했습니다."])
    }

    @Test("외부인 가입에 실패하면 오류 문구를 전달한다")
    func 외부인_가입에_실패하면_오류_문구를_전달한다() {
        let spy = SpyRegisterFormUseCase()
        spy.stubbedResult = .failure(ErrorResponse(statusCode: 500, code: "500", message: "서버 오류가 발생했습니다."))
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryGeneralRegister(generalRequest()))

        let messages = recorder.outputs.compactMap { output -> String? in
            if case let .failRegister(message) = output { return message }
            return nil
        }
        #expect(messages == ["서버 오류가 발생했습니다."])
    }

    @Test("가입에 실패하면 성공을 알리지 않는다")
    func 가입에_실패하면_성공을_알리지_않는다() {
        let spy = SpyRegisterFormUseCase()
        spy.stubbedResult = .failure(ErrorResponse(statusCode: 500, code: "500", message: "서버 오류가 발생했습니다."))
        let recorder = OutputRecorder(.makeForEnterForm(registerFormUseCase: spy))

        recorder.send(.tryStudentRegister(studentRequest()))
        recorder.send(.tryGeneralRegister(generalRequest()))

        #expect(recorder.outputs.contains { if case .succesRegister = $0 { return true } else { return false } } == false)
    }
}

extension RegisterFormViewModelRegisterTests {
    private func studentRequest(
        email: String? = "koinuser",
        nickname: String? = "코인"
    ) -> StudentRegisterFormRequest {
        StudentRegisterFormRequest(
            name: "이코인",
            phoneNumber: "01012345678",
            loginId: "koinuser",
            password: "koin1234!",
            department: "컴퓨터공학부",
            studentNumber: "2021136001",
            gender: "1",
            email: email,
            nickname: nickname
        )
    }

    private func generalRequest(
        email: String? = "koin@gmail.com",
        nickname: String? = "코인"
    ) -> GeneralRegisterFormRequest {
        GeneralRegisterFormRequest(
            name: "이코인",
            phoneNumber: "01012345678",
            loginId: "koinuser",
            gender: "0",
            password: "koin1234!",
            email: email,
            nickname: nickname
        )
    }
}
