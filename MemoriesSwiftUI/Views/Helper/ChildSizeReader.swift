//
//  ChildSizeReader.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 17.05.2023.
//

import SwiftUI

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    
    var body: some View {
        ZStack {
            content().background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: proxy.size
                    )
                }
            )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}
