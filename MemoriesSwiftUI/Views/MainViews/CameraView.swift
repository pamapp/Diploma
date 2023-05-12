//
//  CameraView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 19.03.2023.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @EnvironmentObject var cameraModel: CameraVM
    
    var body: some View {
        
        GeometryReader { proxy in
            let size = proxy.size
            
            CameraPreview(size: size)
                .environmentObject(cameraModel)
                .mask(Circle())
                .overlay(
                    VStack {
                        Text(String(format: "%.2f", cameraModel.recordedDuration))
                    }
                )
        }
        .onAppear(perform: cameraModel.checkPermissions)
        .alert(isPresented: $cameraModel.alert) {
            Alert(title: Text("Please enable cameraModel access or microphone access"))
        }
        .onReceive(Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()) { _ in
            if cameraModel.recordedDuration <= cameraModel.maxDuration && cameraModel.isRecording {
                cameraModel.recordedDuration += 0.001
                if cameraModel.seconds <= cameraModel.maxDuration {
                    cameraModel.seconds += 1
                }
            }
            
            if cameraModel.recordedDuration >= cameraModel.maxDuration && cameraModel.isRecording {
                // Stopping recording
                cameraModel.stopRecording()
                cameraModel.isRecording = false
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @EnvironmentObject var cameraModel: CameraVM
    var size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        cameraModel.preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
        cameraModel.preview.frame.size = size
        cameraModel.preview.videoGravity = .resizeAspect
        view.layer.addSublayer(cameraModel.preview)
        cameraModel.session.startRunning()

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
}



//
//  Home.swift
//  CameraApp2
//
//  Created by Bradley Cox on 2/17/23.
//

import SwiftUI
import AVKit

struct Home: View {
    @StateObject var cameraModel = CameraVM()
    @State var finishRecord = false
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea(.all)

            // MARK: Camera View
            CameraView()
                .environmentObject(cameraModel)
//                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                .padding(.top, 10)
//                .padding(.bottom, 30)
                .background(BlurView(style: .systemMaterialDark, intensity: 1))
                .ignoresSafeArea()
            
            // MARK: Controls
            ZStack {
                Button {
                    if cameraModel.isRecording {
                        cameraModel.stopRecording()
                    } else {
                        cameraModel.startRecording()
                    }
                } label: {
                    Image(systemName: "play.fill")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.black)
                        .opacity(cameraModel.isRecording ? 0 : 1)
                        .padding(12)
                        .frame(width: 60, height:60)
                        .background{
                            Circle()
                                .stroke(cameraModel.isRecording ? .clear : .black)
                        }
                        .padding(6)
                        .background {
                            Circle()
                                .fill(cameraModel.isRecording ? .red : .white)
                        }
                }
                
                // Preview Button
                Button {
                    if let _ = cameraModel.previewURL {
                        cameraModel.showPreview.toggle()
                    }
                } label: {
                    Group {
                        if cameraModel.previewURL == nil && !cameraModel.recordedURLs.isEmpty {
                            // Merging Videos
                            ProgressView()
                                .tint(.black)
                        } else {
                            Label {
                                Image(systemName: "chevron.right")
                                    .font(.callout)
                            } icon: {
                                Text("Preview")
                            }
                            .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
                .opacity((cameraModel.previewURL == nil && !cameraModel.recordedURLs.isEmpty) || cameraModel.isRecording ? 0 : 1)
                
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 10)
            .padding(.bottom, 30)
            
            Button {
                cameraModel.recordedDuration = 0
                cameraModel.previewURL = nil
                cameraModel.recordedURLs.removeAll()
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .padding(.top)
        }
        .overlay(content: {
            if let url = cameraModel.previewURL, cameraModel.showPreview {
                FinalPreview(url: url, showPreview: $cameraModel.showPreview)
                    .transition(.move(edge: .trailing))
            }
        })
        .animation(.easeInOut, value: cameraModel.showPreview)
        .preferredColorScheme(.dark)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

// MARK: Final Video Preview
struct FinalPreview: View {
    var url: URL
    @Binding var showPreview: Bool
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            // MARK: Back Button
                .overlay(alignment: .topLeading) {
                    Button {
                        showPreview.toggle()
                    } label: {
                        Label {
                            Text("Back")
                        } icon: {
                            Image(systemName: "chevron.left")
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.leading)
                    .padding(.top, 22)
                }
        }
    }
}
