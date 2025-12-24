//
//  ShopCoordinator.swift
//  koin
//
//  Created by 김성민 on 12/20/25.
//

import UIKit
import Combine

final class ShopCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    private let factory: ShopFactory
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController, factory: ShopFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() {
        navigateToShop(categoryId: 1)
    }
    
    func navigateToShop(categoryId: Int) {
        let shopViewController = factory.makeShopViewController(selectedId: categoryId)
        shopViewController.coordinator = self
        navigationController.pushViewController(shopViewController, animated: true)
    }
    
    func navigateToShopSummary(shopId: Int, shopName: String, categoryName: String?) {
        let shopSummaryViewController = factory.makeShopSummaryViewController(
            selectedCategoryName: categoryName,
            shopId: shopId,
            shopName: shopName
        )
        shopSummaryViewController.coordinator = self
        
        navigationController.pushViewController(shopSummaryViewController, animated: true)
    }
    
    func navigateToShopSearch(categoryName: String) {
        let shopSearchViewController = factory.makeShopSearchViewController(selectedCategoryName: categoryName)
        shopSearchViewController.coordinator = self
        navigationController.pushViewController(shopSearchViewController, animated: true)
    }
    
    func navigateToShopDetail(shopId: Int, shouldHighlight: ShopDetailTableView.HighlightableCell) {
        let shopDetailViewController = factory.makeShopDetailViewController(
            shopId: shopId,
            shouldHighlight: shouldHighlight
        )
        navigationController.pushViewController(shopDetailViewController, animated: true)
    }
    
    func navigateToReviewList(shopId: Int, shopName: String) {
        let reviewListViewController = factory.makeReviewListViewController(shopId: shopId, shopName: shopName)
        reviewListViewController.coordinator = self
        navigationController.pushViewController(reviewListViewController, animated: true)
    }
    
    func navigateToShopReview(shopId: Int, shopName: String, reviewId: Int? = nil, completion: ((Bool, Int?, WriteReviewRequest) -> Void)? = nil) {
        let shopReviewViewController = factory.makeShopReviewViewController(
            reviewId: reviewId,
            shopId: shopId,
            shopName: shopName
        )
        
        shopReviewViewController.writeCompletePublisher
            .sink { result in
                completion?(result.0, result.1, result.2)
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(shopReviewViewController, animated: true)
    }
    
    func navigateToReviewReport(reviewId: Int, shopId: Int, shopName: String, completion: ((Int, Int) -> Void)? = nil) {
        let shopReviewReportViewController = factory.makeShopReviewReportViewController(
            reviewId: reviewId,
            shopId: shopId,
            shopName: shopName
        )
        
        shopReviewReportViewController.reviewInfoPublisher
            .sink { result in
                completion?(result.0, result.1)
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(shopReviewReportViewController, animated: true)
    }
    
    func showSortOptionSheet(currentType: ShopSortType, onSelect: @escaping (ShopSortType) -> Void) {
        let shopSortOptionSheetViewController = factory.makeShopSortOptionSheetViewController(
            currentSortType: currentType,
            onOptionSelected: onSelect
        )
        navigationController.present(shopSortOptionSheetViewController, animated: true)
    }
    
    func showSortTypeBottomSheet(options: [String], selectedIndex: Int, onSelect: @escaping (Int) -> Void) {
        let sortTypeBottomSheetViewController = factory.makeSortTypeBottomSheetViewController(
            options: options,
            selectedIndex: selectedIndex,
            onSelection: onSelect
        )
        navigationController.present(sortTypeBottomSheetViewController, animated: true)
    }
    
    func showLoginModal(type: MessageType, onLogin: @escaping () -> Void, onCancel: (() -> Void)?) {
        let reviewLoginModalViewController = factory.makeReviewLoginModalViewController(
            messageType: type.rawValue,
            onLoginButtonTapped: onLogin,
            onCancelButtonTapped: onCancel
        )
        navigationController.present(reviewLoginModalViewController, animated: true)
    }
    
    func showDeleteReviewModal(onDelete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let deleteReviewModalViewController = factory.makeDeleteReviewModalViewController(
            onDeleteButtonTapped: onDelete,
            onCancelButtonTapped: onCancel
        )
        navigationController.present(deleteReviewModalViewController, animated: true)
    }
    
    func showBackButtonPopup(onStop: @escaping () -> Void) {
        let backButtonPopUpViewController = factory.makeBackButtonPopUpViewController(onStop: onStop)
        navigationController.present(backButtonPopUpViewController, animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.removeChild(self)
    }
}
