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
    
    var body: some View {
        HStack() {
            Button(action: {
                topScore.toggle()
            }, label: {
                Image(systemName: topScore ? "bolt.fill":"bolt")
            })
            Button {
                readAll.toggle()
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "eye")
                    Text("\(unreadStories)")
                        .font(.caption)
                }
                .frame(width: 65)
            }
            .opacity(unreadStories > 0 ? 1:0 )
        }
        .foregroundColor(.gray)
        .padding(5)
    }
}

struct TopBarScore_Previews: PreviewProvider {
    static var previews: some View {
        TopBarOptionsView(topScore: .constant(false), readAll: .constant(false), unreadStories: .constant(10))
            .previewLayout(.sizeThatFits)
    }
}
