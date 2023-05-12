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
                Text(UI.Strings.empty_chapter_text)
                    .font(.memoryTextBase())
                    .foregroundColor(.c7)
            }
            Spacer()
        }
    }
}

struct MemoryCellView: View {
    @ObservedObject var audioPlayer: AudioPlayerVM
    @State private var sliderValue: Double = 0.0
    @State private var isDragging = false
    @State private var isSwipeable = false
    
    @State var cellHeight: CGFloat = 0
    @State var cellWidth: CGFloat = UIScreen.main.bounds.width - 32

    let timer = Timer
        .publish(every: 0.01, on: .main, in: .common)
        .autoconnect()
    
    var memory: ItemMO
    var delete: ()->()
    var edit: ()->()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(memory: ItemMO, delete: @escaping ()->(), edit: @escaping ()->()) {
        self.memory = memory
        self.audioPlayer = AudioPlayerVM()
        self.delete = delete
        self.edit = edit
        
        let thumbImage : UIImage = UIImage(named: UI.Icons.drower)!        
        UISlider.appearance().minimumTrackTintColor = UIColor(.c3)
        UISlider.appearance().maximumTrackTintColor = UIColor(.c4)
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }

    var body: some View {
        SwipeItem(content: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 2.3)
                    .foregroundColor(memory.safeSentimentColor)
                
                VStack(alignment: .leading, spacing: 8) {
                    if memory.safeType == "photo" {
                        if memory.mediaAlbum?.attachmentsArray.count == 1 {
                            CollageLayoutOne(images: memory.mediaAlbum?.attachmentsArray ?? [], width: cellWidth)
                        } else if memory.mediaAlbum?.attachmentsArray.count == 2 {
                            CollageLayoutTwo(images: memory.mediaAlbum?.attachmentsArray ?? [], width: cellWidth)
                        } else {
                            CollageLayoutThree(images: memory.mediaAlbum?.attachmentsArray ?? [], width: cellWidth)
                        }
                    }

                    if memory.safeType == "text" {
                        memory.safeText.textWithHashtags(color: .c6)
                            .memoryTextBaseStyle()
                    }
                    
                    if memory.safeType == "audio" {
                        MemoryVoiceView()
                    }
                    
                    if memory.safeType == "textWithPhoto" {
                        if memory.mediaAlbum?.attachmentsArray.count == 1 {
                            CollageLayoutOne(images: memory.mediaAlbum?.attachmentsArray ?? [], width: cellWidth)
                        } else if memory.mediaAlbum?.attachmentsArray.count == 2 {
                            CollageLayoutTwo(images: memory.mediaAlbum?.attachmentsArray ?? [], width: cellWidth)
                        } else {
                            CollageLayoutThree(images: memory.mediaAlbum?.attachmentsArray ?? [], width: cellWidth)
                        }
                        
                        memory.safeText.textWithHashtags(color: .c6)
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
                .background (
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                let height = proxy.size.height
                                self.cellHeight = height
                            }
                    }
                )
            }
        },
        right: {
            HStack {
                Rectangle()
                    .foregroundColor(.c8)
                    .frame(width: 2)
                Spacer()
                
                GeometryReader { geo in
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.edit()
                            }
                            
                        }, label: {
                            Image(UI.Icons.edit)
                                .foregroundColor(.c6)
                        })
                        .frame(width: geo.size.width / 2, height: geo.size.height)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.delete()
                            }
                        }, label: {
                            Image(UI.Icons.trash)
                                .foregroundColor(.c5)
                        })
                        .frame(width: geo.size.width / 2, height: geo.size.height)
                    }
                }
            }
        }, itemHeight: cellHeight, endSwipeAction: $isSwipeable)
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
                Image(audioPlayer.isPlaying ? UI.Buttons.pause_audio : UI.Buttons.play_audio)
            }

            Slider(value: $sliderValue, in: 0...((audioPlayer.currentlyPlaying != nil) ? audioPlayer.audioPlayer!.duration : 0)) { dragging in
                print("Editing the slider: \(dragging)")
                isDragging = dragging
                if !dragging {
                    audioPlayer.audioPlayer!.currentTime = sliderValue
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing, 8)
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
