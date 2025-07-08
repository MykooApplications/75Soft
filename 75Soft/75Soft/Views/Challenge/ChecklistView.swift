//
//  ChecklistView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import SwiftData
import WidgetKit

// This view shows today’s checklist: each task with a tappable circle.
// When you tap the circle, it marks that task done (and you can’t un-tap it).
struct ChecklistView: View {
    // Our “coach” object that knows what tasks exist and which are done
    @ObservedObject var viewModel: ChallengeViewModel
    
    // We pick a fixed width so every task label lines up neatly
    let labelWidth: CGFloat = 240
    
    var body: some View {
        // Stack each task row vertically, with some space between them
        VStack(spacing: 24) {
            // Sort tasks alphabetically by their name, then loop through them
            ForEach(viewModel.tasks.sorted(by: { $0.key < $1.key }), id: \.key) { title, done in
                HStack(spacing: 16) {
                    // 1) The circle button that shows completed vs. not
                    Button {
                        // When tapped, tell our viewModel “toggle this task”
                        viewModel.toggle(title)
                    } label: {
                        ZStack {
                            // Outline circle: colored if done, gray if not
                            Circle()
                                .strokeBorder(
                                    done ? Color.accentColor : Color.gray,
                                    lineWidth: 3
                                )
                                .frame(width: 32, height: 32)
                            
                            // If the task is done, draw a filled circle inside
                            if done {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
                    .buttonStyle(.plain)  // Remove any extra button styling
                    .disabled(done)       // Disable re-tapping once it’s done
                    
                    // 2) The task label, fixed width so all lines up
                    Text(title)
                        .font(.title3)
                        .frame(width: labelWidth, alignment: .leading)
                    
                    Spacer() // Push everything to the left, leaving empty space on the right
                }
                .padding(.horizontal, 16) // Add a little margin on left & right
            }
        }
    }
}
//// Preview
//struct ChecklistView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Mock view model for preview
//        let mockEntry = DailyEntry(date: Date())
//        mockEntry.waterCompleted = true
//        let mockState = ChallengeState(startDate: Date())
//        let viewModel = ChallengeViewModel(entry: mockEntry, state: mockState, context: /* provide a ModelContext here */)
//
//        return ChecklistView(viewModel: viewModel)
//    }
//}
