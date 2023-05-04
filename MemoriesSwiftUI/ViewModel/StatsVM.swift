//
//  StatsViewModel.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 02.05.2023.
//

import Foundation
import NaturalLanguage

class StatsVM: ObservableObject {
    @Published var popularWords: Array<Dictionary<String, Int>.Element>.SubSequence = []
    @Published var popularEmojies: Array<Dictionary<String, Int>.Element>.SubSequence = []
    @Published var moodDynamics: [StepCount] = []
    
    
    var chapterModel: ChapterViewModel

    init(chapterModel: ChapterViewModel) {
        self.chapterModel = chapterModel
        updateMoodDynamics()
        updatePopularWords()
        updatePopularEmojies()
    }

    func updatePopularWords() {
        let wordCount = getCountStrings()
        let popularWords = wordCount.getWordsByNumber(10)
        self.popularWords = popularWords
    }
    
    func updatePopularEmojies() {
        let wordCount = getCountStrings()
        let popularEmojies = wordCount.countEmojies().sorted(by: { $0.1 > $1.1}).prefix(10)
        self.popularEmojies = popularEmojies
    }
    
    func updateMoodDynamics() {
        var moodDynamics: [StepCount] = []
        
        for chapter in chapterModel.chapters {
            var itemsCountPerChapter = 0.0
            var itemsSentimentPerChapter = 0.0
            for item in chapter.itemsArray {
                itemsSentimentPerChapter += item.safeSentimentValue
            }
            itemsCountPerChapter += Double(chapter.itemsArray.count)
            moodDynamics.append(StepCount(weekday: chapter.safeDateContent, value: itemsSentimentPerChapter / itemsCountPerChapter))
        }

        self.moodDynamics = moodDynamics
    }
    
    func getCountStrings() -> WordCount {
        var tempArr : [String] = []
        for chapter in chapterModel.chapters {
            for item in chapter.itemsArray {
                tempArr.append(item.text ?? "")
            }
        }
        return WordCount(words: tempArr.seporateElements())
    }
}

struct StepCount: Identifiable {
    let id = UUID()
    let weekday: Date
    let value: Double
    
    init(weekday: Date, value: Double) {
        self.weekday = weekday
        self.value = value
    }
}

struct WordCount {
    private let words_only: [String]
    private let emoji_only: [String]
    
    init(words: String) {
        var tempArr: String = ""
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = words
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: words.startIndex..<words.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                if tag.rawValue != "Conjunction" && tag.rawValue != "Pronoun" && tag.rawValue != "Preposition" && tag.rawValue != "Particle" {
                    tempArr = tempArr + " " + "\(words[tokenRange])"
                }
            }
            return true
        }

        words_only = tempArr.stringByRemovingEmoji().unicodeScalars
            .filter { !$0.properties.isEmojiPresentation }
            .reduce("") { $0 + String($1) }.components(separatedBy: CharacterSet.alphanumerics.inverted)

        emoji_only = Array(tempArr.stringByRemovingWords()).map(String.init)

    }

    func countWords() -> [String: Int] {
        return words_only.reduce(into: [:]) { result, word in
            if word.isEmpty { return }
            result[word.lowercased(), default: 0] += 1
        }
    }
    
    func countEmojies() -> [String: Int] {
        return emoji_only.reduce(into: [:]) { result, word in
            if word.isEmpty { return }
            result[word, default: 0] += 1
        }
    }
    
    func getWordsByNumber(_ number: Int) -> Array<Dictionary<String, Int>.Element>.SubSequence {
        return self.countWords().sorted {
            if ($0.1 == $1.1) {
                return $0.0 < $1.0
            }
            return $0.1 > $1.1
        }.prefix(number)
    }
    
    func isTopWord(word: String) -> Bool {
        if word == getWordsByNumber(1).first?.key {
            return true
        }
        return false
    }
    
    func getCountStrings() -> WordCount {
        var tempArr : [String] = []
        for item in words_only {
            tempArr.append(item)
        }
        return WordCount(words: tempArr.seporateElements())
    }
    
}
