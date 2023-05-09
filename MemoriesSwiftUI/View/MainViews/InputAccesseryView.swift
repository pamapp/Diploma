//
//  InputAccesseryView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI
import PhotosUI
import AVKit

struct InputAccesseryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var itemViewModel: ItemVM
    @ObservedObject var chapterViewModel: ChapterVM
    @ObservedObject var cameraModel: CameraVM
    @ObservedObject var audioRecorder: AudioRecorderVM
    @ObservedObject var audioPlayerVM: AudioPlayerVM
    
    @State var showCameraView: Bool = false
    @State var isRecording: Bool = false
    @State var showImagePicker: Bool = false
    @State var showImagePickerInTF: Bool = false

    @State var showAlert: Bool = false

    @State private var message = ""
    @Binding var isKeyboardPresented: Bool
    @State var containerHeight : CGFloat = 0

    @State private var selectedItems: [UIImage] = []
    @State private var selectionsvideo = [URL]()

    @State private var selectedImagesData: [Data] = []
    
    var chapter: ChapterMO
    
    init(chapter: ChapterMO, audioPlayer: AudioPlayerVM, chapterVM: ChapterVM, isKeyboardPresented: Binding<Bool>) {
        self.itemViewModel = ItemVM(chapter: chapter)
        self.audioRecorder = AudioRecorderVM(itemModel: ItemVM(chapter: chapter))
        self.audioPlayerVM = audioPlayer
        self.cameraModel = CameraVM()
        self.chapter = chapter
        self._isKeyboardPresented = isKeyboardPresented
        self.chapterViewModel = chapterVM
        itemViewModel.fetchItems()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if !isKeyboardPresented {
                    if !isRecording {
                        attachmentBtnView
                    } else {
                        recordingDuration
                    }
                }
                VStack {
                    if !selectedItems.isEmpty && isKeyboardPresented {
                        HStack(alignment: .bottom, spacing: 20) {
                            ForEach(selectedItems, id: \.self) { item in
                                Image(uiImage: item)
                                    .imageInTFStyle(w: 42, h: 42)
                                    .overlay(
                                        Button(action: {
                                            withAnimation {
                                                selectedItems.removeAll(where: { $0 == item })
                                            }
                                        }, label: {
                                            Image(UI.Icons.cross_white)
                                        })
                                        .offset(x: 18, y: -18)
                                    )
                            }
                            Spacer()
                        }
                        .transition(.opacity)
                        .padding(.top, 28)
                        .padding(.leading, 16)
                        .transition(.opacity)
                    }
                    
                    AutosizingTF(text: $message, containerHeight: $containerHeight, isFirstResponder: isKeyboardPresented, opened: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }, send: {
                        self.addItem()
                    }, media: {
                        self.showImagePickerInTF.toggle()
                    })
//                    .transition(.scale)
//                    .animation(.easeInOut(duration: 1), value: isKeyboardPresented)

                    .padding(.horizontal, 8)
                    .frame(height: containerHeight <= 150 ? containerHeight : 150)
                    .sheet(isPresented: $showImagePickerInTF) {
                        ImagesPicker(selections: $selectedItems, selectionsVideo: $selectionsvideo, addFunc: {})
                    }
                    .onTapGesture {
                        withAnimation {
                            isKeyboardPresented = true
                        }
                    }
                }.opacity(isRecording ? 0 : 1)
                
                if !isKeyboardPresented {
                    audioBtnView
                }
            }
            .background(backgroundColor)
            .animation(.default, value: isKeyboardPresented)
            .cornerRadius(isKeyboardPresented ? 8 : 16, corners: isKeyboardPresented ? [.topLeft, .topRight] : [.allCorners])
            .padding(.horizontal, isKeyboardPresented ? 0 : 16)
        }
    }
    
    private var backgroundColor: Color {
        if isKeyboardPresented && !isRecording {
            return .white
        } else if !isKeyboardPresented && !isRecording {
            return Color.c2
        } else {
            return .c1
        }
    }
    
    var recordingDuration: some View {
        HStack(spacing: 8) {
            if let audioRecorder = audioRecorder.audioRecorder, audioRecorder.isRecording {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text("-\(DateComponentsFormatter.positional.string(from: audioRecorder.currentTime) ?? "0:00")")
                        .font(.bodyText(15))
                        .foregroundColor(.c7)
                        .frame(width: 50)
                }
            }
            Circle()
                .frame(width: 10)
                .foregroundColor(.c5)
        }.padding(.leading, 16)
    }
    
    var attachmentBtnView: some View {
        Button {
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized, .limited:
                    self.showImagePicker.toggle()
                    break
                case .denied, .restricted, .notDetermined:
                    self.showAlert.toggle()
                    break
                @unknown default:
                    break
                }
            }
        } label: {
            HStack(spacing: 0) {
                Image(UI.Icons.attachments)
                    .padding(16)
                    .foregroundColor(.cW)
                Rectangle()
                    .frame(width: 2, height: 44)
                    .foregroundColor(.c3)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(UI.Alearts.alert_title),
                  message: Text(UI.Alearts.message_text),
                  primaryButton: .default(Text(UI.Alearts.primaryBtn_text)),
                  secondaryButton: .default(Text(UI.Alearts.secondaryBtn_text), action: {
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                              UIApplication.shared.open(settingsURL)
                  }))
        }
        .transition(.scale)
//        .animation(.none, value: isKeyboardPresented)

        .sheet(isPresented: $showImagePicker) {
            ImagesPicker(selections: $selectedItems, selectionsVideo: $selectionsvideo, addFunc: withAnimation { addItem })
        }
        .opacity(isRecording ? 0 : 1)
    }
    
    var audioBtnView: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 2, height: 44)
                .foregroundColor(.c3)
                .opacity(isRecording ? 0 : 1)
            ZStack {
                Image(UI.Icons.audio_message)
                    .padding(16)
                    .foregroundColor(isRecording ? .c5 : .cW)
            }
        }
        .transition(.scale)
        .onLongPressGesture(minimumDuration: 0.01) {
            if !audioRecorder.isRecording {
                startRecording()
                withAnimation {
                    self.isRecording = true
                }
            }
         }
         .simultaneousGesture(
             DragGesture(minimumDistance: 0)
                .onEnded{ _ in
                    if audioRecorder.isRecording {
                        stopRecording()
                        withAnimation {
                            self.isRecording = false
                        }
                    }
                }
         )
    }
    
    private func addItem() {
        chapterViewModel.addChapter()
        
        if !selectedItems.isEmpty {
            for selectedItem in selectedItems {
                if let data = selectedItem.jpegData(compressionQuality: 0.8) {
                    selectedImagesData.append(data)
                }
            }
        }
        
        if !message.isEmpty && selectedImagesData.isEmpty {
            itemViewModel.addItemParagraph(chapter: chapter, text: message)
        } else if !message.isEmpty && !selectedImagesData.isEmpty  {
            itemViewModel.addItemParagraphAndMedia(chapter: chapter, attachments: selectedImagesData, text: message)
        } else {
            itemViewModel.addItemMedia(chapter: chapter, attachments: selectedImagesData, type: "photo")
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        selectedItems.removeAll()
        selectedImagesData.removeAll()
        message = ""
    }
    
    func startRecording() {
        if audioPlayerVM.audioPlayer?.isPlaying ?? false {
            // stop any playing recordings
            audioPlayerVM.stopPlayback()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Start Recording
                audioRecorder.startRecording()
            }
        } else {
            // Start Recording
            audioRecorder.startRecording()
        }
    }
    
    func stopRecording() {
        // Stop Recording
        audioRecorder.stopRecording(chapter: chapter)
    }
}




//if showCameraView {
//    CameraView()
//        .environmentObject(cameraModel)
//        .background(BlurView(style: .systemMaterialDark, intensity: 1))
//        .ignoresSafeArea()
//}
