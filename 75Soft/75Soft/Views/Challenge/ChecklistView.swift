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
    // adjust until your longest title fits in one line
    let labelWidth: CGFloat = 240

    var body: some View {
        VStack(spacing: 24) {
            ForEach(viewModel.tasks.sorted(by: { $0.key < $1.key }), id: \.key) { title, done in
                HStack(spacing: 16) {
                    // your circle button
                    Button {
                        viewModel.toggle(title)
                    } label: {
                        ZStack {
                            Circle()
                                .strokeBorder(done ? Color.accentColor : Color.gray,
                                              lineWidth: 3)
                                .frame(width: 32, height: 32)
                            if done {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(done)

                    // fixed-width label
                    Text(title)
                        .font(.title3)
                        .frame(width: labelWidth, alignment: .leading)

                    Spacer()
                }
                .padding(.horizontal, 16)
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
