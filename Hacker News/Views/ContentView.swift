//
//  ContentView.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/21.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    /* View Properties
        
        storySource         - The selected story source to manage articles.
        topScore            - Flag to sort articles order by its score number.
        readAll             - Flag to set all stories read state to true.
        selectedStory       - The selected story to open a view and load it's url contents.
        showWebView         - Flag to load the story in a sheet view
        storyController     = The StoryController instance to manage stories.
     
     */
    @State private var storySource:StorySource = .newStories
    @State private var topScore = false
    @State private var readAll = false
    @State private var selectedStory: StoryModel?
    @State private var showWebView: Bool = false
    @StateObject private var storyController = StoryController()

    // Environment key that is automatically updated as your app moves
    // between the foreground, background, and inactive states.
    // Captured in the List view using onChange modifier.
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        
        // Display story cell wrapped in a button.
        // When tapped it triggers a Sheet View and load the url content.
        List {
            ForEach(storyController.stories) { story in
                Button {
                    selectedStory = story
                    showWebView.toggle()
                } label: {
                    StoryCellView(story: .constant(story))
                        .padding([.top, .bottom], 5)
                }
            }
        }
        .listStyle(GroupedListStyle())
        // Show alert if request error occurs on a published property `fetchError`
        .alert(Text("Could not update news"), isPresented: .constant((storyController.fetchError != nil) ? true:false)) {
            Text(storyController.fetchError?.errorDescription ?? "Unknown reason")
        }
        // Present a Sheet View and load the story url
        .sheet(isPresented: $showWebView, onDismiss: {
            withAnimation {
                storyController.readStory(story: selectedStory!)
            }
            selectedStory = nil
        }, content: {
            StoryWebView(story: $selectedStory)
        })
        // Capture API errors
        .onChange(of: storyController.fetchError) { newValue in
            if newValue == .invalidServerResponse && storyController.stories.count == 0 {
                // Load stories from local storage if no stories is loaded.
                storyController.loadLocalStories(from: storySource)
            }
        }
        // Capture Navigation Bar Item story source changes
        .onChange(of: storySource, perform: { newValue in
            withAnimation {
                storyController.stories.removeAll()
            }
            // We have to reset the topScore before retrieve new stories.
            topScore = false
            storyController.retrieveNewStories(from: storySource)
        })
        // Capture Navigation Bar Item score option
        .onChange(of: topScore, perform: { newValue in
            storyController.sortByScore(newValue)
        })
        // Capture Navigation Bar Item Read All button press
        .onChange(of: readAll, perform: { _ in
            withAnimation {
                storyController.readAllStories(from: storySource)
            }
        })
        // Retrieve stories when app change states, ie: Returning from backgound
        .onChange(of: scenePhase, perform: { newValue in
            if newValue == .active {
                storyController.retrieveNewStories(from: storySource)
                topScore = false
            }
        })
        // Retrieve stories when refreshing the view
        .refreshable {
            storyController.retrieveNewStories(from: storySource)
            topScore = false
        }
        .onAppear {
            storySource = storyController.localStorage.loadSettings().lastStorySource
        }
        // TopBar buttons and Story Source menu.
        // Passing Binding properties to keep track of actions to update the view.
        .navigationBarItems(leading: TopBarOptionsView(topScore: $topScore.animation(),
                                                       readAll: $readAll.animation(),
                                                       unreadStories: $storyController.unreadStories.animation()),
                            trailing: TopBarStorySourceView(storySource: $storySource.animation()))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
                .navigationTitle("Hacker News")
        }
        .navigationViewStyle(.stack)
    }
}
