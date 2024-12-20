//
//  EventParameter.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation


protocol EventLabelType {
    var rawValue: String { get }
    var team: String { get }
}

enum EventParameter {
    enum EventLabel {
        
        enum ForceUpdate: String, EventLabelType {
            case forcedUpdatePageView = "forced_update_page_view"
            case forceUpdateExit = "forced_update_exit"
            case forceUpdateConfirm = "forced_update_confirm"
            case forceUpdateAlreadyDone = "forced_update_already_done"
            case alreadyUpdatePopup = "already_update_popup"
            var team: String {
                return "FORCE_UPDATE"
            }
        }
        
        enum ABTest: String, EventLabelType {
            case businessBenefit = "BUSINESS_benefit_1"
            case campusDining = "CAMPUS_dining_1"
            case campusNotice = "CAMPUS_notice_1"
            case businessCall = "BUSINESS_call_1"
            var team: String {
                return "AB_TEST"
            }
        }
        
        enum Business: String, EventLabelType {
            // Shop
            case mainShopCategories = "main_shop_categories"
            case shopCategories = "shop_categories"
            case shopClick = "shop_click"
            case shopCall = "shop_call"
            case shopCan = "shop_can"
            case shopPicture = "shop_picture"
            case hamburger = "hamburger"
            case shopCategoriesEvent = "shop_categories_event"
            case shopDetailViewEvent = "shop_detail_view_event"
            case shopCategoriesSearch = "shop_categories_search"
            case shopDetailView = "shop_detail_view"
            case shopDetailViewReview = "shop_detail_view_review"
            case shopDetailViewBack = "shop_detail_view_back"
            
            case shopDetailViewReviewWrite = "shop_detail_view_review_write"
            case shopDetailViewReviewWriteDone = "shop_detail_view_review_write_done"
            case shopDetailViewReviewReport = "shop_detail_view_review_report"
            case shopDetailViewReviewReportDone = "shop_detail_view_review_report_done"
            case shopDetailViewReviewBack = "shop_detail_view_review_back"
            
            case shopDetailViewReviewDelete = "shop_detail_view_review_delete"
            case shopDetailViewReviewDeleteDone = "shop_detail_view_review_delete_done"
            case shopDetailViewReviewDeleteCancel = "shop_detail_view_review_delete_cancel"
            case shopDetailViewReviewWriteLogin = "shop_detail_view_review_write_login"
            case shopDetailViewReviewWriteCancel = "shop_detail_view_review_write_cancel"
            case shopDetailViewReviewReportLogin = "shop_detail_view_review_report_login"
            case shopDetailViewReviewReportCancel = "shop_detail_view_review_report_cancel"
            case mainShopBenefit = "main_shop_benefit"
            case benefitShopCategories = "benefit_shop_categories"
            case benefitShopCategoriesEvent = "benefit_shop_categories_event"
            case benefitShopClick = "benefit_shop_click"
            case benefitShopCall = "benefit_shop_call"
            var team: String {
                return "BUSINESS"
            }
        }
        
        enum Campus: String, EventLabelType {
            // Dining
            case mainScroll = "main_scroll"
            case mainMenuMoveDetailView = "main_menu_moveDetailView"
            case mainMenuCorner = "main_menu_corner"
            case hamburger = "hamburger"
            case menuTime = "menu_time"
            case menuImage = "menu_image"
            case menuShare = "menu_share"
            case cafeteriaInfo = "cafeteria_info"
            case notificationMenuImageUpload = "notification_menu_image_upload"
            
            // Bus
            case mainBus = "main_bus"
            case mainBusChangeToFrom = "main_bus_changeToFrom"
            case mainBusScroll = "main_bus_scroll"
            case busDeparture = "bus_departure"
            case busArrival = "bus_arrival"
            case busSearchDeparture = "bus_search_departure"
            case busSearchArrival = "bus_search_arrival"
            case busSearch = "bus_search"
            case busTimetable = "bus_timetable"
            case busTimetableArea = "bus_timetable_area"
            case busTimetableTime = "bus_timetable_time"
            case busTimetableExpress = "bus_timetable_express"
            case busTimetableCitybus = "bus_timetable_citybus"
            case busTimetableCitybusRoute = "bus_timetable_citybus_route"
            case busTabMenu = "bus_tab_menu"
            
            case noticeTab = "notice_tab"
            case noticePage = "notice_page"
            case inventory = "inventory"
            case popularNotice = "popular_notice"
            case noticeSearch = "notice_search"
            case popularSearchingWord = "popular_searching_word"
            case manageKeyword = "manage_keyword"
            case fiterAll = "filter_all"
            case noticeFilterAll = "notice_filter_all"
            case addKeyword = "add_keyword"
            case recommendedKeyword = "recommended_keyword"
            case keywordNotification = "keyword_notification"
            case loginPopupKeyword = "login_popup_keyword"
            case noticeOriginalShortcut = "notice_original_shortcut"
            case noticeSearchEvent = "notice_search_event"
            case notificationManageKeyword = "notification_manage_keyword"
            case appMainNoticeDetail = "app_main_notice_detail"
            case popularNoticeBanner = "popular_notice_banner"
            case toManageKeyword = "to_manage_keyword"
            
            case notificationSoldOut = "notification_sold_out"
            case notificationBreakfastSoldOut = "notification_breakfast_sold_out"
            case notificationLunchSoldOut = "notification_lunch_sold_out"
            case notificationDinnerSoldOut = "notification_dinner_sold_out"
            
            var team: String {
                return "CAMPUS"
            }
        }
        
        enum User: String, EventLabelType {
            // Login
            case completeSignUp = "complete_sign_up"
            case hamburgerLogin = "hamburger_login"
            case login = "login"
            case autoLogin = "auto_login"
            case loginFindIdId = "login_findId_id"
            case hamburger = "hamburger"
            case hamburgerMyInfoWithLogin = "hamburger_my_info_with_login"
            case hamburgerMyInfoWithoutLogin = "hamburger_my_info_without_login"
            case startSignUp = "start_sign_up"
            case userOnlyOk = "user_only_ok"
            var team: String {
                return "USER"
            }
        }
        
        // ??
        case hamburgerRegister
        case registerRegister
        case loginFindIdPassword
        case hamburgerClick
    }
    
    enum EventCategory: String {
        case click
        case scroll
        case swipe
        case abTestBenefit = "a/b test 로깅(3차 스프린트, 혜택페이지)"
        case abTestDining = "a/b test 로깅(식단 메인 진입점)"
        case abTestKeyword = "a/b test 로깅(키워드 알림 배너)"
        case abTestCall = "a/b test 로깅(전화하기)"
        case pageView = "page_view"
        case pageExit = "page_exit"
        case update = "update"
        case notification
    }
    
    enum EventLabelNeededDuration: String {
        case shopCategories
        case shopClick
        case mainShopCategories
        case shopCall
        case shopDetailViewBack
        case shopDetailViewReviewBackByTab = "shopDetailViewReviewBackByTab"
        case shopDetailViewReviewBackByCall = "shopDetailViewReviewBackByCall"
        case shopDetailViewReviewBackByCategory = "shopDetailViewReviewBackByCategory"
        case mainShopBenefit
        case benefitShopCategories
        case benefitShopClick
        case benefitShopCall
    }
}
