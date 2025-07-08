//
//  OnboardingView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//
import SwiftUI

/// Keeps track of where we are in the onboarding and whether we've finished it
class OnboardingViewModel: ObservableObject {
    /// Remember in storage if the user has completed onboarding before
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    /// Which page the user is on right now (0–5)
    @Published var currentPage: Int = 0
    /// Total number of pages in our flow
    let totalPages = 6
}

/// The full-screen onboarding flow
struct OnboardingView: View {
    /// Binding so we can tell the app when onboarding is done
    @Binding var hasCompletedOnboarding: Bool
    /// Our view model to drive the pages
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // A paging TabView for each onboarding screen
            TabView(selection: $viewModel.currentPage) {
                IntroPage()           .tag(0)  // What is 75Soft?
                TasksPage()           .tag(1)  // What tasks you'll do
                MarkCompletePage()    .tag(2)  // How to tap to complete
                StreakPage()          .tag(3)  // How streaks work
                ResetPage()           .tag(4)  // How to reset
                MotivationalPage {
                    // When they tap "Start", mark onboarding done
                    hasCompletedOnboarding = true
                }
                .tag(5)
            }
            .tabViewStyle(PageTabViewStyle())                      // Swipeable pages
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // Dots at bottom
            
            // Skip button in top right:
            Button("Skip") {
                // Jump straight to the last page with animation
                withAnimation {
                    viewModel.currentPage = viewModel.totalPages - 1
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 20)
        }
        // If viewModel itself marks onboarding done (rare), update binding
        .onChange(of: viewModel.hasCompletedOnboarding) { finished in
            if finished {
                hasCompletedOnboarding = true
            }
        }
    }
}

// MARK: - Pages

/// Page 1: Intro
struct IntroPage: View {
    @State private var animate = false
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            // Big heart icon that grows
            Image(systemName: "bolt.heart.fill")
                .resizable().scaledToFit().frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
                .scaleEffect(animate ? 1 : 0.6)
                .opacity(animate ? 1 : 0)
            // Title text
            Text("Welcome to 75Soft")
                .font(.largeTitle).bold()
                .opacity(animate ? 1 : 0)
            // Description
            Text("Your 75-day discipline challenge for hydration, reading, diet, and exercise.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
            Spacer()
        }
        .onAppear {
            // Animate in with a spring effect
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}

/// Page 2: Tasks list
struct TasksPage: View {
    @State private var animate = false
    // Our four tasks
    let tasks = [
        ("💧", "Drink 3L of Water"),
        ("📖", "Read 10 Pages"),
        ("🥗", "No Cheat Meals"),
        ("🏃‍♂️", "45-Minute Workout")
    ]
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Daily Tasks")
                .font(.title).bold()
                .opacity(animate ? 1 : 0)
            // Show each task with icon and text
            ForEach(tasks, id: \.1) { icon, title in
                HStack(spacing: 12) {
                    Text(icon).font(.largeTitle)
                    Text(title).font(.headline)
                }
                .opacity(animate ? 1 : 0)
                .offset(x: animate ? 0 : 50)  // Slide in from right
            }
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation(.easeOut.delay(0.3)) { animate = true }
        }
    }
}

/// Page 3: How to mark complete
struct MarkCompletePage: View {
    @State private var animate = false
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            // Big checkmark circle
            Image(systemName: "checkmark.circle.fill")
                .resizable().scaledToFit().frame(width: 100, height: 100)
                .foregroundColor(.green)
                .scaleEffect(animate ? 1 : 0.5)
                .opacity(animate ? 1 : 0)
            Text("Tap to Complete")
                .font(.title2).bold()
                .opacity(animate ? 1 : 0)
            Text("Simply tap the circle next to each task to mark it complete for the day.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
            Spacer()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { animate = true }
        }
    }
}

/// Page 4: Streak explanation
struct StreakPage: View {
    @State private var animate = false
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "flame.fill")
                .resizable().scaledToFit().frame(width: 80, height: 80)
                .foregroundColor(.red)
                .opacity(animate ? 1 : 0)
            Text("Your Streak")
                .font(.title2).bold()
                .opacity(animate ? 1 : 0)
            Text("Complete all tasks in a day to increase your streak. Miss a day and it resets!")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { animate = true }
        }
    }
}

/// Page 5: Manual reset info
struct ResetPage: View {
    @State private var animate = false
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .resizable().scaledToFit().frame(width: 80, height: 80)
                .foregroundColor(.orange)
                .opacity(animate ? 1 : 0)
            Text("Manual Reset")
                .font(.title2).bold()
                .opacity(animate ? 1 : 0)
            Text("You can also reset your entire challenge at any time from the Settings menu.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
            Spacer()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { animate = true }
        }
    }
}

/// Page 6: Final motivational screen with start button
struct MotivationalPage: View {
    /// Called when the user taps "Start My Challenge"
    let onStart: () -> Void
    @State private var animate = false
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Let's Get Started!")
                .font(.largeTitle).bold()
                .scaleEffect(animate ? 1 : 0.7)
                .opacity(animate ? 1 : 0)
            Text("Your journey to a stronger, healthier you begins today.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
            Button(action: onStart) {
                Text("Start My Challenge")
                    .font(.headline).bold()
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .scaleEffect(animate ? 1 : 0.8)
            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}

// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}
