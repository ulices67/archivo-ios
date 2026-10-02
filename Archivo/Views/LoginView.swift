import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var session
    @State private var username = ""
    @State private var password = ""
    @State private var isSubmitting = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer(minLength: geometry.size.height * 0.08)

                    // Minimalist Wordmark
                    Text("ARCHIVO")
                        .font(.caption.weight(.bold))
                        .tracking(4)
                        .foregroundStyle(ArchivoTheme.muted)

                    // Fluid Title that scales down gracefully on small displays (iPhone SE)
                    Text("Lo importante\nmerece su tiempo.")
                        .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(ArchivoTheme.ink)
                        .minimumScaleFactor(0.75)
                        .lineSpacing(4)

                    VStack(spacing: 12) {
                        // Username Field
                        HStack(spacing: 12) {
                            Image(systemName: "person")
                                .foregroundStyle(ArchivoTheme.muted)
                                .frame(width: 20)
                            TextField("Usuario", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundStyle(ArchivoTheme.ink)
                        }
                        .padding(.horizontal, 16)
                        .frame(minHeight: ArchivoLayout.minTouchTarget + 6)
                        .background(ArchivoTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: ArchivoLayout.inputCornerRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: ArchivoLayout.inputCornerRadius, style: .continuous)
                                .stroke(ArchivoTheme.border, lineWidth: 1)
                        )

                        // Password Field
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundStyle(ArchivoTheme.muted)
                                .frame(width: 20)
                            SecureField("Contraseña", text: $password)
                                .textContentType(.password)
                                .foregroundStyle(ArchivoTheme.ink)
                        }
                        .padding(.horizontal, 16)
                        .frame(minHeight: ArchivoLayout.minTouchTarget + 6)
                        .background(ArchivoTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: ArchivoLayout.inputCornerRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: ArchivoLayout.inputCornerRadius, style: .continuous)
                                .stroke(ArchivoTheme.border, lineWidth: 1)
                        )
                    }
                    .padding(.top, 8)

                    // Error Message
                    if let error = session.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(error)
                        }
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                    }

                    // Submit Button with Apple HIG touch target
                    Button {
                        Task {
                            isSubmitting = true
                            _ = await session.login(username: username, password: password)
                            isSubmitting = false
                        }
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(ArchivoTheme.accentInk)
                            } else {
                                Text("Entrar")
                                    .font(.headline)
                                    .foregroundStyle(ArchivoTheme.accentInk)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: ArchivoLayout.minTouchTarget + 4)
                        .background(ArchivoTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: ArchivoLayout.buttonCornerRadius, style: .continuous))
                    }
                    .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty || isSubmitting)
                    .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: username.isEmpty || password.isEmpty)

                    Spacer(minLength: geometry.size.height * 0.08)
                }
                .padding(.horizontal, 24)
                .responsiveContainer()
                .frame(minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(ArchivoTheme.background.ignoresSafeArea())
    }
}

// MARK: - Previews
#Preview("iPhone Pro (393 × 852 pt)") {
    LoginView()
        .environment(SessionStore())
        .preferredColorScheme(.dark)
}

#Preview("iPhone SE (375 × 667 pt)") {
    LoginView()
        .environment(SessionStore())
        .preferredColorScheme(.dark)
}
