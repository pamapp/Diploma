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
                    .font(.memoryTextImage(18))
                    .foregroundColor(.c7)
            }
            Spacer()
        }
    }
}

struct MemoryCellView: View {
    @EnvironmentObject var quickActionSettings: QuickActionSettings
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
                    switch memory.safeType {
                    case ItemType.photo.rawValue:
                        CollageLayoutView(images: memory.mediaAlbum?.attachmentsArray ?? [],
                                          width: cellWidth)
                        .environmentObject(quickActionSettings)
                    case ItemType.text.rawValue:
                        memory.safeText.textWithHashtags(color: .c6)
                            .memoryTextBaseStyle()
                            .blur(radius: quickActionSettings.isPrivateModeEnabled ? 4.5 : 0)
                        
                    case ItemType.audio.rawValue:
                        MemoryVoiceView()
                        
                    case ItemType.textWithPhoto.rawValue:
                        CollageLayoutView(images: memory.mediaAlbum?.attachmentsArray ?? [],
                                          width: cellWidth)
                        .environmentObject(quickActionSettings)

                        memory.safeText.textWithHashtags(color: .c6)
                            .memoryTextImageStyle()
                            .blur(radius: quickActionSettings.isPrivateModeEnabled ? 4.5 : 0)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.c8)
                            )
                    default:
                        EmptyView()
                    }

                    HStack {
                        Text(memory.safeTimestampContent.getFormattedDateString(format: "HH:mm"))
                            .memoryTimeStyle()
                        Spacer()
                        
                        if memory.type == ItemType.audio.rawValue {
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
                
                if memory.type != ItemType.audio.rawValue && memory.type != ItemType.photo.rawValue && memory.isEditable {
                    GeometryReader { geo in
                        HStack {
                            editBtnView
                                .frame(width: geo.size.width / 2, height: geo.size.height)
                            Spacer()
                            deleteBtnView
                                .frame(width: geo.size.width / 2, height: geo.size.height)
                            
                        }
                    }
                } else {
                    GeometryReader { geo in
                        HStack {
                            deleteBtnView
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                }
            }
        }, itemHeight: cellHeight, endSwipeAction: $isSwipeable)
    }
    
    func MemoryVoiceView() -> some View {
        var isPlayingThisRecording: Bool {
            audioPlayer.currentlyPlaying?.id == memory.mediaAlbum?.attachmentsArray.first?.id
        }
        
        return HStack {
            ZStack {
                Button {
                    if let _ = audioPlayer.audioPlayer, let _ = audioPlayer.currentlyPlaying {
                        if audioPlayer.isPlaying {
                            // Pause
                            audioPlayer.pausePlayback()
                        } else {
                            // Play
                            audioPlayer.resumePlayback()
                        }
                    }
                } label: {
                    Image(audioPlayer.isPlaying ? UI.Buttons.pause_audio : UI.Buttons.play_audio)
                }
                
                Button {
                    audioPlayer.startPlayback(recording: (memory.mediaAlbum?.attachmentsArray.first)!)
                } label: {
                    Image(UI.Buttons.play_audio)
                }
                .opacity(audioPlayer.currentlyPlaying != nil ? 0 : 1)
                
            }

            Slider(value: $sliderValue, in: 0...((audioPlayer.currentlyPlaying != nil) ? audioPlayer.audioPlayer!.duration : 0)) { dragging in
                print("Editing the slider: \(dragging)")
                isDragging = dragging
                if !dragging && audioPlayer.currentlyPlaying != nil {
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
    
    var editBtnView: some View {
        Button(action: {
            withAnimation {
                isSwipeable.toggle()
                self.edit()
            }
            
        }, label: {
            Image(UI.Icons.edit)
                .foregroundColor(.c6)
        })
    }
    
    var deleteBtnView: some View {
        Button(action: {
            withAnimation {
                isSwipeable = false
                self.delete()
            }
        }, label: {
            Image(UI.Icons.trash)
                .foregroundColor(.c5)
        })
    }
}
