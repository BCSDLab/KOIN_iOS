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
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
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
        viewController.title = "주변상점"
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
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let viewModel = ShopSummaryViewModel(
            fetchOrderShopSummaryFromShopUseCase: fetchOrderShopSummaryFromShopUseCase,
            fetchOrderShopMenusAndGroupsFromShopUseCase: fetchOrderShopMenusAndGroupsFromShopUseCase,
            fetchShopDataUseCase: fetchShopDataUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            shopId: shopId,
            shopName: shopName)
        let viewController = ShopSummaryViewController(
            viewModel: viewModel,
            backCategoryName: selectedCategoryName)
        viewController.title = shopName
        return viewController
    }
    
    func makeShopSearchViewController(selectedCategoryName: String) -> ShopSearchViewController {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchSearchShopUseCase = DefaultFetchSearchShopUseCase(repository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = ShopSearchViewModel(
            fetchSearchShopUseCase: fetchSearchShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            selectedCategoryName: selectedCategoryName)
        return ShopSearchViewController(viewModel: viewModel)
    }
    
    func makeShopSortOptionSheetViewController(
        currentSortType: ShopSortType,
        onOptionSelected: @escaping ((ShopSortType) -> Void)
    ) -> ShopSortOptionSheetViewController {
        let bottomSheetViewController = ShopSortOptionSheetViewController(current: currentSortType)
        bottomSheetViewController.onOptionSelected = onOptionSelected
        bottomSheetViewController.modalPresentationStyle = .pageSheet
        if let sheet = bottomSheetViewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent.custom(identifier: .init("fixed233")) { _ in 233 }
                sheet.detents = [detent]
                sheet.selectedDetentIdentifier = detent.identifier
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 32
        }
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
                                            shopId: shopId)
        let viewController = ShopDetailViewController(viewModel: viewModel, shouldHighlight: shouldHighlight)
        viewController.title = "가게정보"
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
        let logAnalyticsEventUseCae = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = ShopReviewReportViewModel(
            reportReviewReviewUseCase: reportReviewReviewUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCae,
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
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
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
        let viewController = BackButtonPopUpViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        viewController.onStop = onStop
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
        reviewListViewController.title = "리뷰"
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
        reviewWriteLoginModalViewController.modalPresentationStyle = .overFullScreen
        reviewWriteLoginModalViewController.modalTransitionStyle = .crossDissolve
        return reviewWriteLoginModalViewController
    }
    
    func makeDeleteReviewModalViewController(
        onDeleteButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: @escaping ()->Void
    ) -> DeleteReviewModalViewController {
        let deleteReviewModalViewController = DeleteReviewModalViewController(
            onDeleteButtonTapped: onDeleteButtonTapped,
            onCancelButtonTapped: onCancelButtonTapped)
        deleteReviewModalViewController.modalPresentationStyle = .overFullScreen
        deleteReviewModalViewController.modalTransitionStyle = .crossDissolve
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
