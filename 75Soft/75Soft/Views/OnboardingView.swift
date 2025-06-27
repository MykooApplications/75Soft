// OnboardingFlow.swift
import SwiftUI

/// ViewModel for onboarding flow
class OnboardingViewModel: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Published var currentPage: Int = 0
    let totalPages = 6
}

/// Main Onboarding View
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @StateObject private var viewModel = OnboardingViewModel()
    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            IntroPage()
                .tag(0)
            TasksPage()
                .tag(1)
            MarkCompletePage()
                .tag(2)
            StreakPage()
                .tag(3)
            ResetPage()
                .tag(4)
            MotivationalPage() {
                viewModel.hasCompletedOnboarding = true
            }
            .tag(5)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

// MARK: - Individual Pages

struct IntroPage: View {
    @State private var animate = false
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bolt.heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
                .scaleEffect(animate ? 1 : 0.6)
                .opacity(animate ? 1 : 0)
            Text("Welcome to 75Soft")
                .font(.largeTitle).bold()
                .opacity(animate ? 1 : 0)
            Text("Your 75-day discipline challenge for hydration, reading, diet, and exercise.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}

struct TasksPage: View {
    @State private var animate = false
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
            ForEach(tasks, id: \.1) { icon, title in
                HStack(spacing: 12) {
                    Text(icon)
                        .font(.largeTitle)
                    Text(title)
                        .font(.headline)
                }
                .opacity(animate ? 1 : 0)
                .offset(x: animate ? 0 : 50)
            }
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation(.easeOut.delay(0.3)) { animate = true }
        }
    }
}

struct MarkCompletePage: View {
    @State private var animate = false
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
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
        .onAppear { withAnimation(.easeOut(duration: 0.6)) { animate = true } }
    }
}

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
        .onAppear { withAnimation(.easeIn(duration: 0.6)) { animate = true } }
    }
}

struct MotivationalPage: View {
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
        .onAppear { withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { animate = true } }
    }
}

// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}
