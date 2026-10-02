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
            Tab("Recuerdos", systemImage: "archivebox") { MemoriesView() }
            Tab("Explorar", systemImage: "safari") { ExploreView() }
            Tab("Crear", systemImage: "plus") { CreateView() }
            Tab("Biblioteca", systemImage: "books.vertical") { LibraryView() }
            Tab("Perfil", systemImage: "person") { ProfileView() }
        }
        .toolbarBackground(ArchivoTheme.surface, for: .tabBar)
    }
}

