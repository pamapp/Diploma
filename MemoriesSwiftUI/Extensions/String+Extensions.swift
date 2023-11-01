//
//  String+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 21.02.2023.
//

import SwiftUI

// MARK: Localization

extension String {
    public func localized() -> String {
        let string = NSLocalizedString(self, comment: self)
        return string
    }
}


// MARK: WordCount

extension String {
    func stringByRemovingEmoji() -> String { String(self.filter { !$0.isEmoji() }) }
    func stringByRemovingWords() -> String { String(self.filter { $0.isEmoji() }) }
}


// MARK: Hashtags

extension String {
    public func separate(withChar char : String) -> [String] {
        var word : String = ""
        var words : [String] = [String]()
        
        for chararacter in self {
            if String(chararacter) == char && word != "" {
                words.append(word)
                word = char
            } else {
                word += String(chararacter)
            }
        }
        
        words.append(word)
        return words
    }
    
    public func resolveHashtags(color: UIColor) -> NSAttributedString {
        var length: Int = 0
        let text: String = self
        let words: [String] = text.separate(withChar: " ")
        let hashtagWords = words.flatMap({$0.separate(withChar: "#")})
        let attrs = [NSAttributedString.Key.font: UIFont.newYorkFont()]
        let attrString = NSMutableAttributedString(string: text, attributes: attrs)
        
        for word in hashtagWords {
            if word.hasPrefix("#") {
                let matchRange: NSRange = NSMakeRange(length, word.count)
                attrString.addAttribute(.foregroundColor, value: color, range: matchRange)
            }
            length += word.count
        }
        
        return attrString
    }
    
    public func resolveHashtags(color: Color) -> Text {
        let words = self.split(separator: " ")
        var output: Text = Text("")
        
        for word in words {
            if word.hasPrefix("#") {
                if word == words.first {
                    output = Text(String(word))
                        .foregroundColor(color)
                } else {
                    output = output + Text(" ") + Text(String(word))
                        .foregroundColor(color)
                }
            } else {
                if word == words.first {
                    output = Text(String(word))
                } else {
                    output = output + Text(" ") + Text(String(word))
                }
            }
        }
        
        return output
    }
}


