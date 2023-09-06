//
//  InputAccessoryView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI
import PhotosUI

struct InputAccessoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var chapterViewModel: ChapterVM
    
    @ObservedObject var itemViewModel: ItemVM
    @ObservedObject var audioRecorder: AudioRecorderVM
    @ObservedObject var audioPlayerVM: AudioPlayerVM
    
    @Binding var isKeyboardPresented: Bool

    @State private var showCameraView: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showImagePickerInTF: Bool = false
    @State private var showPHPAlert: Bool = false
    @State private var showMicroAlert: Bool = false

    @State private var isRecording: Bool = false

    
    var message: Binding<String> {
        Binding<String>(
            get: { chapterViewModel.message },
            set: { chapterViewModel.message = $0 }
        )
    }
    
    @State private var containerHeight : CGFloat = 0

    @State private var selectedItems: [UIImage] = []
    @State private var selectionsvideo = [URL]()
    @State private var selectedImagesData: [Data] = []
    
    var chapter: ChapterMO
    
    init(chapter: ChapterMO, audioPlayer: AudioPlayerVM, chapterVM: ChapterVM, isKeyboardPresented: Binding<Bool>) {
        self.itemViewModel = ItemVM(moc: PersistenceController.shared.viewContext, chapter: chapter)
        self.audioRecorder = AudioRecorderVM(itemModel: ItemVM(moc: PersistenceController.shared.viewContext, chapter: chapter))
        self.audioPlayerVM = audioPlayer
        self.chapter = chapter
        self._isKeyboardPresented = isKeyboardPresented
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
                    
                    AutosizingTextField(text: message, containerHeight: $containerHeight, isFirstResponder: isKeyboardPresented, send: {
                        if chapterViewModel.isEditingMessage == true {
                            self.editItem()
                        } else {
                            self.addItem()
                        }
                    }, media: {
                        PHPhotoLibrary.requestAuthorization { status in
                            switch status {
                            case .authorized, .limited:
                                self.showImagePickerInTF.toggle()
                                break
                            case .denied, .restricted, .notDetermined:
                                self.showPHPAlert.toggle()
                                break
                            @unknown default:
                                break
                            }
                        }
                    })
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
    
    private var recordingDuration: some View {
        HStack(spacing: 8) {
            if let audioRecorder = audioRecorder.audioRecorder, audioRecorder.isRecording {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text("-\(DateComponentsFormatter.positional.string(from: audioRecorder.currentTime) ?? "0:00")")
                        .memoryRecordingDurationStyle()
                }
            }
            Circle()
                .frame(width: 10)
                .foregroundColor(.c5)
        }.padding(.leading, 16)
    }
    
    private var attachmentBtnView: some View {
        Button {
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized, .limited:
                    self.showImagePicker.toggle()
                    break
                case .denied, .restricted, .notDetermined:
                    self.showPHPAlert.toggle()
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
        .alert(isPresented: $showPHPAlert) {
            Alert(title: Text(UI.Alearts.php_alert_title.localized()),
                  message: Text(UI.Alearts.php_message_text.localized()),
                  primaryButton: .default(Text(UI.Alearts.php_primaryBtn_text.localized())),
                  secondaryButton: .default(Text(UI.Alearts.php_secondaryBtn_text.localized()), action: {
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                              UIApplication.shared.open(settingsURL)
                  }))
        }
        .transition(.scale)
        .sheet(isPresented: $showImagePicker) {
            ImagesPicker(selections: $selectedItems, selectionsVideo: $selectionsvideo, addFunc: withAnimation { addItem })
        }
        .opacity(isRecording ? 0 : 1)
    }
    
    private var audioBtnView: some View {
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
        .alert(isPresented: $showMicroAlert) {
            Alert(title: Text(UI.Alearts.micro_alert_title.localized()),
                  message: Text(UI.Alearts.micro_message_text.localized()),
                  primaryButton: .default(Text(UI.Alearts.micro_primaryBtn_text.localized())),
                  secondaryButton: .default(Text(UI.Alearts.micro_secondaryBtn_text.localized()), action: {
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                              UIApplication.shared.open(settingsURL)
                  }))
        }
        .transition(.scale)
        .onTapGesture {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async { }
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
//            switch AVAudioSession.sharedInstance().recordPermission {
//            case .granted:
                if !audioRecorder.isRecording {
                    withAnimation {
                        self.isRecording = true
                    }
                    startRecording()
                }
//            case .denied, .undetermined:
//                self.showMicroAlert.toggle()
//            @unknown default:
//                break
//            }
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
    
    private func editItem() {
        chapterViewModel.editItem(itemVM: itemViewModel, text: message.wrappedValue)
    }
    
    private func addItem() {
        chapterViewModel.addChapter()
        
        let currentMessage = message.wrappedValue
        
        if !selectedItems.isEmpty {
            for selectedItem in selectedItems {
                if let data = selectedItem.jpegData(compressionQuality: 0.8) {
                    selectedImagesData.append(data)
                }
            }
        }
        
        if !currentMessage.isEmpty && selectedImagesData.isEmpty {
            itemViewModel.addItemParagraph(chapter: chapter, text: currentMessage)
        } else if !currentMessage.isEmpty && !selectedImagesData.isEmpty  {
            itemViewModel.addItemParagraphAndMedia(chapter: chapter, attachments: selectedImagesData, text: currentMessage)
        } else {
            itemViewModel.addItemMedia(chapter: chapter, attachments: selectedImagesData, type: ItemType.photo.rawValue)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        selectedItems.removeAll()
        selectedImagesData.removeAll()
        message.wrappedValue = ""
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
