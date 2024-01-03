//
//  StoryCellView.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/24.
//

import SwiftUI

/// A View to display a Story.
///
/// StoryModel object is used to get story details for the view
struct StoryCellView: View {
    
    /// The Story to be displayed in this view
    @Binding var story: StoryModel
    @Binding var source: StorySource

    // Custom Date/Time formatter to return a relative
    // time from current date, ie: "1 day ago"
    private let timePass: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            Text(story.title)
                .font(.headline)
                .fontWeight(.medium)
            
            HStack {
                if let url = URL(string: story.url)?.host {
                    Text("\(url)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                if source != .bookmark && story.bookmark == true {
                    Image(systemName: "bookmark")
                }
            }

            HStack {
                Text("\(timePass.localizedString(for: Date(timeIntervalSince1970: story.time), relativeTo: Date()))")
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.top, 15)
                Spacer()
                Text("\(Image(systemName: "bolt"))\(story.score)")
                    .font(.caption)
            }
            .opacity(0.5)
        }
        .foregroundColor(source == .bookmark ? .primary : story.read ?? false ? .gray : .primary)
    }
}

struct StoryCellView_Previews: PreviewProvider {
    static var previews: some View {
        StoryCellView(story: .constant(StoryModel(id: 0, title: "Test Title", by: "ClawsOnPaws", time: 1632301218, score: 100, url: "https://arstechnica.com/science/2021/09/braille-display-demo-refreshes-with-miniature-fireballs/")), source: .constant(.newStories))
            .previewLayout(.sizeThatFits)
    }
}
