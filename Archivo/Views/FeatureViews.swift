import PhotosUI
import SwiftUI

private struct SectionHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow.uppercased()).font(.caption2.weight(.bold)).tracking(2).foregroundStyle(ArchivoTheme.muted)
            Text(title.uppercased()).font(.system(size: 34, weight: .medium, design: .rounded))
            Text(subtitle).foregroundStyle(ArchivoTheme.muted)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MemoriesView: View {
    @State private var memories: [Memory] = []
    @State private var error: String?
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    SectionHeader(eyebrow: "El tiempo guardado", title: "Recuerdos", subtitle: "Fotos, videos y fragmentos que perduran.")
                    if memories.isEmpty { ContentUnavailableView("Sin recuerdos", systemImage: "archivebox", description: Text("Crea el primero desde el botón central.")) }
                    ForEach(memories) { memory in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(memory.title).font(.headline)
                            Text(memory.description ?? "Sin descripción").foregroundStyle(ArchivoTheme.muted)
                            Text((memory.visibility ?? "private").uppercased()).font(.caption2)
                        }.frame(maxWidth: .infinity, alignment: .leading).archivoCard()
                    }
                }.padding()
            }
            .navigationTitle("Archivo")
            .task { await load() }
        }
    }
    private func load() async {
        do { let response: BootstrapResponse = try await APIClient.shared.request("/api/bootstrap"); memories = response.memories ?? [] }
        catch let err { self.error = err.localizedDescription }
    }
}

struct ExploreView: View {
    @State private var posts: [SocialPost] = []
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    SectionHeader(eyebrow: "Descubrir sin ruido", title: "Explorar", subtitle: "Solo contenido compartido explícitamente.")
                    ForEach(posts) { post in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack { Image(systemName: "person.crop.circle"); Text(post.displayName ?? post.username ?? "Archivo") }
                            if let title = post.title { Text(title).font(.title3.weight(.semibold)) }
                            if let body = post.body { Text(body) }
                            HStack { Text((post.kind ?? "nota").uppercased()); Spacer(); Image(systemName: visibilityIcon(post.visibility)) }
                                .font(.caption).foregroundStyle(ArchivoTheme.muted)
                        }.frame(maxWidth: .infinity, alignment: .leading).archivoCard()
                    }
                }.padding()
            }.task { await load() }
        }
    }
    private func load() async {
        struct Response: Decodable { let posts: [SocialPost]? }
        if let response: Response = try? await APIClient.shared.request("/api/social") { posts = response.posts ?? [] }
    }
    private func visibilityIcon(_ value: String?) -> String { value == "public" ? "globe" : value == "followers" ? "person.2" : "lock" }
}

struct CreateView: View {
    @State private var selection: PhotosPickerItem?
    @State private var selectedData: Data?
    @State private var kind = "Foto"
    @State private var caption = ""
    var body: some View {
        let hasData = selectedData != nil
        NavigationStack {
            Form {
                Section("Crear algo nuevo") {
                    Picker("Tipo", selection: $kind) { ForEach(["Foto", "Video", "Poema", "Canción", "Nota"], id: \.self) { Text($0) } }
                    PhotosPicker(selection: $selection, matching: .any(of: [.images, .videos])) {
                        Label(hasData ? "Archivo preparado" : "Elegir foto o video", systemImage: "photo.on.rectangle")
                    }
                    TextField("Contexto", text: $caption, axis: .vertical)
                    Picker("Visibilidad", selection: .constant("private")) {
                        Text("Privado").tag("private"); Text("Seguidores").tag("followers"); Text("Público").tag("public")
                    }
                }
                Section { Button("Guardar en Archivo") {}.disabled(!hasData && caption.isEmpty) }
            }
            .navigationTitle("Crear")
            .onChange(of: selection) { _, item in Task { selectedData = try? await item?.loadTransferable(type: Data.self) } }
        }
    }
}

struct LibraryView: View {
    private let sections = [("Música", "music.note"), ("Películas", "film"), ("Series", "tv"), ("Poemas", "sparkles"), ("Cartas", "doc.text"), ("Listas", "list.bullet")]
    var body: some View {
        NavigationStack {
            List(sections, id: \.0) { item in NavigationLink { ContentUnavailableView(item.0, systemImage: item.1, description: Text("Aquí podrás añadir y organizar contenido.")) } label: { Label(item.0, systemImage: item.1) } }
                .navigationTitle("Biblioteca")
        }
    }
}

struct ProfileView: View {
    @Environment(SessionStore.self) private var session
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill").font(.system(size: 76))
                        Text(session.user?.displayName ?? session.user?.username ?? "Perfil").font(.title2)
                        Text("@\(session.user?.username ?? "")").foregroundStyle(ArchivoTheme.muted)
                    }.frame(maxWidth: .infinity).padding()
                }
                Section("Cuenta") {
                    NavigationLink("Editar perfil") { Text("Edición de perfil") }
                    NavigationLink("Privacidad y seguridad") { Text("Privacidad y seguridad") }
                    NavigationLink("Notificaciones") { NotificationsView() }
                }
                Section { Button("Cerrar sesión", role: .destructive) { Task { await session.logout() } } }
                Section { Text("Archivo 0.10.0-beta.1 (19)").font(.footnote).foregroundStyle(ArchivoTheme.muted) }
            }.navigationTitle("Perfil")
        }
    }
}

struct NotificationsView: View {
    @State private var notifications: [ArchivoNotification] = []
    var body: some View {
        List(notifications) { item in VStack(alignment: .leading) { Text(item.title); if let body = item.body { Text(body).font(.footnote).foregroundStyle(.secondary) } } }
            .navigationTitle("Notificaciones")
            .task {
                struct Response: Decodable { let notifications: [ArchivoNotification]? }
                if let response: Response = try? await APIClient.shared.request("/api/notifications") { notifications = response.notifications ?? [] }
            }
    }
}

