import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session
    @State private var isShowingSplash = true
    @State private var webViewLoading = true
    private let appURL = URL(string: "https://archivo.societext.workers.dev")!

    var body: some View {
        ZStack {
            // Edge-to-edge original Archivo application
            ArchivoWebView(url: appURL) { isLoading in
                if !isLoading && isShowingSplash {
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 600_000_000)
                        withAnimation(.easeOut(duration: 0.4)) {
                            isShowingSplash = false
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea())

            // Official Geometric Splash Screen Overlay
            if isShowingSplash {
                SplashScreenView(stage: session.startupStage)
                    .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                    .zIndex(100)
            }
        }
        .task {
            // Dismiss splash automatically as fallback after 2.5s
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if isShowingSplash {
                withAnimation(.easeOut(duration: 0.4)) {
                    isShowingSplash = false
                }
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

// MARK: - Fallback / Native Tab View

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
