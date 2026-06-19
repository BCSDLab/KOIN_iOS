import Foundation

protocol AppLaunchPresentationUseCase {
    func execute() async -> AppLaunchPresentation
}

final class DefaultAppLaunchPresentationUseCase: AppLaunchPresentationUseCase {

    private let checkVersionUseCase: CheckVersionUseCase
    private let checkModifyUserNeededUseCase: CheckModifyUserNeededUseCase

    init(
        checkVersionUseCase: CheckVersionUseCase,
        checkModifyUserNeededUseCase: CheckModifyUserNeededUseCase
    ) {
        self.checkVersionUseCase = checkVersionUseCase
        self.checkModifyUserNeededUseCase = checkModifyUserNeededUseCase
    }
    
    func execute() async -> AppLaunchPresentation {
        if let (shouldUpdate, version) = try? await checkVersionUseCase.execute().async(),
           shouldUpdate {
            return .forceUpdate(requiredVersion: version)
        }
        let shouldModifyUser = await checkModifyUserNeededUseCase.execute().async()
        return shouldModifyUser ? .forceModifyUser : .none
    }
}
