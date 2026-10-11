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
        
//        enum AbTest: String, EventLabelType {
//            var team: String {
//                return "AB_TEST"
//            }
//        }
        
        enum Business: String, EventLabelType {
            // Shop
            case shop = "shop"
            case popularShop = "popular_shop"
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
            case shopCategoriesSearchClick = "shop_categories_search_click"
            case shopDetailView = "shop_detail_view"
            case shopDetailViewReview = "shop_detail_view_review"
            case shopDetailViewBack = "shop_detail_view_back"
            case shopCategoriesBack = "shop_categories_back"
            case shopDetailViewInfo = "shop_detail_view_info"
            
            case shopDetailViewReviewWrite = "shop_detail_view_review_write"
            case shopDetailViewReviewWriteDone = "shop_detail_view_review_write_done"
            case shopDetailViewReviewReport = "shop_detail_view_review_report"
            case shopDetailViewReviewBack = "shop_detail_view_review_back"
            
            case shopDetailViewReviewDelete = "shop_detail_view_review_delete"
            case shopDetailViewReviewDeleteDone = "shop_detail_view_review_delete_done"
            case shopDetailViewReviewDeleteCancel = "shop_detail_view_review_delete_cancel"
            case shopDetailViewReviewWriteCancel = "shop_detail_view_review_write_cancel"
            case shopDetailViewReviewReportCancel = "shop_detail_view_review_report_cancel"
            case shopDetailViewReviewCan = "shop_detail_view_review_can"
            case mainShopBenefit = "main_shop_benefit"
            case benefitShopCategories = "benefit_shop_categories"
            case benefitShopCategoriesEvent = "benefit_shop_categories_event"
            case benefitShopClick = "benefit_shop_click"
            case benefitShopCall = "benefit_shop_call"
            case shopBenefitEntry = "shop_benefit_entry"
            case shopBenefitBack = "shop_benefit_back"
            case shopBenefitDetail = "shop_benefit_detail"
            case shopPictureSwipe = "shop_picture_swipe"
            
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
            case todayMeal = "today_meal"
            case menuCorner = "menu_corner"
            case mainMenuMoveDetailView = "main_menu_moveDetailView"
            case mainMenuCorner = "main_menu_corner"
            case hamburger = "hamburger"
            case menuTime = "menu_time"
            case menuImage = "menu_image"
            case menuShare = "menu_share"
            case cafeteriaInfo = "cafeteria_info"
            case notificationMenuImageUpload = "notification_menu_image_upload"
            case diningToShop = "dining_to_shop"
            
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
            
            // Home
            case shuttleTicket = "shuttle_ticket"
            case busTimetable = "bus_timetable"
            case busRoute = "bus_route"
            case navHome = "nav_home"
            case navCategory = "nav_category"
            case navBulletin = "nav_bulletin"
            case navProfile = "nav_profile"
            case categoryTimetable = "category_timetable"
            case categoryLostProperty = "category_lost_property"
            case categoryCampus = "category_campus"
            case categoryTransportation = "category_transportation"
            case categoryEtc = "category_etc"
            case mainBusTimetable = "main_bus_timetable"
            case mainBusSearch = "main_bus_search"
            case mainNextModal = "main_next_modal"
            case mainModalHide7d = "main_modal_hide_7d"
            case mainModalClose = "main_modal_close"
            case homeTimetable = "home_timetable"
            case homeLogin = "home_login"
            case homeLogout = "home_logout"
            case homeSettings = "home_settings"
            
            case departureBox = "departure_box"
            case arrivalBox = "arrival_box"
            
            case departureLocationConfirm = "departure_location_confirm"
            case arrivalLocationConfirm = "arrival_location_confirm"
            case swapDestination = "swap_destination"
            case searchBus = "search_bus"
            case searchResultBack = "search_result_back"
            case searchResultClose = "search_result_close"
            case searchResultDepartureTime = "search_result_departure_time"
            case departureTimeSetting = "departure_time_setting"
            case departureNow = "departure_now"
            case departureTimeSettingDone = "departure_time_setting_done"
            case searchResultBusType = "search_result_bus_type"
            
            // Notice
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
            
            // Noti
            case notification = "notification"
            case notificationList = "notification_list"
            case notificationListReadAll = "notification_list_read_all"
            case notificationListDelete = "notification_list_delete"
            case notificationListDeleteAll = "notification_list_delete_all"
            case notificationSoldOut = "notification_sold_out"
            case notificationBreakfastSoldOut = "notification_breakfast_sold_out"
            case notificationLunchSoldOut = "notification_lunch_sold_out"
            case notificationDinnerSoldOut = "notification_dinner_sold_out"
            
            // lostitem
            case itemWrite = "item_write"
            case findUserCategory = "find_user_category"
            case findUserAddItem = "find_user_add_item"
            case findUserWriteConfirm = "find_user_write_confirm"
            case findUserDelete = "find_user_delete"
            case findUserDeleteConfirm = "find_user_delete_confirm"
            case lostItemEntry = "lost_item_entry"
            case lostItemFilter = "lost_item_filter"
            case lostItemFilterApply = "lost_item_filter_apply"
            case lostItemPostEntry = "lost_item_post_entry"
            case lostItemMessageLoginRequest = "lost_item_message_login_request"
            case lostItemWriteLoginRequest = "lost_item_write_login_request"
            case lostItemStateChange = "lost_item_state_change"
            case lostItemFound = "lost_item_found"
            case lostItemKeywordSetting = "lost_item_keyword_setting"
            case lostItemKeywordAdd = "lost_item_keyword_add"
            case lostItemKeywordRecommend = "lost_item_keyword_recommend"
            case lostItemKeywordAlarm = "lost_item_keyword_alarm"
            case lostItemKeywordRemove = "lost_item_keyword_remove"
            
            case findUserWrite = "find_user_write"
            case lostItemWrite = "lost_item_write"
            case lostItemCategory = "lost_item_category"
            case lostItemAddItem = "lost_item_add_item"
            case lostItemWriteConfirm = "lost_item_write_confirm"
            case itemMessageSend = "item_message_send"
            case itemPostReport = "item_post_report"
            case itemPostReportConfirm = "item_post_report_confirm"
            case messageListSelect = "message_list_select"
            
            case loginPrompt = "login_prompt"
            
            // CallVan
            case callvanpot = "callvanpot"
            case mainCallVanView = "main_callvan_view"
            case mainCallVanWrite = "main_callvan_write"
            case callvanSearch = "callvan_search"
            case callvanFilter = "callvan_filter"
            case callvanFilterApply = "callvan_filter_apply"
            case callvanJoin = "callvan_join"
            case callvanJoinCancel = "callvan_join_cancel"
            case callvanChat = "callvan_chat"
            case callvanChatSend = "callvan_chat_send"
            case callvanCall = "callvan_call"
            case callvanCreate = "callvan_create"
            case callvanChatEntry = "callvan_chat_entry"
            case callvanBack = "callvan_back"
            case callvanWriteDeparture = "callvan_write_departure"
            case callvanWriteArrival = "callvan_write_arrival"
            case callvanWriteTime = "callvan_write_time"
            case callvanWriteDone = "callvan_write_done"
            case callvanWriteBack = "callvan_write_back"
            
            // Recruit
            case teamRecruitmentNotification = "team_recruitment_notification"
            case teamRecruitmentSearch = "team_recruitment_search"
            case teamRecruitmentFilter = "team_recruitment_filter"
            case teamRecruitmentFilterStatus = "team_recruitment_filter_status"
            case teamRecruitmentFilterSort = "team_recruitment_filter_sort"
            case teamRecruitmentFilterCategory = "team_recruitment_filter_category"
            case teamRecruitmentFilterMethod = "team_recruitment_filter_method"
            case teamRecruitmentFilterReset = "team_recruitment_filter_reset"
            case teamRecruitmentFilterApply = "team_recruitment_filter_apply"
            case teamRecruitmentPostSelect = "team_recruitment_post_select"
            case teamRecruitmentPostApply = "team_recruitment_post_apply"
            case teamRecruitmentPostApplicantCheck = "team_recruitment_post_applicant_check"
            case teamRecruitmentPostDelete = "team_recruitment_post_delete"
            case teamRecruitmentPostDeleteConfirm = "team_recruitment_post_delete_confirm"
            case teamRecruitmentPostDeleteCancel = "team_recruitment_post_delete_cancel"
            case teamRecruitmentPostEdit = "team_recruitment_post_edit"
            case teamRecruitmentPostEditCategory = "team_recruitment_post_edit_category"
            case teamRecruitmentPostEditMethod = "team_recruitment_post_edit_method"
            case teamRecruitmentPostEditRole = "team_recruitment_post_edit_role"
            case teamRecruitmentPostEditSubmit = "team_recruitment_post_edit_submit"
            case teamRecruitmentPostEditSubmitCancel = "team_recruitment_post_edit_submit_cancel"
            case teamRecruitmentPostEditSubmitConfirm = "team_recruitment_post_edit_submit_confirm"
            case teamRecruitmentRecruit = "team_recruitment_recruit"
            case teamRecruitmentRecruitCategory = "team_recruitment_recruit_category"
            case teamRecruitmentRecruitMethod = "team_recruitment_recruit_method"
            case teamRecruitmentRecruitRole = "team_recruitment_recruit_role"
            case teamRecruitmentRecruitSubmit = "team_recruitment_recruit_submit"
            case teamRecruitmentRecruitSubmitCancel = "team_recruitment_recruit_submit_cancel"
            case teamRecruitmentRecruitSubmitConfirm = "team_recruitment_recruit_submit_confirm"
            case teamRecruitmentApplyLoad = "team_recruitment_apply_load"
            case teamRecruitmentApplyMajorSelect = "team_recruitment_apply_major_select"
            case teamRecruitmentApplySkillAdd = "team_recruitment_apply_skill_add"
            case teamRecruitmentApplyActivityAdd = "team_recruitment_apply_activity_add"
            case teamRecruitmentApplyActivityModify = "team_recruitment_apply_activity_modify"
            case teamRecruitmentApplyActivityModifyComplete = "team_recruitment_apply_activity_modify_complete"
            case teamRecruitmentApplyNext = "team_recruitment_apply_next"
            case teamRecruitmentApplyRoleSelect = "team_recruitment_apply_role_select"
            case teamRecruitmentApplySubmit = "team_recruitment_apply_submit"
            case teamRecruitmentApplySubmitConfirm = "team_recruitment_apply_submit_confirm"
            case teamRecruitmentApplySubmitCancel = "team_recruitment_apply_submit_cancel"
            case teamRecruitmentProfile = "team_recruitment_profile"
            case teamRecruitmentProfileModify = "team_recruitment_profile_modify"
            case teamRecruitmentProfileCreate = "team_recruitment_profile_create"
            case teamRecruitmentProfileCreated = "team_recruitment_profile_created"
            case teamRecruitmentProfileApplied = "team_recruitment_profile_applied"
            case teamRecruitmentProfileModifyLoad = "team_recruitment_profile_modify_load"
            case teamRecruitmentProfileModifyMajorSelect = "team_recruitment_profile_modify_major_select"
            case teamRecruitmentProfileModifyNext = "team_recruitment_profile_modify_next"
            case teamRecruitmentProfileModifySkillAdd = "team_recruitment_profile_modify_skill_add"
            case teamRecruitmentProfileModifyActivityModify = "team_recruitment_profile_modify_activity_modify"
            case teamRecruitmentProfileModifyActivityModifyComplete = "team_recruitment_profile_modify_activity_modify_complete"
            case teamRecruitmentProfileModifyActivityAdd = "team_recruitment_profile_modify_activity_add"
            case teamRecruitmentProfileModifyActivityComplete = "team_recruitment_profile_modify_activity_complete"
            case teamRecruitmentProfileModifySubmit = "team_recruitment_profile_modify_submit"
            case teamRecruitmentProfileModifySubmitConfirm = "team_recruitment_profile_modify_submit_confirm"
            case teamRecruitmentProfileModifySubmitCancel = "team_recruitment_profile_modify_submit_cancel"
            case teamRecruitmentProfileCreateLoad = "team_recruitment_profile_create_load"
            case teamRecruitmentProfileCreateMajor = "team_recruitment_profile_create_major"
            case teamRecruitmentProfileCreateNext = "team_recruitment_profile_create_next"
            case teamRecruitmentProfileCreateSkillAdd = "team_recruitment_profile_create_skill_add"
            case teamRecruitmentProfileCreateActivityAdd = "team_recruitment_profile_create_activity_add"
            case teamRecruitmentProfileCreateActivityAddComplete = "team_recruitment_profile_create_activity_add_complete"
            case teamRecruitmentProfileCreateActivityModify = "team_recruitment_profile_create_activity_modify"
            case teamRecruitmentProfileCreateActivityModifyComplete = "team_recruitment_profile_create_activity_modify_complete"
            case teamRecruitmentProfileCreateSubmit = "team_recruitment_profile_create_submit"
            case teamRecruitmentProfileCreateSubmitCancel = "team_recruitment_profile_create_submit_cancel"
            case teamRecruitmentProfileCreateSubmitConfirm = "team_recruitment_profile_create_submit_confirm"
            case teamRecruitmentAppliedPostFilter = "team_recruitment_applied_post_filter"
            case teamRecruitmentAppliedPostFilterStatus = "team_recruitment_applied_post_filter_status"
            case teamRecruitmentAppliedPostFilterSort = "team_recruitment_applied_post_filter_sort"
            case teamRecruitmentAppliedPostFilterReset = "team_recruitment_applied_post_filter_reset"
            case teamRecruitmentAppliedPostFilterApply = "team_recruitment_applied_post_filter_apply"
            case teamRecruitmentAppliedPostChat = "team_recruitment_applied_post_chat"
            case teamRecruitmentCreatedPostApplicant = "team_recruitment_created_post_applicant"
            case teamRecruitmentCreatedPostClose = "team_recruitment_created_post_close"
            case teamRecruitmentCreatedPostCloseCancel = "team_recruitment_created_post_close_cancel"
            case teamRecruitmentCreatedPostCloseConfirm = "team_recruitment_created_post_close_confirm"
            case teamRecruitmentCreatedPostChat = "team_recruitment_created_post_chat"
            case teamRecruitmentCreatedPostFilter = "team_recruitment_created_post_filter"
            case teamRecruitmentCreatedPostFilterStatus = "team_recruitment_created_post_filter_status"
            case teamRecruitmentCreatedPostFilterSort = "team_recruitment_created_post_filter_sort"
            case teamRecruitmentCreatedPostFilterReset = "team_recruitment_created_post_filter_reset"
            case teamRecruitmentCreatedPostFilterApply = "team_recruitment_created_post_filter_apply"
            case teamRecruitmentCreatedPostApplicantSelect = "team_recruitment_created_post_applicant_select"
            case teamRecruitmentCreatedPostApplicantChat = "team_recruitment_created_post_applicant_chat"
            case teamRecruitmentCreatedPostApplicantApprove = "team_recruitment_created_post_applicant_approve"
            case teamRecruitmentCreatedPostApplicantApproveConfirm = "team_recruitment_created_post_applicant_approve_confirm"
            case teamRecruitmentCreatedPostApplicantApproveCancel = "team_recruitment_created_post_applicant_approve_cancel"
            case teamRecruitmentCreatedPostApplicantReject = "team_recruitment_created_post_applicant_reject"
            case teamRecruitmentCreatedPostApplicantRejectConfirm = "team_recruitment_created_post_applicant_reject_confirm"
            case teamRecruitmentCreatedPostApplicantRejectCancel = "team_recruitment_created_post_applicant_reject_cancel"
            
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
        case pageView = "page_view"
        case pageExit = "page_exit"
        case update = "update"
        case notification
        case result
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
        case shopDetailViewReviewBack = "shop_detail_view_review_back"
    }
}
