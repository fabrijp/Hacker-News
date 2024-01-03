//
//  TopBarRanked.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/22.
//

import SwiftUI

/// A View for Navigation Bar with a Picker menu
///
struct TopBarStorySourceView: View {
    
    /// Trigger the story source selection
    @Binding var storySource: StorySource
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Source", selection: $storySource) {
                ForEach(StorySource.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.menu)
        }
        .accentColor(.orange)
    }
    
}

struct TopBarRanked_Previews: PreviewProvider {
    static var previews: some View {
        TopBarStorySourceView(storySource: .constant(.topStories))
            .previewLayout(.sizeThatFits)
    }
}
