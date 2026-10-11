//
//  DepartmentHostingController.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

final class DepartmentHostingController: UIHostingController<DepartmentView>, HostingControllerProtocol {
    
    // MARK: - Initializer
    override init(rootView: DepartmentView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
    }
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
    }
    
    // MARK: - Execute
    func execute(action: DepartmentView.Action) {
        switch action {
        case .showCopyToast:
            showToastMessage(message: "클립보드에 복사되었습니다.")
        }
    }
}
