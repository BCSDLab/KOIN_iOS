//
//  DepartmentCategoryHostingController.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import SwiftUI

final class DepartmentCategoryHostingController: UIHostingController<DepartmentCategoryView>, HostingControllerProtocol {
    
    // MARK: - Initializer
    override init(rootView: DepartmentCategoryView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
    }
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "학교 부서정보"
        configureNavigationBar(style: .order)
    }
    
    // MARK: - Execute
    func execute(action: DepartmentCategoryView.Action) {
        switch action {
        case .showDepartment(let category):
            navigationController?.pushViewController(makeDepartmentHostingController(category: category), animated: true)
        case .showCopyToast:
            showToastMessage(message: "클립보드에 복사되었습니다.")
        case .showToast(let message):
            showToastMessage(message: message)
        }
    }
}

extension DepartmentCategoryHostingController {
    private func makeDepartmentHostingController(category: DepartmentCategory) -> UIViewController {
        let repository = DefaultDepartmentRepository(service: DefaultDepartmentService())
        let fetchDepartmentByCategoryUseCase = DefaultFetchDepartmentByCategoryUseCase(repository: repository)
        let searchDepartmentByCategoryUseCase = DefaultSearchDepartmentByCategoryUseCase(repository: repository)
        let viewModel = DepartmentViewModel(
            fetchDepartmentByCategoryUseCase: fetchDepartmentByCategoryUseCase,
            searchDepartmentByCategoryUseCase: searchDepartmentByCategoryUseCase,
            category: category
        )
        let rootView = DepartmentView(viewModel: viewModel)
        let viewController = DepartmentHostingController(rootView: rootView)
        viewController.title = category.rawValue
        return viewController
    }
}
