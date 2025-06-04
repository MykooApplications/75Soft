//
//  Soft75widgetLiveActivity.swift
//  Soft75widget
//
//  Created by Roshan Mykoo on 6/4/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Soft75widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Soft75widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Soft75widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Soft75widgetAttributes {
    fileprivate static var preview: Soft75widgetAttributes {
        Soft75widgetAttributes(name: "World")
    }
}

extension Soft75widgetAttributes.ContentState {
    fileprivate static var smiley: Soft75widgetAttributes.ContentState {
        Soft75widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Soft75widgetAttributes.ContentState {
         Soft75widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Soft75widgetAttributes.preview) {
   Soft75widgetLiveActivity()
} contentStates: {
    Soft75widgetAttributes.ContentState.smiley
    Soft75widgetAttributes.ContentState.starEyes
}
