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
        
        enum AbTest: String, EventLabelType {
            case businessBenefit = "BUSINESS_benefit_1"
            case businessCall = "BUSINESS_call_1"
            case campusClub1 = "CAMPUS_club_1"
            case dining2shop1 = "dining2shop_1"
            case diningToShop = "dining_to_shop"
            case diningToShopClose = "dining_to_shop_close"
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
            case shopCategoriesBenefit = "shop_categories_benefit"
            case shopCategoriesEvent = "shop_categories_event"
            case shopDetailViewEvent = "shop_detail_view_event"
            case shopCategoriesSearch = "shop_categories_search"
            case shopDetailView = "shop_detail_view"
            case shopDetailViewReview = "shop_detail_view_review"
            case shopDetailViewBack = "shop_detail_view_back"
            case shopCategoriesBack = "shop_categories_back"
            
            case shopDetailViewReviewWrite = "shop_detail_view_review_write"
            case shopDetailViewReviewWriteDone = "shop_detail_view_review_write_done"
            case shopDetailViewReviewReport = "shop_detail_view_review_report"
            case shopDetailViewReviewReportDone = "shop_detail_view_review_report_done"
            case shopDetailViewReviewBack = "shop_detail_view_review_back"
            
            case shopDetailViewReviewDelete = "shop_detail_view_review_delete"
            case shopDetailViewReviewDeleteDone = "shop_detail_view_review_delete_done"
            case shopDetailViewReviewDeleteCancel = "shop_detail_view_review_delete_cancel"
            case shopDetailViewReviewWriteCancel = "shop_detail_view_review_write_cancel"
            case shopDetailViewReviewReportCancel = "shop_detail_view_review_report_cancel"
            case mainShopBenefit = "main_shop_benefit"
            case benefitShopCategories = "benefit_shop_categories"
            case benefitShopCategoriesEvent = "benefit_shop_categories_event"
            case benefitShopClick = "benefit_shop_click"
            case benefitShopCall = "benefit_shop_call"
            
            case loginPrompt = "login_prompt"
            
            //order
            case orderHistoryTabClick = "orderHistory_tabClick"
            
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
            case errorFeedbackButton = "error_feedback_button"
            case busAnnouncement = "bus_announcement"
            case busAnnouncementClose = "bus_announcement_close"
            case shuttleBusRoute = "shuttle_bus_route"
            case areaSpecificRoute = "area_specific_route"
            case dsBusDirection = "ds_bus_direction"
            case cityBusRoute = "city_bus_route"
            case cityBusDirection = "city_bus_direction"
            case timetableBusTypeTab = "timetable_bus_type_tab"
            
            case shuttleTicket = "shuttle_ticket"
            case mainBusTimetable = "main_bus_timetable"
            case mainBusSearch = "main_bus_search"
            
            case departureBox = "departure_box"
            case arrivalBox = "arrival_box"
            
            case departureLocationConfirm = "departure_location_confirm"
            case arrivalLocationConfirm = "arrival_location_confirm"
            case swapDestionation = "swap_destination"
            case searchBus = "search_bus"
            case searchResultBack = "search_result_back"
            case searchResultClose = "search_result_close"
            case searchResultDepartureTime = "search_result_departure_time"
            case departureTimeSetting = "departure_time_setting"
            case departureNow = "departure_now"
            case departureTimeSettingDone = "departure_time_setting_done"
            case searchResultBusType = "search_result_bus_type"
            
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
            
            case itemWrite = "item_write"
            case findUserCategory = "find_user_category"
            case findUserAddItem = "find_user_add_item"
            case findUserWriteConfirm = "find_user_write_confirm"
            case findUserDelete = "find_user_delete"
            case findUserDeleteConfirm = "find_user_delete_confirm"
            
            case lostItemWrite = "lost_item_write"
            case findUserWrite = "find_user_write"
            case lostItemCategory = "lost_item_category"
            case lostItemAddItem = "lost_item_add_item"
            case lostItemWriteConfirm = "lost_item_write_confirm"
            case itemMessageSend = "item_message_send"
            case itemPostReport = "item_post_report"
            case itemPostReportConfirm = "item_post_report_confirm"
            case messageListSelect = "message_list_select"
            case itemPostType = "item_post_type"
            
            case loginPrompt = "login_prompt"

            var team: String {
                return "CAMPUS"
            }
        }
        
        enum User: String, EventLabelType {
            // Login
            case completeSignUp = "complete_sign_up"
            case login = "login"
            case autoLogin = "auto_login"
            case loginFindIdId = "login_findId_id"
            case hamburger = "hamburger"
            case hamburgerMyInfoWithLogin = "hamburger_my_info_with_login"
            case hamburgerMyInfoWithoutLogin = "hamburger_my_info_without_login"
            case startSignUp = "start_sign_up"
            case userOnlyOk = "user_only_ok"
            case userInfo = "user_info"
            case termsAgreement = "terms_agreement"
            case identityVerification = "identity_verification"
            case createAccount = "create_account"
            case signUpCompleted = "sign_up_completed"
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
        case signup
        case entry
        case abTestBenefit = "a/b test 로깅(3차 스프린트, 혜택페이지)"
        case abTestDining = "a/b test 로깅(식단 메인 진입점)"
        case abTestKeyword = "a/b test 로깅(키워드 알림 배너)"
        case abTestCall = "a/b test 로깅(전화하기)"
        case abTestDiningEntry = "a/b test 로깅(메인화면 식단 진입)"
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
        case shopCategoriesBack
    }
}
