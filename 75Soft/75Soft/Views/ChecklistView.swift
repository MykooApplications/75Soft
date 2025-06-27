//
//  ChecklistView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ChecklistView: View {
    @ObservedObject var viewModel: ChallengeViewModel

    var body: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.tasks.sorted(by: { $0.key < $1.key }), id: \.key) { title, done in
                HStack {
                    Button(action: {
                        viewModel.toggle(title)
                    }) {
                        ZStack {
                            Circle()
                                .strokeBorder(done ? Color.accentColor : Color.gray, lineWidth: 2)
                                .frame(width: 28, height: 28)
                            if done {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(done) // tasks cannot be unchecked

                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.leading, 8)

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 40)
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
