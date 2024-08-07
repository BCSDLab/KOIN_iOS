//
//  FirebaseLog.swift
//  koin
//
//  Created by JOOMINKYUNG on 4/24/24.
//

import Foundation

enum eventTitle {
    case main_store_categories
    case store_categories
    case store_categories_search
    case store_can_delivery
    case store_can_card
    case store_can_bank
    case store_click
    case store_call
    case store_picture
    case store_detailView
    case store_backButton
    case store_swipe_back
    case store_categories_event
    case store_detailView_event
    case hamburger_store
    case hamburger_register
    case register_register
    case hamburger_login
    case login
    case login_findId_id
    case login_findId_password
    case hamburger_click
    case main_menu_moveDetailView
    case main_menu_corner
    case menu_time
    case menu_image
    case main_bus
    case main_bus_changeToFrom
    case main_bus_scroll
    case bus_departure
    case bus_arrival
    case bus_timetable
    case bus_timetable_area
    case bus_timetable_time
    case bus_timetable_express
    case hamburger_bus
    case hamburger
    case hamburger_dining
    case complete_sign_up
    case hamburger_my_info_without_login
    case user_only_ok
    case start_sign_up
    case hamburger_my_info_with_login
    case auto_login

}

enum eventName_action {
    case campus
    case business
    case user
}

enum event_category {
    case click
    case scroll
    case swipe
}

struct MakeParamsForLog {
    func makeValueForLogAboutStoreId(id: Int) -> String {
        switch id {
        case 2:
            return "치킨"
        case 3:
            return "피자"
        case 4:
            return "도시락"
        case 5:
            return "족발"
        case 6:
            return "중국집"
        case 7:
            return "일반음식점"
        case 8:
            return "카페"
        case 9:
            return "뷰티"
        case 10:
            return "기타/콜밴"
        case 0:
            return "전체보기"
        default:
            return ""
            
        }
    }
    
    func makeEventTitle(title: eventTitle) -> String {
        switch title {
        case .main_store_categories:
            return "main_shop_categories"
        case .store_can_bank:
            return "shop_can_bank"
        case .store_can_card:
            return "shop_can_card"
        case .store_can_delivery:
            return "shop_can_delivery"
        case .store_categories_search:
            return "shop_categories_search"
        case .store_categories:
            return "shop_categories"
        case .store_detailView:
            return "shop_detail_view"
        case .hamburger_store:
            return "hamburger_shop"
        case .hamburger_register:
            return "hamburger_register"
        case .register_register:
            return "register_register"
        case .hamburger_login:
            return "hamburger_login"
        case .login:
            return "login"
        case .login_findId_id:
            return "login_findId_id"
        case .login_findId_password:
            return "login_findId_password"
        case .hamburger_click:
            return "hamburger_click"
        case .main_menu_moveDetailView:
            return "main_menu_moveDetailView"
        case .main_menu_corner:
            return "main_menu_corner"
        case .menu_time:
            return "menu_time"
        case .menu_image:
            return "menu_image"
        case .main_bus:
            return "main_bus"
        case .main_bus_changeToFrom:
            return "main_bus_changeToFrom"
        case .main_bus_scroll:
            return "main_bus_scroll"
        case .bus_departure:
            return "bus_departure"
        case .bus_arrival:
            return "bus_arrival"
        case .bus_timetable:
            return "bus_timetable"
        case .bus_timetable_area:
            return "bus_timetable_area"
        case .bus_timetable_time:
            return "bus_timetable_time"
        case .bus_timetable_express:
            return "bus_timetable_express"
        case .hamburger_bus:
            return "hamburger_bus"
        case .hamburger_dining:
            return "hamburger_dining"
        case .hamburger:
            return "hamburger"
        case .complete_sign_up:
            return "complete_sign_up"
        case .hamburger_my_info_without_login:
            return "hamburger_my_info_without_login"
        case .user_only_ok:
            return "user_only_ok"
        case .start_sign_up:
            return "start_sign_up"
        case .hamburger_my_info_with_login:
            return "hamburger_my_info_with_login"
        case .store_backButton:
            return "shop_back_button"
        case .store_categories_event:
            return "shop_categories_event"
        case .store_detailView_event:
            return "shop_detail_view_event"
        case .store_click:
            return "shop_click"
        case .store_call:
            return "shop_call"
        case .store_picture:
            return "shop_picture"
        case .store_swipe_back:
            return "shop_swipe_back"
        case .auto_login:
            return "auto_login"
        }
    }
    
    func makeEventNameAction(name: eventName_action) -> String {
        switch name {
        case .business:
            return "BUSINESS"
        case .campus:
            return "CAMPUS"
        case .user:
            return "USER"
        }
    }
    
    func makeEventCategory(category: event_category) -> String {
        switch category {
        case .click:
            return "click"
        case .scroll:
            return "scroll"
        case .swipe:
            return "swipe"
        }
    }
}
