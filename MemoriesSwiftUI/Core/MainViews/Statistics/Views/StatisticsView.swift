//
//  StatisticsView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 05.04.2023.
//

import SwiftUI
import Foundation

enum Tab: String {
    case week = "Нед", month = "Мес", year = "Год"
}

struct StatisticsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var quickActionSettings: QuickActionVM
    @EnvironmentObject var popUpViewModel: BottomPopUpVM
    
    @ObservedObject var chapterViewModel: ChapterVM
    @ObservedObject var statsViewModel: StatisticsVM

    @State private var currentTab: Tab = .week
    @State private var totalHeight: CGFloat = CGFloat.zero
//    @State private var isPopUpPresented = false
    
    @State var offset : CGFloat = 0
    
    let maxHeight = UIScreen.main.bounds.height / 4
    
    var topEdge: CGFloat
    
    init(chapterModel: ChapterVM, topEdge: CGFloat) {
        self.chapterViewModel = chapterModel
        self.statsViewModel = StatisticsVM(chapterModel: chapterModel)
        self.topEdge = topEdge
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    GeometryReader { proxy in
                        StatusView(topEge: topEdge, offset: $offset, maxHeight: maxHeight)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: getHeaderHeight(), alignment: .bottom)
                            .background(
                                Color.theme.c4,
                                in: RoundedCorner(radius: getCornerRadius(), corners: [.bottomRight, .bottomLeft])
                            )
                            .overlay(simplifiedHeader, alignment: .top)
                    }
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: maxHeight)
                    .offset(y: -offset)
                    .zIndex(1)
                    
                    VStack(spacing: 32) {
                        PrivateMode()
                        
                        ChartView(title: UI.Strings.mood_chart_title,
                                  text: UI.Strings.mood_chart_text)

                        TopEmojiView(title: UI.Strings.emoji_top,
                                     sequence: statsViewModel.popularEmojies)

                        TopWordsView(title: UI.Strings.words_top_title,
                                     text: UI.Strings.words_top_text,
                                     sequence: statsViewModel.popularWords)
                    }
                    .padding(.horizontal, 16)
                    .background(Color.theme.cW.edgesIgnoringSafeArea(.all))
                    .zIndex(0)
                }
                .modifier(OffsetModifier(offset: $offset))
            }
            .coordinateSpace(name: "stats_scroll")
            
            BottomPopUpView(popUpVM: popUpViewModel, type: "settings")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    func StatusView(topEge: CGFloat, offset: Binding<CGFloat>, maxHeight: CGFloat) -> some View {
        VStack(spacing: 16) {
            HStack {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(Color.theme.c8)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(chapterViewModel.getStatusImage())
                            .resizable()
                            .frame(width: 64, height: 84)
                    )
                    .shadowFloating()
                    .onTapGesture {
                        withAnimation {
                            popUpViewModel.enablePopUp()
//                            self.isPopUpPresented.toggle()
                        }
                    }
            }
            statusIndicator
        }
        .padding(.bottom, 24)
        .opacity(getOpacity())
    }
    
    func PrivateMode() -> some View {
        VStack(spacing: 8) {
            Toggle(isOn: $quickActionSettings.isPrivateModeEnabled) {
                HStack {
                    Image(UI.Icons.incognito)
                        .padding(9)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.theme.c8)
                        }
                    Text(UI.Strings.privacy_mode_title.localized())
                        .font(.title(17))
                }
            }
            .tint(Color.theme.c2)
            
            HStack {
                Text(UI.Strings.privacy_mode_text.localized())
                    .statsSubTitleStyle()
                Spacer()
            }
        }
    }
    
    func ChartView(title: String, text: String) -> some View {
        VStack(spacing: 24) {
            sectionHeaderItem(title: title, subtitle: text)

            ZStack {
                chartBody
                
                if statsViewModel.moodDynamics.isEmpty {
                    VStack {
                        Spacer()
                        
                        Text(UI.Strings.mood_chart_empty_text.localized())
                            .chartEmptyTextStyle()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(statsViewModel.moodDynamics.isEmpty ? Color.theme.c8 : Color.theme.c11.opacity(0.2))
            }
            .overlay(
                DottedLine()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [2]))
                    .frame(height: 2)
                    .foregroundColor(Color.theme.cW)
            )
            .frame(height: 178)
        }
    }
    
    func TopEmojiView(title: String, sequence: Array<Dictionary<String, Int>.Element>.SubSequence) -> some View {
        VStack(spacing: 24) {
            HStack {
                Text(title)
                    .statsTitleStyle()
                Spacer()
            }
    
            HStack(alignment: .center) {
                if sequence.isEmpty {
                    ForEach(0...4, id: \.self) {_ in
                        emojiItem(key: UI.Icons.emoji, value: 0)
                    }
                } else {
                    ForEach(sequence, id: \.key) { key, value in
                        emojiItem(key: key, value: value)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func TopWordsView(title: String, text: String, sequence: Array<Dictionary<String, Int>.Element>.SubSequence) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        VStack(spacing: 24) {
            sectionHeaderItem(title: title, subtitle: text)
            
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        if sequence.isEmpty {
                            ForEach(UI.Strings.words_top_empty, id: \.self) { item in
                                wordItem(key: item, value: 0)
                                    .padding([.horizontal, .vertical], 4)
                                    .alignmentGuide(.leading, computeValue: { d in
                                        if (abs(width - d.width) > geometry.size.width) {
                                            width = 0
                                            height -= d.height
                                        }
                                        let result = width
                                        if UI.Strings.words_top_empty.first(where: { $0 == item }) == UI.Strings.words_top_empty.last {
                                            width = 0
                                        } else {
                                            width -= d.width
                                        }
                                        return result
                                    })
                                    .alignmentGuide(.top, computeValue: {d in
                                        let result = height
                                        if UI.Strings.words_top_empty.first(where: { $0 == item }) == UI.Strings.words_top_empty.last {
                                            height = 0
                                        }
                                        return result
                                    })
                            }
                        } else {
                            ForEach(sequence, id: \.key) { key, value in
                                wordItem(key: key, value: value)
                                    .padding([.horizontal, .vertical], 4)
                                    .alignmentGuide(.leading, computeValue: { d in
                                        if (abs(width - d.width) > geometry.size.width) {
                                            width = 0
                                            height -= d.height
                                        }
                                        let result = width
                                        if sequence.first(where: { $0.key == key })?.key == sequence.last?.key {
                                            width = 0
                                        } else {
                                            width -= d.width
                                        }
                                        return result
                                    })
                                    .alignmentGuide(.top, computeValue: {d in
                                        let result = height
                                        if sequence.first(where: { $0.key == key })?.key == sequence.last?.key {
                                            height = 0
                                        }
                                        return result
                                    })
                            }
                        }
                    }.background(viewHeightReader($totalHeight))
                }
            }
            .frame(height: totalHeight).padding(.trailing, 8)
        }
    }
}

extension StatisticsView {
    
    // MARK: - Private Variables
    
    // View Objects Without Parameters
    
    private var statusIndicator: some View {
        HStack(spacing: 2) {
            ForEach(1...7, id: \.self) { i in
                Circle()
                    .fill(chapterViewModel.statusValue < i ? Color.theme.c8 : Color.theme.c6)
                    .frame(width: 10)
            }
        }
    }
    
    private var chartBody: some View {
        let pathProvider = LineChartProvider(data: statsViewModel.moodDynamics, lineRadius: 0.5)
        return GeometryReader { geometry in
            ZStack {
                pathProvider.closedPath(for: geometry)
                    .fill(Color.theme.c11)
                            
                pathProvider.path(for: geometry)
                    .stroke(Color.theme.cW, style: StrokeStyle(lineWidth: 2.5))
            }
        }
    }
    
    private var simplifiedHeader: some View {
        ZStack {
            VStack {
                VStack(alignment: .center) {
                    statusIndicator
                        .opacity(topBarTitleOpacity())
                }
            }
            HStack {
                Spacer()
                
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(UI.Icons.cross_white)
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 40)
        .foregroundColor(.white)
        .padding(.top, topEdge)
    }
}

extension StatisticsView {
    
    // MARK: - Private Functions
    
    // Values for Bouncing Header
    
    private func getOpacity() -> CGFloat {
        let progess = -offset / 80
        let opacity = 1 - progess
        return offset < 0 ? opacity : 1
    }
    
    private func getHeaderHeight() -> CGFloat{
        let topHeight = maxHeight + offset
        return topHeight > (40 + topEdge) ? topHeight : (40 + topEdge)
    }
    
    private func getCornerRadius() -> CGFloat {
        let progess = -offset / (maxHeight - (40 + topEdge))
        let value = 1 - progess
        let radius = value * 32
        return offset < 0 ? radius : 32
    }
    
    private func topBarTitleOpacity() -> CGFloat {
        let progress = -(offset + 80) / (maxHeight - (80 + topEdge))
        return progress
    }
    
    // View Objects With Parameters
    
    private func sectionHeaderItem(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title.localized())
                    .statsTitleStyle()
                Spacer()
            }
            HStack {
                Text(subtitle.localized())
                    .statsSubTitleStyle()
                Spacer()
            }
        }
    }
    
    private func wordItem(key: String, value: Int) -> some View {
        HStack {
            Text(("\(key)").localized().capitalized)
                .wordTagStyle(color: value != 0 ? Color.theme.c1 : Color.theme.c7)
                .lineLimit(1)
            if value != 0 {
                Text("\(value)")
                    .wordTagStyle(color: Color.theme.c2)
                    .lineLimit(1)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 7)
                    .background(Color.theme.cW)
                    .overlay(Capsule().stroke(.clear, lineWidth: 1))
                    .cornerRadius(14)
            }
        }
        .padding(10)
        .background(Color.theme.c8)
        .frame(height: 40)
        .cornerRadius(14)
        .overlay(Capsule().stroke(.clear, lineWidth: 1))
    }
    
    private func emojiItem(key: String, value: Int) -> some View {
        VStack(spacing: 16) {
            if key == UI.Icons.emoji {
                Image(key)
            } else {
                Text("\(key)")
                    .font(.headline(25.92))
                    .lineLimit(1)
            }
            Text(value.stringFormat)
                .font(.title(17))
                .foregroundColor(key == UI.Icons.emoji ? Color.theme.c4 : Color.theme.c11)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 14.5)
        .frame(minWidth: 64)
        .background(key == UI.Icons.emoji ? Color.theme.c8 : Color.theme.c13)
        .cornerRadius(100)
        .overlay(Capsule().stroke(.clear, lineWidth: 1))

    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
