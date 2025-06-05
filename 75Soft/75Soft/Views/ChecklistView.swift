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
    @Bindable var viewModel: ChallengeViewModel

    var body: some View {
        VStack {
            Spacer() // ⬅️ Pushes checklist down

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
                        .disabled(done)

                        Text(title)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.leading, 8)

                        Spacer()
                    }
                }
            }
            .frame(maxWidth: 300)
            .padding(.bottom, 40)
        }
        .frame(maxHeight: .infinity, alignment: .bottom) // ✅ Anchor to bottom
    }
}
