import PhotosUI
import SwiftUI

// MARK: - Responsive Section Header

private struct SectionHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(2)
                .foregroundStyle(ArchivoTheme.muted)

            Text(title.uppercased())
                .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                .foregroundStyle(ArchivoTheme.ink)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(ArchivoTheme.muted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 6)
    }
}

// MARK: - Memories View

struct MemoriesView: View {
    @State private var memories: [Memory] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    SectionHeader(
                        eyebrow: "El tiempo guardado",
                        title: "Recuerdos",
                        subtitle: "Fotos, videos y fragmentos que perduran."
                    )

                    if isLoading && memories.isEmpty {
                        ProgressView()
                            .padding(.vertical, 40)
                    } else if memories.isEmpty {
                        ContentUnavailableView(
                            "Sin recuerdos aún",
                            systemImage: "archivebox",
                            description: Text("Crea tu primer recuerdo desde la pestaña Crear.")
                        )
                        .padding(.vertical, 32)
                    } else {
                        ForEach(memories) { memory in
                            MemoryCardView(memory: memory)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .responsiveContainer()
            }
            .background(ArchivoTheme.background.ignoresSafeArea())
            .navigationTitle("Archivo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ARCHIVO")
                        .font(.caption.weight(.bold))
                        .tracking(3)
                        .foregroundStyle(ArchivoTheme.ink)
                }
            }
            .refreshable {
                await load()
            }
            .task {
                await load()
            }
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: BootstrapResponse = try await APIClient.shared.request("/api/bootstrap")
            memories = response.memories ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Memory Card Component

struct MemoryCardView: View {
    let memory: Memory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with Symbol & Visibility
            HStack(alignment: .center) {
                Text(memory.displaySymbol)
                    .font(.title3)
                    .foregroundStyle(ArchivoTheme.accent)

                Text(memory.title)
                    .font(.headline)
                    .foregroundStyle(ArchivoTheme.ink)
                    .lineLimit(1)

                Spacer()

                Image(systemName: visibilityIcon(memory.effectiveVisibility))
                    .font(.caption)
                    .foregroundStyle(ArchivoTheme.muted)
            }

            // Description
            if let description = memory.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(ArchivoTheme.muted)
                    .lineLimit(2)
            }

            // Footer with metadata
            HStack(spacing: 12) {
                if let count = memory.entryCount, count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "square.stack")
                        Text("\(count) \(count == 1 ? "elemento" : "elementos")")
                    }
                    .font(.caption2)
                    .foregroundStyle(ArchivoTheme.muted)
                }

                if let date = memory.startDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(date)
                    }
                    .font(.caption2)
                    .foregroundStyle(ArchivoTheme.muted)
                }

                Spacer()

                if memory.isOwner == 1 {
                    Text("PROPIO")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(ArchivoTheme.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ArchivoTheme.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .archivoCard()
    }

    private func visibilityIcon(_ value: String) -> String {
        switch value {
        case "public": "globe"
        case "followers": "person.2"
        default: "lock"
        }
    }
}

// MARK: - Explore View

struct ExploreView: View {
    @State private var posts: [SocialPost] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    SectionHeader(
                        eyebrow: "Descubrir sin ruido",
                        title: "Explorar",
                        subtitle: "Solo contenido compartido explícitamente."
                    )

                    if isLoading && posts.isEmpty {
                        ProgressView()
                            .padding(.vertical, 40)
                    } else if posts.isEmpty {
                        ContentUnavailableView(
                            "Sin publicaciones",
                            systemImage: "safari",
                            description: Text("Cuando tú o tus contactos compartan algo público, aparecerá aquí.")
                        )
                        .padding(.vertical, 32)
                    } else {
                        ForEach(posts) { post in
                            SocialPostCardView(post: post)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .responsiveContainer()
            }
            .background(ArchivoTheme.background.ignoresSafeArea())
            .navigationTitle("Explorar")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await load()
            }
            .task {
                await load()
            }
        }
    }

    private func load() async {
        isLoading = true
        struct Response: Decodable { let posts: [SocialPost]? }
        if let response: Response = try? await APIClient.shared.request("/api/social") {
            posts = response.posts ?? []
        }
        isLoading = false
    }
}

// MARK: - Social Post Card Component

struct SocialPostCardView: View {
    let post: SocialPost

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Author row
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle")
                    .font(.title3)
                    .foregroundStyle(ArchivoTheme.muted)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.effectiveAuthor)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ArchivoTheme.ink)
                    if let username = post.username {
                        Text("@\(username)")
                            .font(.caption2)
                            .foregroundStyle(ArchivoTheme.muted)
                    }
                }

                Spacer()

                if let kind = post.kind {
                    Text(kind.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(ArchivoTheme.muted)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ArchivoTheme.surface)
                        .clipShape(Capsule())
                }
            }

            // Post Title
            if let title = post.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ArchivoTheme.ink)
            }

            // Post Body
            if let body = post.body, !body.isEmpty {
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(ArchivoTheme.muted)
                    .lineLimit(4)
            }

            // Media Preview if present (responsive aspect ratio)
            if let mediaUrl = post.mediaUrl, let url = URL(string: mediaUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(16 / 9, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    case .failure:
                        EmptyView()
                    case .empty:
                        Rectangle()
                            .fill(ArchivoTheme.elevated)
                            .aspectRatio(16 / 9, contentMode: .fit)
                            .overlay(ProgressView())
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            // Footer
            HStack {
                Text(post.createdAt ?? "")
                    .font(.caption2)
                    .foregroundStyle(ArchivoTheme.muted)

                Spacer()

                Image(systemName: post.visibility == "public" ? "globe" : "person.2")
                    .font(.caption)
                    .foregroundStyle(ArchivoTheme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .archivoCard()
    }
}

// MARK: - Create View

struct CreateView: View {
    @State private var selection: PhotosPickerItem?
    @State private var selectedData: Data?
    @State private var selectedImage: UIImage?
    @State private var kind = "Foto"
    @State private var title = ""
    @State private var caption = ""
    @State private var visibility = "private"
    @State private var isSubmitting = false

    private let kinds = ["Foto", "Video", "Poema", "Canción", "Nota"]

    var body: some View {
        let hasData = selectedData != nil
        NavigationStack {
            Form {
                Section("Tipo de contenido") {
                    Picker("Tipo", selection: $kind) {
                        ForEach(kinds, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Multimedia") {
                    PhotosPicker(
                        selection: $selection,
                        matching: kind == "Video" ? .videos : .images
                    ) {
                        Label(
                            hasData ? "Archivo seleccionado" : "Elegir de la fototeca",
                            systemImage: hasData ? "checkmark.circle.fill" : "photo.badge.plus"
                        )
                    }

                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }

                Section("Detalles") {
                    TextField("Título", text: $title)
                    TextField("Descripción o contenido…", text: $caption, axis: .vertical)
                        .lineLimit(3...6)

                    Picker("Visibilidad", selection: $visibility) {
                        Text("Privado (solo tú)").tag("private")
                        Text("Seguidores").tag("followers")
                        Text("Público").tag("public")
                    }
                }

                Section {
                    Button {
                        // Submit to API
                    } label: {
                        HStack {
                            Spacer()
                            Text("Guardar en Archivo")
                                .font(.headline)
                                .foregroundStyle(ArchivoTheme.accentInk)
                            Spacer()
                        }
                        .frame(minHeight: ArchivoLayout.minTouchTarget)
                    }
                    .listRowBackground(ArchivoTheme.accent)
                    .disabled(title.isEmpty && caption.isEmpty && !hasData)
                }
            }
            .scrollContentBackground(.hidden)
            .background(ArchivoTheme.background.ignoresSafeArea())
            .navigationTitle("Crear")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selection) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self) {
                        selectedData = data
                        selectedImage = UIImage(data: data)
                    }
                }
            }
        }
    }
}

// MARK: - Library View

struct LibraryView: View {
    private let sections = [
        ("Música", "music.note", "Canciones y pistas guardadas"),
        ("Películas", "film", "Cine y referencias visuales"),
        ("Series", "tv", "Temporadas y episodios"),
        ("Poemas", "sparkles", "Textos y versos"),
        ("Cartas", "doc.text", "Correspondencia y notas largas"),
        ("Cápsulas", "clock.arrow.circlepath", "Mensajes para el futuro")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Colecciones culturales") {
                    ForEach(sections, id: \.0) { item in
                        NavigationLink {
                            ContentUnavailableView(
                                item.0,
                                systemImage: item.1,
                                description: Text(item.2)
                            )
                            .background(ArchivoTheme.background.ignoresSafeArea())
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.1)
                                    .foregroundStyle(ArchivoTheme.accent)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.0)
                                        .font(.body.weight(.medium))
                                    Text(item.2)
                                        .font(.caption)
                                        .foregroundStyle(ArchivoTheme.muted)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ArchivoTheme.background.ignoresSafeArea())
            .navigationTitle("Biblioteca")
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        NavigationStack {
            List {
                // Header Profile Card
                Section {
                    VStack(spacing: 14) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(ArchivoTheme.surface)
                                .frame(width: 76, height: 76)
                                .overlay(
                                    Circle()
                                        .stroke(ArchivoTheme.border, lineWidth: 1)
                                )

                            if let avatarUrl = session.profile?.avatarUrl, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Image(systemName: "person.fill").font(.title)
                                    }
                                }
                                .frame(width: 76, height: 76)
                                .clipShape(Circle())
                            } else {
                                Text(session.profile?.effectiveDisplayName.prefix(1).uppercased() ?? "A")
                                    .font(.title.weight(.semibold))
                                    .foregroundStyle(ArchivoTheme.ink)
                            }
                        }

                        VStack(spacing: 4) {
                            Text(session.profile?.effectiveDisplayName ?? "Archivo")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(ArchivoTheme.ink)

                            if let username = session.profile?.username {
                                Text("@\(username)")
                                    .font(.subheadline)
                                    .foregroundStyle(ArchivoTheme.muted)
                            }
                        }

                        if let bio = session.profile?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.footnote)
                                .foregroundStyle(ArchivoTheme.muted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(ArchivoTheme.surface)

                Section("Cuenta") {
                    NavigationLink("Notificaciones") {
                        NotificationsView()
                    }
                    NavigationLink("Privacidad y datos") {
                        Text("Centro de privacidad de Archivo")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(ArchivoTheme.background.ignoresSafeArea())
                    }
                }
                .listRowBackground(ArchivoTheme.surface)

                Section {
                    Button(role: .destructive) {
                        Task {
                            await session.logout()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cerrar sesión")
                            Spacer()
                        }
                    }
                }
                .listRowBackground(ArchivoTheme.surface)

                Section {
                    HStack {
                        Spacer()
                        Text("Archivo 0.10.0-beta.1 (19)")
                            .font(.caption)
                            .foregroundStyle(ArchivoTheme.muted)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(ArchivoTheme.background.ignoresSafeArea())
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Notifications View

struct NotificationsView: View {
    @State private var notifications: [ArchivoNotification] = []
    @State private var isLoading = false

    var body: some View {
        List {
            if isLoading && notifications.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            } else if notifications.isEmpty {
                ContentUnavailableView(
                    "Sin notificaciones",
                    systemImage: "bell.slash",
                    description: Text("Te avisaremos cuando haya actividad o recordatorios de tus recuerdos.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(notifications) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(ArchivoTheme.ink)
                        if let body = item.body {
                            Text(body)
                                .font(.subheadline)
                                .foregroundStyle(ArchivoTheme.muted)
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(ArchivoTheme.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(ArchivoTheme.background.ignoresSafeArea())
        .navigationTitle("Notificaciones")
        .task {
            isLoading = true
            struct Response: Decodable { let notifications: [ArchivoNotification]? }
            if let response: Response = try? await APIClient.shared.request("/api/notifications") {
                notifications = response.notifications ?? []
            }
            isLoading = false
        }
    }
}

// MARK: - Previews

#Preview("Memories View (393 × 852 pt)") {
    MemoriesView()
        .preferredColorScheme(.dark)
}

#Preview("Explore View (393 × 852 pt)") {
    ExploreView()
        .preferredColorScheme(.dark)
}

#Preview("Profile View (393 × 852 pt)") {
    ProfileView()
        .environment(SessionStore())
        .preferredColorScheme(.dark)
}
