//
//  DIConatiner+Shop.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import UIKit

enum MessageType: String {
    case write = "작성"
    case report = "신고"
}

protocol ShopFactory {
    
    func makeShopViewController(selectedId: Int) -> ShopViewController
    
    func makeShopSummaryViewController(
        selectedCategoryName: String?,
        shopId: Int,
        shopName: String
    ) -> ShopSummaryViewController
    
    func makeShopSearchViewController(selectedCategoryName: String) -> ShopSearchViewController
    
    func makeShopSortOptionSheetViewController(
        currentSortType: ShopSortType,
        onOptionSelected: @escaping ((ShopSortType) -> Void)
    ) -> ShopSortOptionSheetViewController
    
    func makeShopDetailViewController(
        shopId: Int,
        shouldHighlight: ShopDetailTableView.HighlightableCell
    ) -> ShopDetailViewController
    
    func makeShopReviewViewController(
        reviewId: Int?,
        shopId: Int,
        shopName: String,
        completion: @escaping (Bool, Int?, WriteReviewRequest) -> Void
    ) -> ShopReviewViewController
    
    func makeReviewListViewController(
        shopId: Int,
        shopName: String
    ) -> ReviewListViewController
        
    func makeShopReviewReportViewController(
        reviewId: Int,
        shopId: Int,
        shopName: String,
        completion: @escaping (Int, Int) -> Void
    ) -> ShopReviewReportViewController
    
    func makeBackButtonPopUpViewController(onStop: @escaping () -> Void) -> BackButtonPopUpViewController

    func makeReviewLoginModalViewController(
        messageType: String,
        onLoginButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: (()->Void)?
    ) -> ReviewLoginModalViewController
    
    func makeDeleteReviewModalViewController(
        onDeleteButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: @escaping ()->Void
    ) -> DeleteReviewModalViewController
    
    func makeSortTypeBottomSheetViewController(
        options: [String],
        selectedIndex: Int,
        onSelection: @escaping (Int)->Void
    ) -> SortTypeBottomSheetViewController
}

extension DIContainer: ShopFactory {
    
    func makeShopViewController(selectedId: Int = 1) -> ShopViewController {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
        let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = resolve(type: LogAnalyticsEventUseCase.self)
        let getUserScreenTimeUseCase = resolve(type: GetUserScreenTimeUseCase.self)
        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            selectedId: selectedId
        )
        let viewController = ShopViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeShopSummaryViewController(
        selectedCategoryName: String? = nil,
        shopId: Int,
        shopName: String
    ) -> ShopSummaryViewController {
        let service = DefaultShopService()
        let repository = DefaultShopRepository(service: service)
        let fetchOrderShopSummaryFromShopUseCase = DefaultFetchOrderShopSummaryFromShopUseCase(repository: repository)
        let fetchOrderShopMenusAndGroupsFromShopUseCase = DefaultFetchOrderShopMenusAndGroupsFromShopUseCase(shopRepository: repository)
        let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: repository)
        let logAnalyticsEventUseCase = resolve(type: LogAnalyticsEventUseCase.self)
        let getUserScreenTimeUseCase = resolve(type: GetUserScreenTimeUseCase.self)
        let viewModel = ShopSummaryViewModel(
            fetchOrderShopSummaryFromShopUseCase: fetchOrderShopSummaryFromShopUseCase,
            fetchOrderShopMenusAndGroupsFromShopUseCase: fetchOrderShopMenusAndGroupsFromShopUseCase,
            fetchShopDataUseCase: fetchShopDataUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            shopId: shopId,
            shopName: shopName,
            backCategoryName: selectedCategoryName
        )
        let viewController = ShopSummaryViewController(viewModel: viewModel)
        viewController.title = shopName
        return viewController
    }
    
    func makeShopSearchViewController(selectedCategoryName: String) -> ShopSearchViewController {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchSearchShopUseCase = DefaultFetchSearchShopUseCase(repository: shopRepository)
        let logAnalyticsEventUseCase = resolve(type: LogAnalyticsEventUseCase.self)
        let viewModel = ShopSearchViewModel(
            fetchSearchShopUseCase: fetchSearchShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            selectedCategoryName: selectedCategoryName
        )
        return ShopSearchViewController(viewModel: viewModel)
    }
    
    func makeShopSortOptionSheetViewController(
        currentSortType: ShopSortType,
        onOptionSelected: @escaping ((ShopSortType) -> Void)
    ) -> ShopSortOptionSheetViewController {
        let bottomSheetViewController = ShopSortOptionSheetViewController(current: currentSortType, onOptionSelected: onOptionSelected)
        return bottomSheetViewController
    }
    
    func makeShopDetailViewController(
        shopId: Int,
        shouldHighlight: ShopDetailTableView.HighlightableCell
    ) -> ShopDetailViewController {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchOrderShopDetailFromShopUseCase = DefaultFetchOrderShopDetailFromShopUseCase(repository: shopRepository)
        let viewModel = ShopDetailViewModel(fetchOrderShopDetailFromShopUseCase: fetchOrderShopDetailFromShopUseCase,
                                            shopId: shopId,
                                            shouldHighlight: shouldHighlight
        )
        let viewController = ShopDetailViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeShopReviewReportViewController(
        reviewId: Int,
        shopId: Int,
        shopName: String,
        completion: @escaping (Int, Int) -> Void
    ) -> ShopReviewReportViewController {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let reportReviewReviewUseCase = DefaultReportReviewUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = resolve(type: LogAnalyticsEventUseCase.self)
        let viewModel = ShopReviewReportViewModel(
            reportReviewReviewUseCase: reportReviewReviewUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            reviewId: reviewId,
            shopId: shopId,
            shopName: shopName,
            completion: completion
        )
        return ShopReviewReportViewController(viewModel: viewModel)
    }
    
    func makeShopReviewViewController(
        reviewId: Int? = nil,
        shopId: Int,
        shopName: String,
        completion: @escaping (Bool, Int?, WriteReviewRequest) -> Void
    ) -> ShopReviewViewController {
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let postReviewUseCase = DefaultPostReviewUseCase(shopRepository: shopRepository)
        let modifyReviewUseCase = DefaultModifyReviewUseCase(shopRepository: shopRepository)
        let fetchShopReviewUseCase = DefaultFetchShopReviewUseCase(shopRepository: shopRepository)
        let uploadFileUseCase = DefaultUploadFileUseCase(shopRepository: shopRepository)
        let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = resolve(type: LogAnalyticsEventUseCase.self)
        let getUserScreenTimeUseCase = resolve(type: GetUserScreenTimeUseCase.self)
        let viewModel = ShopReviewViewModel(
            postReviewUseCase: postReviewUseCase,
            modifyReviewUseCase: modifyReviewUseCase,
            fetchShopReviewUseCase: fetchShopReviewUseCase,
            uploadFileUseCase: uploadFileUseCase,
            fetchShopDataUseCase: fetchShopDataUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            reviewId: reviewId,
            shopId: shopId,
            shopName: shopName,
            completion: completion
        )
        return ShopReviewViewController(viewModel: viewModel)
    }
    
    func makeBackButtonPopUpViewController(onStop: @escaping () -> Void) -> BackButtonPopUpViewController {
        let viewController = BackButtonPopUpViewController(onStop: onStop)
        return viewController
    }
    
    func makeReviewListViewController(
        shopId: Int,
        shopName: String
    ) -> ReviewListViewController {
        let reviewListViewController = ReviewListViewController(
            shopId: shopId,
            shopName: shopName
        )
        return reviewListViewController
    }
    
    func makeReviewLoginModalViewController(
        messageType: String,
        onLoginButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: (()->Void)?
    ) -> ReviewLoginModalViewController {
        let reviewWriteLoginModalViewController = ReviewLoginModalViewController(
            message: messageType,
            onLoginButtonTapped: onLoginButtonTapped,
            onCancelButtonTapped: onCancelButtonTapped
        )
        return reviewWriteLoginModalViewController
    }
    
    func makeDeleteReviewModalViewController(
        onDeleteButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: @escaping ()->Void
    ) -> DeleteReviewModalViewController {
        let deleteReviewModalViewController = DeleteReviewModalViewController(
            onDeleteButtonTapped: onDeleteButtonTapped,
            onCancelButtonTapped: onCancelButtonTapped
        )
        return deleteReviewModalViewController
    }
    
    func makeSortTypeBottomSheetViewController(
        options: [String],
        selectedIndex: Int = 0,
        onSelection: @escaping (Int)->Void
    ) -> SortTypeBottomSheetViewController {
        let bottomSheetViewController = SortTypeBottomSheetViewController(
            options: options,
            selectedIndex: selectedIndex,
            onSelection: onSelection
        )
        return bottomSheetViewController
    }
}
