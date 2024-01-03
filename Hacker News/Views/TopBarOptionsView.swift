//
//  topBarView.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/22.
//

import SwiftUI

/// A View to display actions in Navigation Bar.
///
/// The properties are used to inform the user and trigger actions
struct TopBarOptionsView: View {
    
    /* Properties
     
        topScore        - To trigger action to sort articles order.
        readAll         - To trigger action to change all stories read state.
        unreadStories   - To display the unread stories number
     
     */
    @Binding var topScore: Bool
    @Binding var readAll: Bool
    @Binding var unreadStories: Int
    @Binding var storySource: StorySource
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                topScore.toggle()
            }, label: {
                Image(systemName: topScore ? "bolt.fill":"bolt")
            })
            Button {
                readAll.toggle()
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: storySource == .bookmark ? "eye.fill":"eye")
                    Text("\(unreadStories)")
                        .font(.caption)
                }
                .frame(width: 55)
            }
            .disabled(storySource == .bookmark)
            .opacity(unreadStories > 0 ? 1:0 )
        
        }
        .foregroundColor(.orange)
        .padding(5)
    }
}

struct TopBarScore_Previews: PreviewProvider {
    static var previews: some View {
        TopBarOptionsView(topScore: .constant(false), readAll: .constant(false), unreadStories: .constant(10), storySource: .constant(.topStories))
            .previewLayout(.sizeThatFits)
    }
}
