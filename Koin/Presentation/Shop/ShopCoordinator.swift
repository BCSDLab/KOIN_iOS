//
//  ShopCoordinator.swift
//  koin
//
//  Created by 김성민 on 12/20/25.
//

import UIKit

final class ShopCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    private weak var rootViewController: UIViewController?
    
    private let factory: ShopFactory
    
    init(navigationController: UINavigationController, factory: ShopFactory) {
        self.navigationController = navigationController
        self.factory = factory
        super.init()
        self.navigationController.delegate = self
    }
    
    func start() {
        pushShopViewController(categoryId: 1)
    }
    
    func pushShopViewController(categoryId: Int) {
        let shopViewController = factory.makeShopViewController(selectedId: categoryId)
        shopViewController.coordinator = self
        self.rootViewController = shopViewController
        navigationController.pushViewController(shopViewController, animated: true)
    }
    
    func pushShopSummaryViewController(shopId: Int, shopName: String, categoryName: String?) {
        let shopSummaryViewController = factory.makeShopSummaryViewController(
            selectedCategoryName: categoryName,
            shopId: shopId,
            shopName: shopName
        )
        shopSummaryViewController.coordinator = self
        
        navigationController.pushViewController(shopSummaryViewController, animated: true)
    }
    
    func pushShopSearchViewController(categoryName: String) {
        let shopSearchViewController = factory.makeShopSearchViewController(selectedCategoryName: categoryName)
        shopSearchViewController.coordinator = self
        navigationController.pushViewController(shopSearchViewController, animated: true)
    }
    
    func pushShopDetailViewController(shopId: Int, shouldHighlight: ShopDetailTableView.HighlightableCell) {
        let shopDetailViewController = factory.makeShopDetailViewController(
            shopId: shopId,
            shouldHighlight: shouldHighlight
        )
        navigationController.pushViewController(shopDetailViewController, animated: true)
    }
    
    func pushReviewListViewController(shopId: Int, shopName: String) {
        let reviewListViewController = factory.makeReviewListViewController(shopId: shopId, shopName: shopName)
        reviewListViewController.coordinator = self
        navigationController.pushViewController(reviewListViewController, animated: true)
    }
    
    func pushShopReviewViewController(shopId: Int, shopName: String, reviewId: Int? = nil, completion: @escaping ((Bool, Int?, WriteReviewRequest) -> Void)) {
        let shopReviewViewController = factory.makeShopReviewViewController(
            reviewId: reviewId,
            shopId: shopId,
            shopName: shopName,
            completion: completion
        )
        shopReviewViewController.coordinator = self
        navigationController.pushViewController(shopReviewViewController, animated: true)
    }
    
    func pushShopReviewReportViewController(reviewId: Int, shopId: Int, shopName: String, completion: @escaping (Int, Int) -> Void) {
        let shopReviewReportViewController = factory.makeShopReviewReportViewController(
            reviewId: reviewId,
            shopId: shopId,
            shopName: shopName,
            completion: completion
        )
        navigationController.pushViewController(shopReviewReportViewController, animated: true)
    }
    
    func presentShopSortOptionSheetViewController(currentType: ShopSortType, onSelect: @escaping (ShopSortType) -> Void) {
        let shopSortOptionSheetViewController = factory.makeShopSortOptionSheetViewController(
            currentSortType: currentType,
            onOptionSelected: onSelect
        )
        shopSortOptionSheetViewController.modalPresentationStyle = .pageSheet
        if let sheet = shopSortOptionSheetViewController.sheetPresentationController {
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
        navigationController.present(shopSortOptionSheetViewController, animated: true)
    }
    
    func presentSortTypeBottomSheetViewController(options: [String], selectedIndex: Int, onSelect: @escaping (Int) -> Void) {
        let sortTypeBottomSheetViewController = factory.makeSortTypeBottomSheetViewController(
            options: options,
            selectedIndex: selectedIndex,
            onSelection: onSelect
        )
        sortTypeBottomSheetViewController.modalPresentationStyle = .overFullScreen
        sortTypeBottomSheetViewController.modalTransitionStyle = .crossDissolve
        navigationController.present(sortTypeBottomSheetViewController, animated: true)
    }
    
    func presentReviewLoginModalViewController(type: MessageType, onLogin: @escaping () -> Void, onCancel: (() -> Void)?) {
        let reviewLoginModalViewController = factory.makeReviewLoginModalViewController(
            messageType: type.rawValue,
            onLoginButtonTapped: onLogin,
            onCancelButtonTapped: onCancel
        )
        navigationController.present(reviewLoginModalViewController, animated: true)
    }
    
    func presentDeleteReviewModalViewController(onDelete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let deleteReviewModalViewController = factory.makeDeleteReviewModalViewController(
            onDeleteButtonTapped: onDelete,
            onCancelButtonTapped: onCancel
        )
        deleteReviewModalViewController.modalPresentationStyle = .overFullScreen
        deleteReviewModalViewController.modalTransitionStyle = .crossDissolve
        navigationController.present(deleteReviewModalViewController, animated: true)
    }
    
    func presentBackButtonPopUpViewController(onStop: @escaping () -> Void) {
        let backButtonPopUpViewController = factory.makeBackButtonPopUpViewController(onStop: onStop)
        backButtonPopUpViewController.modalPresentationStyle = .overFullScreen
        backButtonPopUpViewController.modalTransitionStyle = .crossDissolve
        navigationController.present(backButtonPopUpViewController, animated: true)
    }
    
    func didFinish() {
        navigationController.delegate = parentCoordinator as? UINavigationControllerDelegate
        parentCoordinator?.removeChild(self)
    }
}

extension ShopCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
        if fromViewController === rootViewController {
            didFinish()
            print("ShopViewController 제거됨")
        }

    }
}
