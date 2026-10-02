import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var session
    @State private var username = ""
    @State private var password = ""
    @State private var isSubmitting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer()
            Text("ARCHIVO").font(.caption.weight(.bold)).tracking(4)
            Text("Lo importante\nmerece su tiempo.")
                .font(.system(size: 42, weight: .medium, design: .rounded))
                .textCase(.uppercase)
            TextField("Usuario", text: $username)
                .textInputAutocapitalization(.never).autocorrectionDisabled()
                .padding().background(ArchivoTheme.surface).clipShape(RoundedRectangle(cornerRadius: 14))
            SecureField("Contraseña", text: $password)
                .textContentType(.password)
                .padding().background(ArchivoTheme.surface).clipShape(RoundedRectangle(cornerRadius: 14))
            Button {
                Task {
                    isSubmitting = true
                    _ = await session.login(username: username, password: password)
                    isSubmitting = false
                }
            } label: {
                Group { if isSubmitting { ProgressView() } else { Text("Entrar") } }
                    .frame(maxWidth: .infinity).padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(ArchivoTheme.accent).foregroundStyle(.black)
            .disabled(username.isEmpty || password.isEmpty || isSubmitting)
            if let error = session.errorMessage { Text(error).font(.footnote).foregroundStyle(.red) }
            Spacer()
        }
        .padding(28)
    }
}

