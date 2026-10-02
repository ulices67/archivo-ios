import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        ZStack {
            // Main content
            Group {
                if session.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .tint(ArchivoTheme.accent)
            .foregroundStyle(ArchivoTheme.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ArchivoTheme.background.ignoresSafeArea())

            // Official Splash Screen Overlay
            if session.isRestoring {
                SplashScreenView(stage: session.startupStage)
                    .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                    .zIndex(100)
            }
        }
    }
}

// MARK: - Official Geometric Splash Screen

struct SplashScreenView: View {
    let stage: StartupStage

    var body: some View {
        ZStack {
            ArchivoTheme.background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Official Geometric Wordmark
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 210)
                    .foregroundStyle(ArchivoTheme.ink)

                // Minimalist 3px Progress Bar
                GeometryReader { _ in
                    ZStack(alignment: .leading) {
                        // Inactive Track
                        Capsule()
                            .fill(Color.white.opacity(0.14))
                            .frame(height: 3)

                        // Active Progress
                        Capsule()
                            .fill(ArchivoTheme.ink)
                            .frame(width: 190 * stage.progress, height: 3)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stage.progress)
                    }
                }
                .frame(width: 190, height: 3)
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MemoriesView()
                .tabItem {
                    Label("Recuerdos", systemImage: "archivebox")
                }
                .tag(0)

            ExploreView()
                .tabItem {
                    Label("Explorar", systemImage: "safari")
                }
                .tag(1)

            CreateView()
                .tabItem {
                    Label("Crear", systemImage: "plus")
                }
                .tag(2)

            LibraryView()
                .tabItem {
                    Label("Biblioteca", systemImage: "books.vertical")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person")
                }
                .tag(4)
        }
        .toolbarBackground(ArchivoTheme.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - Previews

#Preview("Canvas 393 × 852 pt (iPhone 16 Pro)") {
    RootView()
        .environment(SessionStore())
        .preferredColorScheme(.dark)
}

#Preview("Splash Screen") {
    SplashScreenView(stage: .profile)
        .preferredColorScheme(.dark)
}
