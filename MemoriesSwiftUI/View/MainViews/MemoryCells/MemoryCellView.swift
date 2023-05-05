//
//  MemoryCellView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 24.03.2023.
//

import SwiftUI
import AVFoundation

struct MemoryEmptyCellView: View {
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 2)
                .foregroundColor(.c8)
            
            VStack {
                Text("Сегодня записей нет")
                    .font(.memoryTextBase())
                    .foregroundColor(.c7)
            }
            Spacer()
        }
    }
}

struct MemoryCellView: View {
    @ObservedObject var audioPlayer: AudioPlayerVM
    @State var sliderValue: Double = 0.0
    @State private var isDragging = false
    
    let timer = Timer
        .publish(every: 0.01, on: .main, in: .common)
        .autoconnect()
    
    
    var memory: ItemMO
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(memory: ItemMO) {
        self.memory = memory
        self.audioPlayer = AudioPlayerVM()
        
        let thumbImage : UIImage = UIImage(named: "drower")!
//        let size = CGSizeMake(thumbImage.size.width * 0.4, thumbImage.size.height * 0.4)
        
        UISlider.appearance().minimumTrackTintColor = UIColor(.c3)
        UISlider.appearance().maximumTrackTintColor = UIColor(.c4)
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 2.3)
                    .foregroundColor(memory.safeSentimentColor)
                
                VStack(alignment: .leading, spacing: 8) {
                    if memory.safeType == "photo" {
                        if memory.mediaAlbum?.attachmentsArray.count == 1 {
                            CollageLayoutOne(images: memory.mediaAlbum?.attachmentsArray ?? [])
                        } else if memory.mediaAlbum?.attachmentsArray.count == 2 {
                            CollageLayoutTwo(images: memory.mediaAlbum?.attachmentsArray ?? [])
                        } else {
                            CollageLayoutThree(images: memory.mediaAlbum?.attachmentsArray ?? [])
                        }
                    }

                    if memory.safeType == "text" {
                        Text(memory.safeText)
                            .memoryTextBaseStyle()
                            .textSelection(.enabled)
                    }
                    
                    if memory.safeType == "audio" {
                        MemoryVoiceView()
                    }
                    
                    if memory.safeType == "textWithPhoto" {
                        if memory.mediaAlbum?.attachmentsArray.count == 1 {
                            CollageLayoutOne(images: memory.mediaAlbum?.attachmentsArray ?? [])
                        } else if memory.mediaAlbum?.attachmentsArray.count == 2 {
                            CollageLayoutTwo(images: memory.mediaAlbum?.attachmentsArray ?? [])
                        } else {
                            CollageLayoutThree(images: memory.mediaAlbum?.attachmentsArray ?? [])
                        }
                        
                        Text(memory.safeText)
                            .memoryTextImageStyle()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.c8)
                            )
                    }
                    
                    HStack {
                        Text(memory.safeTimestampContent.getFormattedDateString(format: "HH:mm"))
                            .memoryTimeStyle()
                        Spacer()
                        if memory.type == "audio" {
                            if audioPlayer.audioPlayer != nil {
                                Text("-\(DateComponentsFormatter.positional.string(from: (audioPlayer.audioPlayer!.duration - audioPlayer.audioPlayer!.currentTime) ) ?? "0:00")")
                                    .memoryAudioTimeStyle()
                            } else {
                                if let recordingData = memory.mediaAlbum?.attachmentsArray.first?.data, let duration = getDuration(of: recordingData) {
                                    Text(DateComponentsFormatter.positional.string(from: duration) ?? "0:00")
                                        .memoryAudioTimeStyle()
                                }
                            }
                        }
                    }
                }
            }
            
            
        }
    }
    
    
    @ViewBuilder
    func MemoryVoiceView() -> some View {
        HStack {
            Button {
                if audioPlayer.isPlaying {
                    // Pause
                    audioPlayer.pausePlayback()
                } else {
                    // Play
                    audioPlayer.startPlayback(recording: (memory.mediaAlbum?.attachmentsArray.first)!)

//                    audioPlayer.resumePlayback()
                }
            } label: {
                Image(audioPlayer.isPlaying ? "pause-audio" : "play-audio")
            }

            Slider(value: $sliderValue, in: 0...((audioPlayer.currentlyPlaying != nil) ? audioPlayer.audioPlayer!.duration : 0)) { dragging in
                print("Editing the slider: \(dragging)")
                isDragging = dragging
                if !dragging {
                    audioPlayer.audioPlayer!.currentTime = sliderValue
                }
            }
            .frame(maxWidth: .infinity)
//            .tint(.c3)
        }
        .onAppear {
            sliderValue = 0
        }
        .onReceive(timer) { _ in
            guard let player = audioPlayer.audioPlayer, !isDragging else { return }
            sliderValue = player.currentTime
        }
    }
    
    func getDuration(of recordingData: Data) -> TimeInterval? {
        do {
            return try AVAudioPlayer(data: recordingData).duration
        } catch {
            print("Failed to get the duration for recording on the list: Recording")
            return nil
        }
    }
}

//
//struct MemoryVoiceView: View {
//    @ObservedObject var audioPlayer: AudioPlayerVM
//    @State var sliderValue: Double = 0.0
//    @State private var isDragging = false
//
//    var media: MediaMO
//
//    let timer = Timer
//        .publish(every: 0.01, on: .main, in: .common)
//        .autoconnect()
//
//    init(media: MediaMO, audioPlayer: AudioPlayerVM) {
//        self.media = media
//        self.audioPlayer = audioPlayer
//
//        let thumbImage : UIImage = UIImage(named: "Drower")!
//        let size = CGSizeMake( thumbImage.size.width * 0.4, thumbImage.size.height * 0.4 )
//        UISlider.appearance().minimumTrackTintColor = UIColor(.c3)
//        UISlider.appearance().maximumTrackTintColor = UIColor(.c4)
//        UISlider.appearance().setThumbImage(thumbImage.scaled(to: size), for: .normal)
//    }
//
//    var body: some View {
//        HStack {
//            Button {
//                if audioPlayer.isPlaying {
//                    // Pause
//                    audioPlayer.pausePlayback()
//                } else {
//                    // Play
//                    audioPlayer.startPlayback(recording: media )
//
////                    audioPlayer.resumePlayback()
//                }
//            } label: {
//                Image(audioPlayer.isPlaying ? "pause-audio" : "play-audio")
//            }
//
//            Slider(value: $sliderValue, in: 0...((audioPlayer.currentlyPlaying != nil) ? audioPlayer.audioPlayer!.duration : 0)) { dragging in
//                print("Editing the slider: \(dragging)")
//                isDragging = dragging
//                if !dragging {
//                    audioPlayer.audioPlayer!.currentTime = sliderValue
//                }
//            }
//            .tint(.c3)
//
//            if let recordingData = media.data, let duration = getDuration(of: recordingData) {
//                Text(DateComponentsFormatter.positional.string(from: duration) ?? "0:00")
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .onAppear {
//            sliderValue = 0
//        }
//        .onReceive(timer) { _ in
//            guard let player = audioPlayer.audioPlayer, !isDragging else { return }
//            sliderValue = player.currentTime
//        }
//    }
//
//    func getDuration(of recordingData: Data) -> TimeInterval? {
//        do {
//            return try AVAudioPlayer(data: recordingData).duration
//        } catch {
//            print("Failed to get the duration for recording on the list: Recording")
//            return nil
//        }
//    }
//}
//
