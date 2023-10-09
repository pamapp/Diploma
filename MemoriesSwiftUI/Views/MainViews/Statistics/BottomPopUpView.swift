//
//  BottomPopUpView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.05.2023.
//

import SwiftUI

struct BottomPopUpView: View {
    @ObservedObject var popUpVM: PopUpVM
    
    @GestureState private var translation: CGFloat = 0
    
    @State private var maxHeight: CGFloat = 0
    
     var type: String
    
    private let width: CGFloat = UI.screen_width - 32
    private var offset: CGFloat {
        popUpVM.isVisible ? 0 : maxHeight + (self.maxHeight / 2)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.cW)
                    .overlay (
                        GeometryReader { geo in
                            VStack(spacing: 16) {
                                if type == "settings" {
                                    Image(UI.PopUp.watering_a_flower)
                                        .imageInPopUpStyle(w: geo.size.width - 32)
                                }
                                
                                VStack(spacing: 8) {
                                    Text(UI.Strings.stats_description_title.localized())
                                        .statsPopUpTitleStyle()
                                    
                                    Text(UI.Strings.stats_description_text.localized())
                                        .statsPopUpTextStyle()
                                }.padding(.bottom, 48)
                                
                                Button(action: {
                                    withAnimation {
                                        popUpVM.disablePopUp()
                                    }
                                }, label: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .foregroundColor(.c3)
                                        .overlay(
                                            Text(UI.Strings.stats_description_btn_text.localized())
                                                .foregroundColor(.cW)
                                                .font(.title(17))
                                        )
                                })
                                .frame(height: geo.size.width / 6)
                                
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background (
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            maxHeight = proxy.size.height
                                        }
                                }
                            )
                        }
                    )
            }
            .frame(width: width, height: maxHeight)
            .cornerRadius(32)
            .frame(height: geometry.size.height - 32, alignment: .bottom)
            .offset(x: geometry.size.width / 2 - width / 2, y: max(self.offset + self.translation, 0))
            .animation(Animation.interpolatingSpring(mass: 1, stiffness: 300, damping: 20, initialVelocity: 0), value: popUpVM.isVisible)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    let snapDistance = self.maxHeight * 0.3
                    
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    withAnimation {
                        popUpVM.isVisible = value.translation.height < 0
                    }
                }
            )
        }
        .background {
            if popUpVM.isVisible {
                Color.cB.opacity(0.25)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                            withAnimation(.easeInOut) {
                                popUpVM.disablePopUp()
                            }
                    }
            }
        }
    }
}

struct ButtonCustomStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            .animation(.linear(duration: 1), value: 1)
    }
}
