# Epic 1: Authentication & User Onboarding

## Issue 1: Implement Google Sign-In
**Description**: Users need to be able to securely create an account and log in using Google.
**Tasks**:
- [x] Set up Firebase Auth UI screens in `features/auth`
- [x] Connect Google Sign-In integration with Firebase
- [x] Handle auth state changes using Provider
- [x] Route user to Main Dashboard or Onboarding based on new user status
**Labels**: `enhancement`, `auth`

## Issue 2: User Onboarding & Profile Setup
**Description**: After first login, new users should fill out basic info to help calculate calories and distance.
**Tasks**:
- [ ] Create onboarding screens (Height, Weight, Daily Step Goal)
- [ ] Save user profile data to Firestore
- [ ] Request physical activity permissions via `permission_handler`
**Labels**: `enhancement`, `ui`, `database`

---

# Epic 2: Core Step Tracking

## Issue 3: Step Detection Service
**Description**: The app needs to track steps using the pedometer package and sync them.
**Tasks**:
- [ ] Initialize `pedometer` streams (StepCount & PedestrianStatus)
- [ ] Handle pedometer errors or missing device sensors gracefully
- [ ] Store daily step counts locally (SharedPrefs/Hive) and sync to Firestore
**Labels**: `core-feature`, `pedometer`

## Issue 4: Main Dashboard UI
**Description**: Users need a visual representation of their daily progress.
**Tasks**:
- [ ] Build circular progress indicator for daily step goal
- [ ] Display current step count, estimated calories burned, and distance
- [ ] Implement smooth micro-animations when step count updates
**Labels**: `ui`, `design`

---

# Epic 3: History & Gamification

## Issue 5: Activity History View
**Description**: Users should be able to look back at their past step history and performance.
**Tasks**:
- [ ] Query Firestore for past 7/30 days of step data
- [ ] Build a sleek history list view or bar chart UI to visualize past progress
**Labels**: `enhancement`, `ui`

## Issue 6: Badges & Achievements
**Description**: Reward users when they hit milestones (e.g., 10k steps, 3-day streak) to increase retention.
**Tasks**:
- [ ] Define milestone logic in a Provider
- [ ] Create a Badge UI in the User Profile tab
- [ ] Trigger celebration animations (e.g. confetti) upon hitting a daily goal
**Labels**: `feature`, `gamification`

---

# Epic 4: Settings & Polish

## Issue 7: App Settings & Theme Toggling
**Description**: Users should be able to customize their app settings.
**Tasks**:
- [ ] Add Dark/Light mode toggle
- [ ] Allow users to change their daily step goal, weight, or height
- [ ] Allow users to log out or delete their account (Firebase Auth)
**Labels**: `settings`, `ui`

## Issue 8: Setup App Icons & Splash Screen
**Description**: Final visual polish using the newly added Movexa logo.
**Tasks**:
- [ ] Generate Android & iOS app icons from `assets/Movexa.png`
- [ ] Create a sleek, animated splash screen that matches the brand colors
**Labels**: `polish`, `configuration`
