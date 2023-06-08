//
//  AudioRecorderVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 03.05.2023.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreData

class AudioRecorderVM: NSObject, ObservableObject {
    @Published private var recordingName = "Recording"
    @Published private var recordingDate = Date()
    @Published private var recordingURL: URL?
    @Published var isRecording = false
    
    var audioRecorder: AVAudioRecorder?
    var itemModel: ItemVM

    init(itemModel: ItemVM) {
        self.itemModel = itemModel
    }
    
    // MARK: - Start Recording
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            print("Start Recording - Recording session setted")
        } catch {
            print("Start Recording - Failed to set up recording session")
        }
        
        let currentDateTime = Date.now
        
        recordingDate = currentDateTime
        recordingName = "\(currentDateTime.toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss"))"
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let recordingFileURL = tempDirectory.appendingPathComponent(recordingName).appendingPathExtension("m4a")
        recordingURL = recordingFileURL
        
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                        AVEncoderBitRateKey: 96000,
                        AVNumberOfChannelsKey: 2,
                        AVSampleRateKey: 44100.0 ] as [String : Any]

        do {
            audioRecorder = try AVAudioRecorder(url: recordingFileURL, settings: settings)
            audioRecorder?.record()
            
            withAnimation {
                isRecording = true
            }
            print("Start Recording - Recording Started")
        } catch {
            print("Start Recording - Could not start recording")
        }
    }
    
    // MARK: - Stop Recording
    
    func stopRecording(chapter: ChapterMO) {
        audioRecorder?.stop()
        withAnimation {
            isRecording = false
        }
        
        if let recordingURL {
            do {
                let recordingData = try Data(contentsOf: recordingURL)
                print("Stop Recording - Saving to CoreData")
                // save the recording to CoreData
                saveRecordingOnCoreData(chapter: chapter, recordingData: recordingData)
            } catch {
                print("Stop Recording - Could not save to CoreData - Cannot get the recording data from URL: \(error)")
            }
            
        } else {
            print("Stop Recording -  Could not save to CoreData - Cannot find the recording URL")
        }
        
    }
    
    // MARK: - CoreData
    
    func saveRecordingOnCoreData(chapter: ChapterMO, recordingData: Data) {
        itemModel.addItemMedia(chapter: chapter, attachments: [recordingData], type: ItemType.audio.rawValue)
    }
    
    func deleteRecordingFile() {
        if let recordingURL {
            do {
               try FileManager.default.removeItem(at: recordingURL)
                print("Stop Recording - Successfully deleted the recording file")
            } catch {
                print("Stop Recording - Could not delete the recording file - Cannot find the recording URL")
            }
        }
    }
    
}
