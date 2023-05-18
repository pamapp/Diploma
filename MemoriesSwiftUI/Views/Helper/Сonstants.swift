//
//  Сonstants.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 08.05.2023.
//

import Foundation
import SwiftUI

struct Errors {
    static let savingDataError: String = "Saving data error"

}

struct UI {
    static let screen_width: CGFloat = UIScreen.main.bounds.width
    static let screen_height: CGFloat = UIScreen.main.bounds.height
    static let chapters_spaces: CGFloat = 32
    
    enum PopUp {
        static let watering_a_flower: String = "watering-a-flower"
    }
    
    enum Buttons {
        static let pause_audio: String = "pause-audio"
        static let play_audio: String = "play-audio"
        static let scroll_to_bottom: String = "scroll-to-bottom"
        static let send_inactive: String = "send-inactive"
        static let send_active: String = "send-active"
    }
    
    enum Icons {
        static let attachments: String = "attachment"
        static let cross_gray: String = "cross-gray"
        static let cross_white: String = "cross-white"
        static let drower: String = "drower"
        static let profile: String = "profile"
        static let search: String = "search"
        static let tag: String = "tag"
        static let trash: String = "trash"
        static let edit: String = "edit"
        static let video_message: String = "video-message"
        static let audio_message: String = "audio-message"
        static let eye_slash_fill: String = "eye.slash.fill"
    }
    
    enum Strings {
        static let empty_chapter_text: String = "Сегодня записей нет"
        static let dear_diary: String = "Дорогой дневник,"
        static let draft: String = "Черновик"
        static let mood_chart_title: String = "График настроя"
        static let mood_chart_text: String = "Показывает общее настроение Ваших воспоминаний. Это помогает остледить уровень эмоций"
        static let words_top_title: String = "Топ 10 слов"
        static let words_top_text: String = "Это может помочь Вам лучше отслеживать ваши чувства и переживания"
        static let emoji_top: String = "Топ Emoji"
        
        static let stats_description_title: String = "Цветок воспоминаний"
        static let stats_description_text: String = "Ведите дневник каждый день и ваш цветок будет расти. Память улучшаться. Ум станет острее. Ежедневные записи укрепляют нейроны нашего мозга и питают цветок."
        static let stats_description_btn_text: String = "Запомню"
    }
    
    enum Alearts {
        static let alert_title: String = "Доступ к библиотеке фотографий"
        static let message_text: String = "Пожалуйста, предоставьте доступ в настройках, чтобы продолжить"
        static let primaryBtn_text: String = "Отменить"
        static let secondaryBtn_text: String = "Настройки"
    }
}
