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
            case shopCategories = "shop_categories"
            case shopClick = "shop_click"
            case shopCall = "shop_call"
            case shopCan = "shop_can"
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
            case shopDetailViewReviewWriteCancel = "shop_detail_view_review_write_cancel"
            case shopDetailViewReviewCan = "shop_detail_view_review_can"
            case shopBenefitEntry = "shop_benefit_entry"
            case shopBenefitBack = "shop_benefit_back"
            case shopBenefitDetail = "shop_benefit_detail"
            case shopPictureSwipe = "shop_picture_swipe"
            
            case loginPrompt = "login_prompt"
            
            var team: String {
                return "BUSINESS"
            }
        }
        
        enum Campus {
            enum Dining: String, EventLabelType {
                case todayMeal = "today_meal"
                case menuCorner = "menu_corner"
                case menuShare = "menu_share"
                case notificationMenuImageUpload = "notification_menu_image_upload"
                case notificationSoldOut = "notification_sold_out"
                case notificationBreakfastSoldOut = "notification_breakfast_sold_out"
                case notificationLunchSoldOut = "notification_lunch_sold_out"
                case notificationDinnerSoldOut = "notification_dinner_sold_out"
                var team: String {
                    return "CAMPUS"
                }
            }
            
            enum Bus: String, EventLabelType {
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
                case busTimetable = "bus_timetable"
                case busRoute = "bus_route"
                case departureBox = "departure_box"
                case arrivalBox = "arrival_box"
                case departureLocationConfirm = "departure_location_confirm"
                case arrivalLocationConfirm = "arrival_location_confirm"
                case swapDestination = "swap_destination"
                case searchBus = "search_bus"
                case searchResultBack = "search_result_back"
                case searchResultClose = "search_result_close"
                case searchResultDepartureTime = "search_result_departure_time"
                case departureNow = "departure_now"
                case departureTimeSettingDone = "departure_time_setting_done"
                case searchResultBusType = "search_result_bus_type"
                var team: String {
                    return "CAMPUS"
                }
            }
            
            enum Home: String, EventLabelType {
                case navHome = "nav_home"
                case navCategory = "nav_category"
                case navBulletin = "nav_bulletin"
                case navProfile = "nav_profile"
                case categoryTimetable = "category_timetable"
                case categoryLostProperty = "category_lost_property"
                case categoryCampus = "category_campus"
                case categoryTransportation = "category_transportation"
                case categoryEtc = "category_etc"
                case mainNextModal = "main_next_modal"
                case mainModalHide7d = "main_modal_hide_7d"
                case mainModalClose = "main_modal_close"
                case mainModalEntry = "main_modal_entry"
                case mainModal = "main_modal"
                case homeTimetable = "home_timetable"
                case homeLogin = "home_login"
                case homeLogout = "home_logout"
                case homeSettings = "home_settings"
                var team: String {
                    return "CAMPUS"
                }
            }
            
            enum Notice: String, EventLabelType {
                case noticeTab = "notice_tab"
                case noticePage = "notice_page"
                case inventory = "inventory"
                case popularNotice = "popular_notice"
                case noticeSearch = "notice_search"
                case popularSearchingWord = "popular_searching_word"
                case manageKeyword = "manage_keyword"
                case noticeFilterAll = "notice_filter_all"
                case addKeyword = "add_keyword"
                case recommendedKeyword = "recommended_keyword"
                case keywordNotification = "keyword_notification"
                case loginPopupKeyword = "login_popup_keyword"
                case noticeOriginalShortcut = "notice_original_shortcut"
                case noticeSearchEvent = "notice_search_event"
                case notificationManageKeyword = "notification_manage_keyword"
                case loginPrompt = "login_prompt"
                var team: String {
                    return "CAMPUS"
                }
            }
            
            enum Notification: String, EventLabelType {
                case notification = "notification"
                case notificationList = "notification_list"
                case notificationListReadAll = "notification_list_read_all"
                case notificationListDelete = "notification_list_delete"
                case notificationListDeleteAll = "notification_list_delete_all"
                var team: String {
                    return "CAMPUS"
                }
            }
            
            enum LostItem: String, EventLabelType {
                case itemWrite = "item_write"
                case findUserCategory = "find_user_category"
                case findUserAddItem = "find_user_add_item"
                case findUserWriteConfirm = "find_user_write_confirm"
                case findUserDelete = "find_user_delete"
                case findUserDeleteConfirm = "find_user_delete_confirm"
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
                var team: String {
                    return "CAMPUS"
                }
            }
            
            enum CallVan: String, EventLabelType {
                case callvanpot = "callvanpot"
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
                var team: String {
                    return "CAMPUS"
                }
            }
            
            enum Recruit: String, EventLabelType {
                case recruitNotification = "team_recruitment_notification"
                case recruitSearch = "team_recruitment_search"
                case recruitFilter = "team_recruitment_filter"
                case recruitFilterStatus = "team_recruitment_filter_status"
                case recruitFilterSort = "team_recruitment_filter_sort"
                case recruitFilterCategory = "team_recruitment_filter_category"
                case recruitFilterMethod = "team_recruitment_filter_method"
                case recruitFilterReset = "team_recruitment_filter_reset"
                case recruitFilterApply = "team_recruitment_filter_apply"
                case recruitPostSelect = "team_recruitment_post_select"
                case recruitPostApply = "team_recruitment_post_apply"
                case recruitPostApplicantCheck = "team_recruitment_post_applicant_check"
                case recruitPostDelete = "team_recruitment_post_delete"
                case recruitPostDeleteConfirm = "team_recruitment_post_delete_confirm"
                case recruitPostDeleteCancel = "team_recruitment_post_delete_cancel"
                case recruitPostEdit = "team_recruitment_post_edit"
                case recruitPostEditCategory = "team_recruitment_post_edit_category"
                case recruitPostEditMethod = "team_recruitment_post_edit_method"
                case recruitPostEditRole = "team_recruitment_post_edit_role"
                case recruitPostEditSubmit = "team_recruitment_post_edit_submit"
                case recruitPostEditSubmitCancel = "team_recruitment_post_edit_submit_cancel"
                case recruitPostEditSubmitConfirm = "team_recruitment_post_edit_submit_confirm"
                case recruitRecruit = "team_recruitment_recruit"
                case recruitRecruitCategory = "team_recruitment_recruit_category"
                case recruitRecruitMethod = "team_recruitment_recruit_method"
                case recruitRecruitRole = "team_recruitment_recruit_role"
                case recruitRecruitSubmit = "team_recruitment_recruit_submit"
                case recruitRecruitSubmitCancel = "team_recruitment_recruit_submit_cancel"
                case recruitRecruitSubmitConfirm = "team_recruitment_recruit_submit_confirm"
                case recruitApplyLoad = "team_recruitment_apply_load"
                case recruitApplyMajorSelect = "team_recruitment_apply_major_select"
                case recruitApplySkillAdd = "team_recruitment_apply_skill_add"
                case recruitApplyActivityAdd = "team_recruitment_apply_activity_add"
                case recruitApplyActivityModify = "team_recruitment_apply_activity_modify"
                case recruitApplyActivityModifyComplete = "team_recruitment_apply_activity_modify_complete"
                case recruitApplyNext = "team_recruitment_apply_next"
                case recruitApplyRoleSelect = "team_recruitment_apply_role_select"
                case recruitApplySubmit = "team_recruitment_apply_submit"
                case recruitApplySubmitConfirm = "team_recruitment_apply_submit_confirm"
                case recruitApplySubmitCancel = "team_recruitment_apply_submit_cancel"
                case recruitProfile = "team_recruitment_profile"
                case recruitProfileModify = "team_recruitment_profile_modify"
                case recruitProfileCreate = "team_recruitment_profile_create"
                case recruitProfileCreated = "team_recruitment_profile_created"
                case recruitProfileApplied = "team_recruitment_profile_applied"
                case recruitProfileModifyLoad = "team_recruitment_profile_modify_load"
                case recruitProfileModifyMajorSelect = "team_recruitment_profile_modify_major_select"
                case recruitProfileModifyNext = "team_recruitment_profile_modify_next"
                case recruitProfileModifySkillAdd = "team_recruitment_profile_modify_skill_add"
                case recruitProfileModifyActivityModify = "team_recruitment_profile_modify_activity_modify"
                case recruitProfileModifyActivityModifyComplete = "team_recruitment_profile_modify_activity_modify_complete"
                case recruitProfileModifyActivityAdd = "team_recruitment_profile_modify_activity_add"
                case recruitProfileModifyActivityComplete = "team_recruitment_profile_modify_activity_complete"
                case recruitProfileModifySubmit = "team_recruitment_profile_modify_submit"
                case recruitProfileModifySubmitConfirm = "team_recruitment_profile_modify_submit_confirm"
                case recruitProfileModifySubmitCancel = "team_recruitment_profile_modify_submit_cancel"
                case recruitProfileCreateLoad = "team_recruitment_profile_create_load"
                case recruitProfileCreateMajor = "team_recruitment_profile_create_major"
                case recruitProfileCreateNext = "team_recruitment_profile_create_next"
                case recruitProfileCreateSkillAdd = "team_recruitment_profile_create_skill_add"
                case recruitProfileCreateActivityAdd = "team_recruitment_profile_create_activity_add"
                case recruitProfileCreateActivityAddComplete = "team_recruitment_profile_create_activity_add_complete"
                case recruitProfileCreateActivityModify = "team_recruitment_profile_create_activity_modify"
                case recruitProfileCreateActivityModifyComplete = "team_recruitment_profile_create_activity_modify_complete"
                case recruitProfileCreateSubmit = "team_recruitment_profile_create_submit"
                case recruitProfileCreateSubmitCancel = "team_recruitment_profile_create_submit_cancel"
                case recruitProfileCreateSubmitConfirm = "team_recruitment_profile_create_submit_confirm"
                case recruitAppliedPostFilter = "team_recruitment_applied_post_filter"
                case recruitAppliedPostFilterStatus = "team_recruitment_applied_post_filter_status"
                case recruitAppliedPostFilterSort = "team_recruitment_applied_post_filter_sort"
                case recruitAppliedPostFilterReset = "team_recruitment_applied_post_filter_reset"
                case recruitAppliedPostFilterApply = "team_recruitment_applied_post_filter_apply"
                case recruitAppliedPostChat = "team_recruitment_applied_post_chat"
                case recruitCreatedPostApplicant = "team_recruitment_created_post_applicant"
                case recruitCreatedPostClose = "team_recruitment_created_post_close"
                case recruitCreatedPostCloseCancel = "team_recruitment_created_post_close_cancel"
                case recruitCreatedPostCloseConfirm = "team_recruitment_created_post_close_confirm"
                case recruitCreatedPostChat = "team_recruitment_created_post_chat"
                case recruitCreatedPostFilter = "team_recruitment_created_post_filter"
                case recruitCreatedPostFilterStatus = "team_recruitment_created_post_filter_status"
                case recruitCreatedPostFilterSort = "team_recruitment_created_post_filter_sort"
                case recruitCreatedPostFilterReset = "team_recruitment_created_post_filter_reset"
                case recruitCreatedPostFilterApply = "team_recruitment_created_post_filter_apply"
                case recruitCreatedPostApplicantSelect = "team_recruitment_created_post_applicant_select"
                case recruitCreatedPostApplicantChat = "team_recruitment_created_post_applicant_chat"
                case recruitCreatedPostApplicantApprove = "team_recruitment_created_post_applicant_approve"
                case recruitCreatedPostApplicantApproveConfirm = "team_recruitment_created_post_applicant_approve_confirm"
                case recruitCreatedPostApplicantApproveCancel = "team_recruitment_created_post_applicant_approve_cancel"
                case recruitCreatedPostApplicantReject = "team_recruitment_created_post_applicant_reject"
                case recruitCreatedPostApplicantRejectConfirm = "team_recruitment_created_post_applicant_reject_confirm"
                case recruitCreatedPostApplicantRejectCancel = "team_recruitment_created_post_applicant_reject_cancel"
                var team: String {
                    return "CAMPUS"
                }
            }
        }
        
        enum User: String, EventLabelType {
            // Login
            case login = "login"
            case hamburger = "hamburger"
            case startSignUp = "start_sign_up"
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
