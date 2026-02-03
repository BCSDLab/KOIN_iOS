//
//  ColorSystem.swift
//  koin
//
//  Created by 이은지 on 10/16/25.
//

import UIKit

extension UIColor {
    
    enum ColorSystem {
        
        // MARK: - Neutral
        
        enum Neutral {
            static let gray0 = UIColor(hexCode: "FFFFFF")
            static let gray50 = UIColor(hexCode: "FAFAFA")
            static let gray100 = UIColor(hexCode: "F5F5F5")
            static let gray200 = UIColor(hexCode: "EEEEEE")
            static let gray300 = UIColor(hexCode: "E6E6E6")
            static let gray400 = UIColor(hexCode: "D9D9D9")
            static let gray500 = UIColor(hexCode: "A8A8A8")
            static let gray600 = UIColor(hexCode: "6f6f6f")
            static let gray700 = UIColor(hexCode: "4B4B4B")
            static let gray800 = UIColor(hexCode: "323232")
            static let gray900 = UIColor(hexCode: "1F1F1F")
        }
        
        // MARK: - Danger
        
        enum Danger {
            static let red100 = UIColor(hexCode: "FBEEEE")
            static let red200 = UIColor(hexCode: "F5D1D1")
            static let red300 = UIColor(hexCode: "F0B7B7")
            static let red400 = UIColor(hexCode: "E99696")
            static let red500 = UIColor(hexCode: "E37878")
            static let red600 = UIColor(hexCode: "DE5F5F")
            static let red700 = UIColor(hexCode: "D94A4A")
            static let red800 = UIColor(hexCode: "D63939")
            static let red900 = UIColor(hexCode: "C92A2A")
            static let red1000 = UIColor(hexCode: "B12525")
            static let red1100 = UIColor(hexCode: "982020")
            static let red1200 = UIColor(hexCode: "871C1C")
            static let red1300 = UIColor(hexCode: "721818")
            static let red1400 = UIColor(hexCode: "541212")
        }
        
        // MARK: - SubColor
        
        enum SubColor {
            static let orange100 = UIColor(hexCode: "FEF2D1")
            static let orange200 = UIColor(hexCode: "FEE1A4")
            static let orange300 = UIColor(hexCode: "FED98B")
            static let orange400 = UIColor(hexCode: "FCCC77")
            static let orange500 = UIColor(hexCode: "FAB655")
            static let orange600 = UIColor(hexCode: "F9AE43")
            static let orange700 = UIColor(hexCode: "F7941E")
            static let orange800 = UIColor(hexCode: "D47415")
            static let orange900 = UIColor(hexCode: "B1580F")
            static let orange1000 = UIColor(hexCode: "A4470D")
            static let orange1100 = UIColor(hexCode: "8F3F09")
            static let orange1200 = UIColor(hexCode: "7D3708")
            static let orange1300 = UIColor(hexCode: "682C06")
            static let orange1400 = UIColor(hexCode: "532004")
        }
        
        // MARK: - Warning
        
        enum Warning {
            static let yellow100 = UIColor(hexCode: "FDF3E2")
            static let yellow200 = UIColor(hexCode: "FBEACC")
            static let yellow300 = UIColor(hexCode: "F9DFB3")
            static let yellow400 = UIColor(hexCode: "F6D38F")
            static let yellow500 = UIColor(hexCode: "F3C873")
            static let yellow600 = UIColor(hexCode: "F1BD5E")
            static let yellow700 = UIColor(hexCode: "EDB345")
            static let yellow800 = UIColor(hexCode: "E8A62A")
            static let yellow900 = UIColor(hexCode: "DD9616")
            static let yellow1000 = UIColor(hexCode: "C38312")
            static let yellow1100 = UIColor(hexCode: "AF740F")
            static let yellow1200 = UIColor(hexCode: "845B0D")
            static let yellow1300 = UIColor(hexCode: "5E4209")
            static let yellow1400 = UIColor(hexCode: "3D2A06")
        }

        // MARK: - Chartreuse
        
        enum Chartreuse {
            static let chartreuse100 = UIColor(hexCode: "DBFC6E")
            static let chartreuse200 = UIColor(hexCode: "CBF443")
            static let chartreuse300 = UIColor(hexCode: "BCE92A")
            static let chartreuse400 = UIColor(hexCode: "AAD816")
            static let chartreuse500 = UIColor(hexCode: "98C50A")
            static let chartreuse600 = UIColor(hexCode: "87B103")
            static let chartreuse700 = UIColor(hexCode: "769C00")
            static let chartreuse800 = UIColor(hexCode: "678800")
            static let chartreuse900 = UIColor(hexCode: "577400")
            static let chartreuse1000 = UIColor(hexCode: "486000")
            static let chartreuse1100 = UIColor(hexCode: "3A4D00")
            static let chartreuse1200 = UIColor(hexCode: "2C3B00")
            static let chartreuse1300 = UIColor(hexCode: "212C00")
            static let chartreuse1400 = UIColor(hexCode: "181F00")
        }
        
        // MARK: - Celery
        
        enum Celery {
            static let celery100 = UIColor(hexCode: "CDFCBF")
            static let celery200 = UIColor(hexCode: "AEF69D")
            static let celery300 = UIColor(hexCode: "96EE85")
            static let celery400 = UIColor(hexCode: "72E06A")
            static let celery500 = UIColor(hexCode: "4ECF50")
            static let celery600 = UIColor(hexCode: "27BB36")
            static let celery700 = UIColor(hexCode: "07A721")
            static let celery800 = UIColor(hexCode: "009112")
            static let celery900 = UIColor(hexCode: "007C0F")
            static let celery1000 = UIColor(hexCode: "00670F")
            static let celery1100 = UIColor(hexCode: "00530D")
            static let celery1200 = UIColor(hexCode: "00400A")
            static let celery1300 = UIColor(hexCode: "003007")
            static let celery1400 = UIColor(hexCode: "002205")
        }
        
        // MARK: - Success
        
        enum Success {
            static let green100 = UIColor(hexCode: "E5F4EC")
            static let green200 = UIColor(hexCode: "D0EBDD")
            static let green300 = UIColor(hexCode: "BAE9D1")
            static let green400 = UIColor(hexCode: "A8E3C6")
            static let green500 = UIColor(hexCode: "93DCB8")
            static let green600 = UIColor(hexCode: "50CE83")
            static let green700 = UIColor(hexCode: "36BF6E")
            static let green800 = UIColor(hexCode: "2DA05C")
            static let green900 = UIColor(hexCode: "288F52")
            static let green1000 = UIColor(hexCode: "228149")
            static let green1100 = UIColor(hexCode: "1F7743")
            static let green1200 = UIColor(hexCode: "196137")
            static let green1300 = UIColor(hexCode: "15512E")
            static let green1400 = UIColor(hexCode: "0F3920")
        }
        
        // MARK: - Seafoam
        
        enum Seafoam {
            static let seafoam100 = UIColor(hexCode: "CEF7F3")
            static let seafoam200 = UIColor(hexCode: "AAF1EA")
            static let seafoam300 = UIColor(hexCode: "8CE9E2")
            static let seafoam400 = UIColor(hexCode: "65DAD2")
            static let seafoam500 = UIColor(hexCode: "3FC9C1")
            static let seafoam600 = UIColor(hexCode: "0FB5AE")
            static let seafoam700 = UIColor(hexCode: "00A19A")
            static let seafoam800 = UIColor(hexCode: "008C87")
            static let seafoam900 = UIColor(hexCode: "007772")
            static let seafoam1000 = UIColor(hexCode: "00635F")
            static let seafoam1100 = UIColor(hexCode: "0C4F4C")
            static let seafoam1200 = UIColor(hexCode: "123C3A")
            static let seafoam1300 = UIColor(hexCode: "122C2B")
            static let seafoam1400 = UIColor(hexCode: "0F1F1E")
        }
        
        // MARK: - Cyan
        
        enum Cyan {
            static let cyan100 = UIColor(hexCode: "C5F8FF")
            static let cyan200 = UIColor(hexCode: "A4F0FF")
            static let cyan300 = UIColor(hexCode: "88E7FA")
            static let cyan400 = UIColor(hexCode: "60D8F3")
            static let cyan500 = UIColor(hexCode: "33C5E8")
            static let cyan600 = UIColor(hexCode: "12B0DA")
            static let cyan700 = UIColor(hexCode: "019CC8")
            static let cyan800 = UIColor(hexCode: "0086B4")
            static let cyan900 = UIColor(hexCode: "00719F")
            static let cyan1000 = UIColor(hexCode: "005D89")
            static let cyan1100 = UIColor(hexCode: "004A73")
            static let cyan1200 = UIColor(hexCode: "00395D")
            static let cyan1300 = UIColor(hexCode: "002A46")
            static let cyan1400 = UIColor(hexCode: "001E33")
        }
        
        // MARK: - Info

        enum Info {
            static let blue100 = UIColor(hexCode: "F8FCFF")
            static let blue200 = UIColor(hexCode: "D6EEFF")
            static let blue300 = UIColor(hexCode: "CCE5FF")
            static let blue400 = UIColor(hexCode: "BDDDFF")
            static let blue500 = UIColor(hexCode: "A8D2FF")
            static let blue600 = UIColor(hexCode: "75B7FF")
            static let blue700 = UIColor(hexCode: "3394FF")
            static let blue800 = UIColor(hexCode: "1A87FF")
            static let blue900 = UIColor(hexCode: "195BE6")
            static let blue1000 = UIColor(hexCode: "1A55CF")
            static let blue1100 = UIColor(hexCode: "1B4FBB")
            static let blue1200 = UIColor(hexCode: "1947A9")
            static let blue1300 = UIColor(hexCode: "143885")
            static let blue1400 = UIColor(hexCode: "0D2559")
        }

        // MARK: - Indigo

        enum Indigo {
            static let indigo100 = UIColor(hexCode: "EDEEFF")
            static let indigo200 = UIColor(hexCode: "E0E2FF")
            static let indigo300 = UIColor(hexCode: "D3D5FF")
            static let indigo400 = UIColor(hexCode: "C1C4FF")
            static let indigo500 = UIColor(hexCode: "ACAFFF")
            static let indigo600 = UIColor(hexCode: "9599FF")
            static let indigo700 = UIColor(hexCode: "7E84FC")
            static let indigo800 = UIColor(hexCode: "686DF4")
            static let indigo900 = UIColor(hexCode: "5258E4")
            static let indigo1000 = UIColor(hexCode: "4046CA")
            static let indigo1100 = UIColor(hexCode: "3236A8")
            static let indigo1200 = UIColor(hexCode: "262986")
            static let indigo1300 = UIColor(hexCode: "1B1E64")
            static let indigo1400 = UIColor(hexCode: "141648")
        }

        // MARK: - Primary

        enum Primary {
            static let purple100 = UIColor(hexCode: "F5EBFF")
            static let purple200 = UIColor(hexCode: "DDB1FE")
            static let purple300 = UIColor(hexCode: "D39AFE")
            static let purple400 = UIColor(hexCode: "CE86FD")
            static let purple500 = UIColor(hexCode: "C969FC")
            static let purple600 = UIColor(hexCode: "C358FC")
            static let purple700 = UIColor(hexCode: "B611F5")
            static let purple800 = UIColor(hexCode: "980AC9")
            static let purple900 = UIColor(hexCode: "7D08A4")
            static let purple1000 = UIColor(hexCode: "6F09A2")
            static let purple1100 = UIColor(hexCode: "600481")
            static let purple1200 = UIColor(hexCode: "550472")
            static let purple1300 = UIColor(hexCode: "44025E")
            static let purple1400 = UIColor(hexCode: "2F0141")
        }

        // MARK: - Fuchsia

        enum Fuchsia {
            static let fuchsia100 = UIColor(hexCode: "FFE9FC")
            static let fuchsia200 = UIColor(hexCode: "FFDAFA")
            static let fuchsia300 = UIColor(hexCode: "FEC7F8")
            static let fuchsia400 = UIColor(hexCode: "FBAEF6")
            static let fuchsia500 = UIColor(hexCode: "F592F3")
            static let fuchsia600 = UIColor(hexCode: "ED74ED")
            static let fuchsia700 = UIColor(hexCode: "E055E2")
            static let fuchsia800 = UIColor(hexCode: "CD3ACE")
            static let fuchsia900 = UIColor(hexCode: "B622B7")
            static let fuchsia1000 = UIColor(hexCode: "9D039E")
            static let fuchsia1100 = UIColor(hexCode: "800081")
            static let fuchsia1200 = UIColor(hexCode: "640664")
            static let fuchsia1300 = UIColor(hexCode: "470E46")
            static let fuchsia1400 = UIColor(hexCode: "320D31")
        }

        // MARK: - Magenta

        enum Magenta {
            static let magenta100 = UIColor(hexCode: "FFEAF1")
            static let magenta200 = UIColor(hexCode: "FFDCE8")
            static let magenta300 = UIColor(hexCode: "FFCADD")
            static let magenta400 = UIColor(hexCode: "FFB2CE")
            static let magenta500 = UIColor(hexCode: "FF95BD")
            static let magenta600 = UIColor(hexCode: "FA77AA")
            static let magenta700 = UIColor(hexCode: "EF5A98")
            static let magenta800 = UIColor(hexCode: "DE3D82")
            static let magenta900 = UIColor(hexCode: "C82269")
            static let magenta1000 = UIColor(hexCode: "AD0955")
            static let magenta1100 = UIColor(hexCode: "8E0045")
            static let magenta1200 = UIColor(hexCode: "700037")
            static let magenta1300 = UIColor(hexCode: "54032A")
            static let magenta1400 = UIColor(hexCode: "3C061D")
        }
    }
}
