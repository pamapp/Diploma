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
        static let incognito: String = "incognito"
        static let emoji: String = "emoji"
    }
    
    enum Strings {
        static let empty_chapter_text: String = "There are no notes today"
        static let dear_diary: String = "Dear diary,"
        static let draft: String = "Drafts"
        
        static let privacy_mode_title: String = "Privacy mode"
        static let privacy_mode_text: String = "This will hide the recordings from prying eyes, for example, in public transport."
        
        static let mood_chart_title: String = "Mood chart"
        static let mood_chart_text: String = "Shows the general mood of your memories. It helps to track the level of emotions."
        static let mood_chart_empty_text: String = "There is no data yet"
        
        static let words_top_title: String = "Top 10 words"
        static let words_top_text: String = "Frequently used words statistics will help you better track your feelings and experiences."
        static let words_top_empty: [String] = ["Введите", "дневник", "каждый", "день", "узнавайте", "себя", "лучше", "собирайте", "статистику", "о себе"]
        
        static let emoji_top: String = "Top Emoji"
    
        static let stats_description_title: String = "Flower of memories"
        static let stats_description_text: String = "Keep a diary every day and your flower will grow. Memory will improve. The mind will become sharper. Daily recordings strengthen the neurons of our brain and nourish the flower."
        static let stats_description_btn_text: String = "Got it"
    }
    
    enum Alearts {
        static let php_alert_title: String = "Access to the photo library"
        static let php_message_text: String = "Please grant access in the settings to continue"
        static let php_primaryBtn_text: String = "Cancel"
        static let php_secondaryBtn_text: String = "Settings"
        
        static let micro_alert_title: String = "Microphone access"
        static let micro_message_text: String = "Please grant access in the settings to continue"
        static let micro_primaryBtn_text: String = "Cancel"
        static let micro_secondaryBtn_text: String = "Settings"
    }
}
