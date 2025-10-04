//
//  SQProgressBar.swift
//  SignQuestUI
//
//  Created by Ezra Arya Wijaya on 23/04/25.
//

import SwiftUI

public struct SQProgressBar: View {
    @Binding public var progress: Double
    public var width: CGFloat
    
    public init(progress: Binding<Double>, width: CGFloat = 300) {
        self._progress = progress
        self.width = width
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(SQColor.muted.color)
                .frame(height: 12)

            RoundedRectangle(cornerRadius: 8)
                .fill(SQColor.secondary.color)
                .frame(width: CGFloat(progress / 100) * width, height: 12)
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .frame(width: width)
    }
}
