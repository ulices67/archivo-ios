import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        Group {
            if session.isRestoring {
                ProgressView("Abriendo Archivo…")
            } else if session.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .tint(ArchivoTheme.accent)
        .foregroundStyle(ArchivoTheme.ink)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ArchivoTheme.background.ignoresSafeArea())
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            MemoriesView()
                .tabItem { Label("Recuerdos", systemImage: "archivebox") }
            ExploreView()
                .tabItem { Label("Explorar", systemImage: "safari") }
            CreateView()
                .tabItem { Label("Crear", systemImage: "plus") }
            LibraryView()
                .tabItem { Label("Biblioteca", systemImage: "books.vertical") }
            ProfileView()
                .tabItem { Label("Perfil", systemImage: "person") }
        }
        .toolbarBackground(ArchivoTheme.surface, for: .tabBar)
    }
}

