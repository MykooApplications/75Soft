# 75Soft

75Soft is a 75-day discipline challenge app built with SwiftUI. It helps users build and track four daily healthy habits: hydration, reading, clean eating, and exercise. The app features an interactive checklist, streak tracking, rich history insights, configurable notifications, and Home Screen widgets.

---

## Features

- **Daily Checklist**  
  Mark off the following tasks each day: Drink 3 liters of water, read 10 pages of a book, follow a clean diet, complete a 45-minute workout.

- **Streak Tracking**  
  A streak counter that advances only when all tasks are completed in a single day. Users can choose to forgive a missed day or missed task.

- **Home Screen Widgets**  
  - Small progress widget shows current day count  
  - Small checklist widget shows today’s tasks  
  - Medium combined widget shows both progress and tasks

- **History & Insights**  
  - Interactive monthly calendar view of completed and missed days  
  - Line chart showing streak progression  
  - Completion rates for each task  
  - Achievement badges for 7-day, 30-day, and 75-day milestones

- **Onboarding Flow**  
  A multi-screen SwiftUI walkthrough that explains app purpose, tasks, marking logic, streak rules, and reset options.

- **Settings & Notifications**  
  - Toggle daily reminders and set reminder time  
  - Schedule milestone notifications when streak thresholds are reached  
  - Manual reset options for challenge and data  
  - Developer options for testing and debugging

---

## Technical Overview

- **User Interface**: SwiftUI, MVVM architecture  
- **Persistence**: SwiftData models (`@Model`, `@Query`)  
- **Widgets**: WidgetKit with App Group file sharing  
- **Charts**: Apple Charts framework  
- **Notifications**: `UNUserNotificationCenter` for local scheduling  
- **Onboarding**: `TabView` with `PageTabViewStyle` and custom animations

---

## Screenshots
<!-- ![Main Screen](docs/screenshots/main.png)
![History Calendar](docs/screenshots/history.png) -->
<img src="docs/screenshots/main.png" width=50%>
<img src="docs/screenshots/main.png" width=50%>

Installation
	1.	Clone the repository:

git clone https://github.com/your-username/75Soft.git
cd 75Soft


	2.	Open in Xcode 15 or later:

open 75Soft.xcodeproj


	3.	Select the App or Widget target and run on iOS 16 or later.

Usage
	1.	On first launch, complete or skip the onboarding screens.
	2.	Tap Start Today to insert today’s entry.
	3.	Tap each circle to mark a task complete. Completing all tasks advances the streak.
	4.	Add “75Soft” widgets to your Home Screen to view progress at a glance.
	5.	Access History via the sidebar menu for calendar and chart insights.
	6.	Configure Settings for notifications, reset options, and developer tools.

Architecture Diagram

ContentView (SwiftUI)
      │
      ▼
ChallengeViewModel (ObservableObject)
      │
DailyEntry & ChallengeState (SwiftData Models)
      │
WidgetKit ↔ JSON file via App Group

	•	Views bind to ViewModels which manage state and persistence.
	•	Widgets read shared JSON snapshot and update automatically.

Contributing
	1.	Fork the repository.
	2.	Create a feature branch:

git checkout -b my-feature


	3.	Commit your changes:

git commit -m "Add feature"


	4.	Push to your branch:

git push origin my-feature


	5.	Open a Pull Request.

Please follow the existing code style and include tests where appropriate.

License

This project is licensed under the MIT License. See the LICENSE file for details.

Contact

Roshan Mykoo
Email: your.email@example.com
GitHub: github.com/your-username/75Soft

