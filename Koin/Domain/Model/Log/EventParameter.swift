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
        enum Business: String, EventLabelType {
            // Shop
            case mainShopCategories = "main_shop_categories"
            case shopCategories = "shop_categories"
            case shopClick = "shop_click"
            case shopCall = "shop_call"
            case shopPicture = "shop_picture"
            case hamburger = "hamburger"
            case shopCategoriesEvent = "shop_categories_event"
            case shopDetailViewEvent = "shop_detail_view_event"
            case shopCategoriesSearch = "shop_categories_search"
            case shopDetailView = "shop_detail_view"
            case shopDetailViewReview = "shop_detail_view_review"
            case shopDetailViewBack = "shop_detail_view_back"
            
            var team: String {
                return "BUSINESS"
            }
        }
        
        enum Campus: String, EventLabelType {
            // Dining
            case mainMenuMoveDetailView = "main_menu_moveDetailView"
            case mainMenuCorner = "main_menu_corner"
            case hamburgerDining = "hamburger_dining"
            case menuTime = "menu_time"
            case menuImage = "menu_image"
            
            // Bus
            case mainBus = "main_bus"
            case mainBusChangeToFrom = "main_bus_changeToFrom"
            case mainBusScroll = "main_bus_scroll"
            case hamburgerBus = "hamburger_bus"
            case busDeparture = "bus_departure"
            case busArrival = "bus_arrival"
            case busTimetable = "bus_timetable"
            case busTimetableArea = "bus_timetable_area"
            case busTimetableTime = "bus_timetable_time"
            case busTimetableExpress = "bus_timetable_express"
            
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
    }
    
    enum EventLabelNeededDuration {
        case shopCategories
        case shopClick
        case mainShopCategories
        case shopCall
        case shopDetailViewBack
    }
}
