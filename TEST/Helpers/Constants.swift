//
//  Constants.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import UIKit

struct Constants {
    
    static let urlStringForRegisterUser = "http://94.127.67.113:8099/registerUser"
    static let urlStringForCheckLogin = "http://94.127.67.113:8099/checkLogin"
    static let urlStringForUploadAvatar = "http://94.127.67.113:8099/uploadAvatar"
    static let urlStringForUpdateProfile = "http://94.127.67.113:8099/updateProfile"
    
    static let topics = [
        InterestTopic(name: "Авто"),
        InterestTopic(name: "Бизнес"),
        InterestTopic(name: "Инвестиции"),
        InterestTopic(name: "Спорт"),
        InterestTopic(name: "Саморазвитие"),
        InterestTopic(name: "Здоровье"),
        InterestTopic(name: "Еда"),
        InterestTopic(name: "Семья, дети"),
        InterestTopic(name: "Домашние питомцы"),
        InterestTopic(name: "Фильмы"),
        InterestTopic(name: "Компьютерные игры"),
        InterestTopic(name: "Музыка")
    ]
    
    struct Colors {
        static let mainBlue = UIColor(hexString: "#0046AA")
        static let mainBlueWithOpacity = Constants.Colors.mainBlue.withAlphaComponent(0.2)
    }
}
