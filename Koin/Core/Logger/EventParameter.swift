//
//  EventParameter.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

/// 현행 명세 label: `service__page__feature[__detail]__category`.
/// event_name(team)·screen_view·event_category를 label 구간에서 계산한다.
protocol EventLabelType {
    var rawValue: String { get }
    /// 기본값은 page 구간. 명세의 screen_view가 page 구간과 다른 label만 재정의한다.
    var screenView: String? { get }
}

extension EventLabelType {
    var screenView: String? {
        let parts = segments
        guard (4...5).contains(parts.count), parts.allSatisfy({ !$0.isEmpty }) else {
            assertionFailure("Invalid logging label: \(rawValue)")
            return nil
        }
        return parts[1]
    }

    var team: String {
        let service = segments[0]
        switch service {
        case "shop", "cafeteria", "bus", "timetable", "real_estate", "owner", "ticket", "team_recruit":
            return "DA1"
        case "main", "banner", "board", "account", "callvan", "chat", "department", "facility", "course_practice":
            return "DA2"
        default:
            assertionFailure("Unassigned logging service: \(service)")
            return ""
        }
    }

    /// 마지막 구간. 명세의 category가 마지막 구간과 다르면 호출 시 category를 넘긴다.
    var lastSegment: String {
        segments.last ?? ""
    }

    private var segments: [String] {
        rawValue.components(separatedBy: "__")
    }
}

enum EventParameter {
    enum EventLabel {
        enum Shop: String, EventLabelType {
            case shopDetailLoginPopupCloseClick = "account__shop_detail__login_popup__close__click"
            case shopDetailLoginPopupLoginEntryClick = "account__shop_detail__login_popup__login_entry__click"
            case shopBenefitNavigationBackClick = "shop__shop_benefit__navigation__back__click"
            case shopBenefitNavigationBackSwipe = "shop__shop_benefit__navigation__back__swipe"
            case shopBenefitShopEventExpandClick = "shop__shop_benefit__shop_event__expand__click"
            case shopDetailContactPhoneClick = "shop__shop_detail__contact__phone__click"
            case shopDetailFilterReviewSortClick = "shop__shop_detail__filter__review_sort__click"
            case shopDetailNavigationBackClick = "shop__shop_detail__navigation__back__click"
            case shopDetailNavigationBackSwipe = "shop__shop_detail__navigation__back__swipe"
            case shopDetailNavigationReviewExitClick = "shop__shop_detail__navigation__review_exit__click"
            case shopDetailNavigationReviewExitSwipe = "shop__shop_detail__navigation__review_exit__swipe"
            case shopDetailPhotoViewSlideSwipe = "shop__shop_detail__photo_view__slide__swipe"
            case shopDetailReviewDeleteCancelClick = "shop__shop_detail__review_delete__cancel__click"
            case shopDetailReviewDeleteConfirmClick = "shop__shop_detail__review_delete__confirm__click"
            case shopDetailReviewDeleteOpenClick = "shop__shop_detail__review_delete__open__click"
            case shopDetailReviewReportConfirmClick = "shop__shop_detail__review_report__confirm__click"
            case shopDetailReviewReportEntryClick = "shop__shop_detail__review_report__entry__click"
            case shopDetailReviewWriteEntryClick = "shop__shop_detail__review_write__entry__click"
            case shopDetailShopEventEntryClick = "shop__shop_detail__shop_event__entry__click"
            case shopDetailShopInfoEntryClick = "shop__shop_detail__shop_info__entry__click"
            case shopDetailShopMenuScroll = "shop__shop_detail__shop_menu__scroll"
            case shopDetailShopReviewEntryClick = "shop__shop_detail__shop_review__entry__click"
            case shopDetailShopReviewScroll = "shop__shop_detail__shop_review__scroll"
            case shopListFilterCategoryClick = "shop__shop_list__filter__category__click"
            case shopListFilterQuickFilterSelect = "shop__shop_list__filter__quick_filter__select"
            case shopListFilterSortSelect = "shop__shop_list__filter__sort__select"
            case shopListNavigationBackClick = "shop__shop_list__navigation__back__click"
            case shopListNavigationBackSwipe = "shop__shop_list__navigation__back__swipe"
            case shopListSearchClick = "shop__shop_list__search__click"
            case shopListShopDetailEntryClick = "shop__shop_list__shop_detail__entry__click"
            case shopListShopListScroll = "shop__shop_list__shop_list__scroll"
            case shopReviewWriteReviewWriteConfirmClick = "shop__shop_review_write__review_write__confirm__click"
            case shopSearchShopDetailEntryClick = "shop__shop_search__shop_detail__entry__click"
        }

        enum Bus: String, EventLabelType {
            case busSearchSearchArrivalConfirmSelect = "bus__bus_search__search__arrival_confirm__select"
            case busSearchSearchArrivalOpenClick = "bus__bus_search__search__arrival_open__click"
            case busSearchSearchClick = "bus__bus_search__search__click"
            case busSearchSearchDepartureConfirmSelect = "bus__bus_search__search__departure_confirm__select"
            case busSearchSearchDepartureOpenClick = "bus__bus_search__search__departure_open__click"
            case busSearchSearchSwapClick = "bus__bus_search__search__swap__click"
            case busSearchResultFilterBusTypeSelect = "bus__bus_search_result__filter__bus_type__select"
            case busSearchResultNavigationBackClick = "bus__bus_search_result__navigation__back__click"
            case busSearchResultSearchDepartureTimeConfirmClick = "bus__bus_search_result__search__departure_time_confirm__click"
            case busSearchResultSearchDepartureTimeNowClick = "bus__bus_search_result__search__departure_time_now__click"
            case busSearchResultSearchDepartureTimeOpenClick = "bus__bus_search_result__search__departure_time_open__click"
            case busTimetableBusFeedbackEntryClick = "bus__bus_timetable__bus_feedback__entry__click"
            case busTimetableBusNoticeCloseClick = "bus__bus_timetable__bus_notice__close__click"
            case busTimetableBusNoticeOpenClick = "bus__bus_timetable__bus_notice__open__click"
            case busTimetableFilterBusTypeClick = "bus__bus_timetable__filter__bus_type__click"
            case busTimetableFilterCityDirectionSelect = "bus__bus_timetable__filter__city_direction__select"
            case busTimetableFilterCityRouteSelect = "bus__bus_timetable__filter__city_route__select"
            case busTimetableFilterDaeseongDirectionSelect = "bus__bus_timetable__filter__daeseong_direction__select"
            case busTimetableFilterShuttleRouteSelect = "bus__bus_timetable__filter__shuttle_route__select"
            case busTimetableShuttleRouteEntryClick = "bus__bus_timetable__shuttle_route__entry__click"
        }

        enum Dining: String, EventLabelType {
            case accountConfigNotificationConfigEntryClick = "cafeteria__account_config__notification_config__entry__click"
            case cafeteriaCafeteriaInfoEntryClick = "cafeteria__cafeteria__cafeteria_info__entry__click"
            case cafeteriaMealTimeScroll = "cafeteria__cafeteria__meal_time__scroll"
            case cafeteriaMealTimeSelect = "cafeteria__cafeteria__meal_time__select"
            case cafeteriaPhotoViewOpenClick = "cafeteria__cafeteria__photo_view__open__click"
            case cafeteriaShareKakaoClick = "cafeteria__cafeteria__share__kakao__click"
            case fromExternalCafeteriaEntryKakaoEntryClick = "cafeteria__from_external__cafeteria_entry__kakao_entry__click"
            case notificationConfigNotificationConfigPhotoUploadToggle = "cafeteria__notification_config__notification_config__photo_upload__toggle"
            case notificationConfigSoldOutToggle = "cafeteria__notification_config__sold_out__toggle"
            case notificationConfigSoldOutMealToggle = "cafeteria__notification_config__sold_out_meal__toggle"

            /// 품절 제보·실험. label은 현행 명세 그대로지만 screen_view가 page 구간과 다르고,
            /// 일부 category가 마지막 구간과 달라 호출 시 넘긴다.
            enum SoldOutReport: String, EventLabelType {
                case cafeteriaDiningAbtestExposure = "cafeteria__dining__abtest__exposure"
                case cafeteriaDiningSoldoutStart = "cafeteria__dining__soldout__start"
                case cafeteriaDiningSoldoutSelect = "cafeteria__dining__soldout__select"
                case cafeteriaDiningSoldoutPhoto = "cafeteria__dining__soldout__photo"
                case cafeteriaDiningSoldoutSubmit = "cafeteria__dining__soldout__submit"
                case cafeteriaDiningSoldoutExit = "cafeteria__dining__soldout__exit"
                var screenView: String? { "cafeteria" }
            }
        }

        enum CallVan: String, EventLabelType {
            case callvanChatCallvanChatMessageSendClick = "callvan__callvan_chat__callvan_chat__message_send__click"
            case callvanListCallvanChatCardEntryClick = "callvan__callvan_list__callvan_chat__card_entry__click"
            case callvanListCallvanParticipationCancelResponseClick = "callvan__callvan_list__callvan_participation__cancel_response__click"
            case callvanListCallvanParticipationJoinResponseClick = "callvan__callvan_list__callvan_participation__join_response__click"
            case callvanListCallvanWriteEntryClick = "callvan__callvan_list__callvan_write__entry__click"
            case callvanListContactPhoneClick = "callvan__callvan_list__contact__phone__click"
            case callvanListFilterApplyClick = "callvan__callvan_list__filter__apply__click"
            case callvanListFilterOpenClick = "callvan__callvan_list__filter__open__click"
            case callvanListNavigationBackClick = "callvan__callvan_list__navigation__back__click"
            case callvanListNavigationBackSwipe = "callvan__callvan_list__navigation__back__swipe"
            case callvanListSearchSearchInputClick = "callvan__callvan_list__search__search_input__click"
            case callvanParticipantListCallvanChatParticipantEntryClick = "callvan__callvan_participant_list__callvan_chat__participant_entry__click"
            case callvanWriteCallvanWriteArrivalConfirmClick = "callvan__callvan_write__callvan_write__arrival_confirm__click"
            case callvanWriteCallvanWriteConfirmClick = "callvan__callvan_write__callvan_write__confirm__click"
            case callvanWriteCallvanWriteDepartureConfirmClick = "callvan__callvan_write__callvan_write__departure_confirm__click"
            case callvanWriteCallvanWriteDepartureTimeConfirmClick = "callvan__callvan_write__callvan_write__departure_time_confirm__click"
            case callvanWriteNavigationBackClick = "callvan__callvan_write__navigation__back__click"
            case callvanWriteNavigationBackSwipe = "callvan__callvan_write__navigation__back__swipe"
        }

        enum Home {
            enum DA1: String, EventLabelType {
                case busMainBusEntrySearchEntryClick = "bus__main__bus_entry__search_entry__click"
                case busMainCategoryCategoryNavigationSearchEntryClick = "bus__main_category__category_navigation__search_entry__click"
                case busMainCategoryCategoryNavigationTimetableEntryClick = "bus__main_category__category_navigation__timetable_entry__click"
                case cafeteriaMainCategoryCategoryNavigationCafeteriaEntryClick = "cafeteria__main_category__category_navigation__cafeteria_entry__click"
                case ownerMainCategoryCategoryNavigationOwnerEntryClick = "owner__main_category__category_navigation__owner_entry__click"
                case realEstateMainCategoryCategoryNavigationRealEstateEntryClick = "real_estate__main_category__category_navigation__real_estate_entry__click"
                case shopMainShopEntryPopularEntryClick = "shop__main__shop_entry__popular_entry__click"
                case shopMainCategoryCategoryNavigationShopEntryClick = "shop__main_category__category_navigation__shop_entry__click"
                case ticketMainBusEntryTicketEntryClick = "ticket__main__bus_entry__ticket_entry__click"
                case teamRecruitMainCategoryCategoryNavigationTeamRecruitEntryClick = "team_recruit__main_category__category_navigation__team_recruit_entry__click"
                case timetableMainCategoryCategoryNavigationTimetableEntryClick = "timetable__main_category__category_navigation__timetable_entry__click"
                case timetableMainProfileTimetableEntryEntryClick = "timetable__main_profile__timetable_entry__entry__click"
            }
            enum DA2: String, EventLabelType {
                case accountMainProfileAccountConfigEntryClick = "account__main_profile__account_config__entry__click"
                case accountMainProfileLoginEntryClick = "account__main_profile__login__entry__click"
                case accountMainProfileLogoutClick = "account__main_profile__logout__click"
                case bannerMainModalClick = "banner__main__modal__click"
                case bannerMainModalCloseClick = "banner__main__modal__close__click"
                case bannerMainModalExposure = "banner__main__modal__exposure"
                case bannerMainModalHide7dClick = "banner__main__modal__hide_7d__click"
                case bannerMainModalNextSwipe = "banner__main__modal__next__swipe"
                case boardMainCategoryCategoryNavigationLostItemEntryClick = "board__main_category__category_navigation__lost_item_entry__click"
                case callvanMainCallvanEntryRecruitmentListEntryClick = "callvan__main__callvan_entry__recruitment_list_entry__click"
                case callvanMainCategoryCategoryNavigationCallvanEntryClick = "callvan__main_category__category_navigation__callvan_entry__click"
                case chatMainCategoryCategoryNavigationChatEntryClick = "chat__main_category__category_navigation__chat_entry__click"
                case departmentMainCategoryCategoryNavigationDepartmentEntryClick = "department__main_category__category_navigation__department_entry__click"
                case facilityMainCategoryCategoryNavigationFacilityEntryClick = "facility__main_category__category_navigation__facility_entry__click"
                case mainMainBusEntryTimetableEntryClick = "main__main__bus_entry__timetable_entry__click"
                case mainMainCornerSelect = "main__main__corner__select"
                case mainMainMealClick = "main__main__meal__click"
                case mainMainNavigationCategoryMenuEntryClick = "main__main__navigation__category_menu_entry__click"
                case mainMainNavigationMainEntryClick = "main__main__navigation__main_entry__click"
                case mainMainNavigationProfileEntryClick = "main__main__navigation__profile_entry__click"
                case mainMainNoticeEntryNavigationEntryClick = "main__main__notice_entry__navigation_entry__click"
                case mainMainNotificationListEntryClick = "main__main__notification_list__entry__click"
                case mainMainShopEntryMainEntryClick = "main__main__shop_entry__main_entry__click"
                case mainNotificationListNotificationListDeleteClick = "main__notification_list__notification_list__delete__click"
                case mainNotificationListNotificationListDeleteAllClick = "main__notification_list__notification_list__delete_all__click"
                case mainNotificationListNotificationListItemEntryClick = "main__notification_list__notification_list__item_entry__click"
                case mainNotificationListNotificationListReadAllClick = "main__notification_list__notification_list__read_all__click"
            }
        }

        

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
        case exposure
        case select
        case toggle
        case submit
        case fail
    }
    
    enum EventLabelNeededDuration: String {
        case shopCategories
        case shopClick
        case shopCall
        case shopDetailViewBack
        case shopDetailViewReviewBackByTab = "shopDetailViewReviewBackByTab"
        case shopDetailViewReviewBackByCall = "shopDetailViewReviewBackByCall"
        case shopDetailViewReviewBackByCategory = "shopDetailViewReviewBackByCategory"
        case shopCategoriesBack
        case shopDetailViewReviewBack = "shop_detail_view_review_back"
    }
}
