//
//  StatsView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 05.04.2023.
//

import SwiftUI
import Foundation
import Charts

enum Tab: String {
    case week = "Нед", month = "Мес", year = "Год"
}

struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var chapterViewModel: ChapterVM
    @ObservedObject var statsViewModel: StatsVM
    
    @State private var currentTab: Tab = .week
    @State private var totalHeight: CGFloat = CGFloat.zero

    @State var offset : CGFloat = 0
    
    let maxHeight = UIScreen.main.bounds.height / 4
    
    var topEdge: CGFloat
    
    init(chapterModel: ChapterVM, topEdge: CGFloat) {
        self.chapterViewModel = chapterModel
        self.statsViewModel = StatsVM(chapterModel: chapterModel)
        self.topEdge = topEdge
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                GeometryReader{ proxy in
                    StatusView(topEge: topEdge, offset: $offset, maxHeight: maxHeight)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: getHeaderheight(), alignment: .bottom)
                        .background(
                            Color.c4,
                            in: RoundedCorner(radius: getCornerRadius(), corners: [.bottomRight, .bottomLeft])
                        )
                        .overlay (
                            simplifiedHeader
                            , alignment: .top
                        )
                }
                .frame(height: maxHeight)
                .offset(y: -offset)
                .zIndex(1)
                
                VStack(spacing: 32) {
                    ChartView(title: "График настроя",
                              subtitle: "Показывает общее настроение ваших воспоминаний. Это помогает остледить уровень эмоций.")

                    TopEmojiView(title: "Топ Emoji",
                                 sequence: statsViewModel.popularEmojies)

                    TopWordsView(title: "Топ 10 слов",
                                 subtitle: "Это может помочь Вам лучше отслеживать ваши чувства и переживания",
                                 sequence: statsViewModel.popularWords)
                }
                .background(Color.cW.edgesIgnoringSafeArea(.all))
                .zIndex(0)
            }
            .modifier(OffsetModifier(offset: $offset))
        }
        .coordinateSpace(name: "SCROLL")
    }

    func StatusView(topEge: CGFloat, offset: Binding<CGFloat>, maxHeight: CGFloat) -> some View {
        VStack(spacing: 8) {
            HStack {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(Color.c8)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(chapterViewModel.getStatusImage())
                            .resizable()
                            .frame(width: 64, height: 84)
                    )
            }
            statusIndicator
        }
        .padding(.bottom, 24)
        .opacity(getOpacity())
    }
    
    func ChartView(title: String, subtitle: String) -> some View {
        VStack {
            sectionHeaderItem(title: title, subtitle: subtitle)

            ZStack {
                chartBody
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.c11.opacity(0.2))
            }
            .overlay(
                DottedLine()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [2]))
                    .frame(height: 2)
                    .foregroundColor(Color.cW)
            )
            .frame(height: 178)
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    func TopWordsView(title: String, subtitle: String, sequence: Array<Dictionary<String, Int>.Element>.SubSequence) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        VStack(spacing: 8) {
            sectionHeaderItem(title: title, subtitle: subtitle)
            
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
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
                    }.background(viewHeightReader($totalHeight))
                }
            }
            .frame(height: totalHeight).padding(.leading, 12).padding(.trailing, 8)
        }
    }
    
    func TopEmojiView(title: String, sequence: Array<Dictionary<String, Int>.Element>.SubSequence) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .statsTitleStyle()
                Spacer()
            }
    
            HStack(alignment: .center) {
                ForEach(sequence, id: \.key) { key, value in
                    emojiItem(key: key, value: value)
                }
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
                    Image("cross-white")
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 40)
        .foregroundColor(.white)
        .padding(.top, topEdge)
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 2) {
            ForEach(1...7, id: \.self) { i in
                Circle()
                    .fill(chapterViewModel.statusValue < i ? Color.c8 : Color.c6)
                    .frame(width: 10)
            }
        }
    }
    
    private var chartBody: some View {
        let pathProvider = LineChartProvider(data: statsViewModel.moodDynamics, lineRadius: 0.5)
        return GeometryReader { geometry in
            ZStack {
                // Background
                pathProvider.closedPath(for: geometry)
                .fill(Color.c11)
                            
                // Chart
                pathProvider.path(for: geometry)
                .stroke(Color.cW, style: StrokeStyle(lineWidth: 2.5))
            }
        }
    }
    
    func getOpacity() -> CGFloat {
        let progess = -offset / 80
        let opacity = 1 - progess
        return offset < 0 ? opacity : 1
    }
    
    func getHeaderheight() -> CGFloat{
        let topHeight = maxHeight + offset
        return topHeight > (40 + topEdge) ? topHeight : (40 + topEdge)
    }
    
    func getCornerRadius() -> CGFloat {
        let progess = -offset / (maxHeight - (40 + topEdge))
        let value = 1 - progess
        let radius = value * 32
        return offset < 0 ? radius : 32
    }
    
    func topBarTitleOpacity() -> CGFloat {
        let progress = -(offset + 80) / (maxHeight - (80 + topEdge))
        return progress
    }
}


extension StatsView {
    
    // MARK: - Private Functions
    
    private func sectionHeaderItem(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .statsTitleStyle()
                Spacer()
            }
            HStack {
                Text(subtitle)
                    .statsSubTitleStyle()
                    .padding(.leading, 16)
                Spacer()
            }
        }.padding(.bottom, 24)
    }
    
    private func wordItem(key: String, value: Int) -> some View {
        HStack {
            Text(("\(key)").capitalized)
                .wordTagStyle(color: .c1)
                .lineLimit(1)
            Text("\(value)")
                .wordTagStyle(color: .c2)
                .lineLimit(1)
                .padding(.vertical, 2)
                .padding(.horizontal, 7)
                .background(Color.cW)
                .overlay(Capsule().stroke(.clear, lineWidth: 1))
                .cornerRadius(14)
        }
        .padding(10)
        .background(Color.c8)
        .frame(height: 40)
        .cornerRadius(14)
        .overlay(Capsule().stroke(.clear, lineWidth: 1))
    }
    
    private func emojiItem(key: String, value: Int) -> some View {
        VStack(spacing: 16) {
            Text("\(key)")
                .font(.headline(25.92))
                .lineLimit(1)
            Text(value.stringFormat)
                .font(.title(17))
                .foregroundColor(.c11)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 14.5)
        .background(Color.c13)
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
    
    // MARK: - Private Functions
}




//@ViewBuilder
//func ChartView(title: String, subtitle: String) -> some View {
//    VStack {
//        sectionHeader(title: title, subtitle: subtitle)
//
//        VStack() {
//            Chart {
//                ForEach(statsViewModel.moodDynamics) {
//                    AreaMark(
//                        x: .value("Week Day", $0.weekday),
//                        y: .value("Step Count", $0.value),
//                        stacking: .unstacked
//                    )
//                    .interpolationMethod(.catmullRom)
//                    .foregroundStyle(Color.c11)
//
//                    LineMark(
//                        x: .value("Week Day", $0.weekday),
//                        y: .value("Step Count", $0.value)
//                    )
//                    .interpolationMethod(.catmullRom)
//                    .lineStyle(StrokeStyle(lineWidth: 2.5))
//                    .foregroundStyle(
//                        Color.cW
//                            .shadow(.drop(color: .cB.opacity(0.04), radius: 4))
//                            .shadow(.drop(color: .cB.opacity(0.08), radius: 16, y: 8))
//                    )
//                }
//            }
//            .chartPlotStyle { plotArea in
//                plotArea
//                    .cornerRadius(14)
//                    .overlay(
//                        DottedLine()
//                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [2]))
//                            .frame(height: 2)
//                            .foregroundColor(Color.cW)
//                    )
//            }
//            .chartLegend(position: .overlay, alignment: .center)
////                .chartYAxis(.hidden)
////                .chartXAxis(.hidden)
//            .chartYScale(domain: 0...10)
//            .frame(height: 178)
////                .zIndex(0)
//        }
//        .background {
//            RoundedRectangle(cornerRadius: 14)
//                .fill(Color.c11.opacity(0.2))
//        }
//        .padding(.horizontal, 16)
////            .frame(height: totalHeight).padding(.leading, 12).padding(.trailing, 8)
//    }
////        .onChange(of: currentTab) { newValue in
////        }
//
//
//
//}

//                ZStack {
//                    RoundedRectangle(cornerRadius: 5)
//                        .frame(width: UIScreen.main.bounds.size.width-18, height: 32)
//                        .foregroundColor(.c13)
//
//                    Picker("pikcer", selection: $currentTab) {
//                        Text(Tab.week.rawValue)
//                            .tag(Tab.week)
//                        Text(Tab.month.rawValue)
//                            .tag(Tab.month)
//                        Text("Год")
//                        //                            .tag(Tab.week)
//                    }
//                    //                    .background(Color.c13)
//                    //                    .colorMultiply(Color.c3)
//                    .pickerStyle(.segmented)
//                }

//private var maxYValue: CGFloat {
//    statsViewModel.moodDynamics.max { $0.value < $1.value }?.value ?? 0
//}
//
//private var maxXValue: CGFloat {
//    CGFloat(statsViewModel.moodDynamics.count - 1)
//}
//
//private var xStepsCount: Int {
//    Int(self.maxXValue / 1)
//}
//
//private var yStepsCount: Int {
//    Int(self.maxYValue / 1)
//}
//private var gridBody: some View {
//    GeometryReader { geometry in
//        Path { path in
//            let xStepWidth = geometry.size.width / CGFloat(self.xStepsCount)
//            let yStepWidth = geometry.size.height / CGFloat(self.yStepsCount)
//
//            // Y axis lines
//            (1...self.yStepsCount).forEach { index in
//                let y = CGFloat(index) * yStepWidth
//                path.move(to: .init(x: 0, y: y))
//                path.addLine(to: .init(x: geometry.size.width, y: y))
//            }
//
//            // X axis lines
//            (1...self.xStepsCount).forEach { index in
//                let x = CGFloat(index) * xStepWidth
//                path.move(to: .init(x: x, y: 0))
//                path.addLine(to: .init(x: x, y: geometry.size.height))
//            }
//        }
//        .stroke(Color.gray)
//    }
//}
