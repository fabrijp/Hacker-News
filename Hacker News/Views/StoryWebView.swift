//
//  StoryView.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/24.
//

import SwiftUI

/// The View that displays a WebView loading the story URL.
struct StoryWebView: View {
    
    /* Properties
     
     story           - The story received
     doneLoading     - To trigger the ProgressView visibility
     tabBarWidthSize - Our custom top bar size
     
     */
    @Binding var story: StoryModel?
    @State var doneLoading: Bool = false
    @State var topBarWidthSize: CGFloat = UIScreen.main.bounds.width
    
    // Create an instance of StoryController
    var storyController = StoryController()
    
    // A closure to set the bookmark flag of the story
    var setBookmark: ((Bool) -> Void)
    
    // Access the Environment variable to dismiss the view
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                
                ZStack {
                    
                    // A top bar to display the story title, a progress bar activity,
                    // and a button to launch the story in the device's default browser
                    Color.red
                        .frame(width: geometry.size.width, height: 75)
                    
                    HStack {
                        
                        // Add a button to dismiss the view if we are in landscape mode
                        // because Sheet Views in landscape are fullscreen.
                        if geometry.size.width > UIScreen.main.bounds.height {
                            Button("Close", action: dismiss.callAsFunction)
                                .foregroundColor(.white)
                                .padding([.leading,.trailing])
                        }
                        
                        // Display the title of the story
                        Text(story!.title).padding(.leading)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // A button to set/unset bookmark
                        Button {
                            story?.bookmark = !(story?.bookmark ?? false)
                            if let favorite = story?.bookmark, let story = story {
                                if favorite {
                                    storyController.localStorage.saveStory(story: story, storySource: .bookmark, storyRead: false, overwrite: false)
                                } else {
                                    storyController.localStorage.removeStory(story: story, source: .bookmark)
                                }
                                setBookmark(favorite)
                            }
                            // update story favorite flag
                            if let source = story?.source, let story = story {
                                storyController.localStorage.saveStory(story: story, storySource: source, storyRead: true, overwrite: true)
                            }
                        } label: {
                            Image(systemName: story?.bookmark ?? false ? "bookmark.fill":"bookmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .opacity(0.5)
                                .foregroundColor(.white)
                                
                        }
                        .padding(.trailing)
                        
                        // A progress bar to show the loading status
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                            .opacity(doneLoading ? 0:1)
                        
                        // A button to launch the link associated with the article in the user's browser
                        Button {
                            if let strURL = story?.url, let url = URL(string: strURL)  {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing)
                        
                    }
                    
                }
                .frame(maxWidth:.infinity)
                
                // A custom WebView to load the story article
                WebView(finished: $doneLoading, urlString: story?.url)
                
            }
            
        }
        .ignoresSafeArea()
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryWebView(story: .constant( StoryModel(id: 0, title: "Test Title", by: "ClawsOnPaws", time: 1000, score: 1632301218, url: "https://arstechnica.com/science/2021/09/braille-display-demo-refreshes-with-miniature-fireballs/")) ) { _ in }
    }
}
