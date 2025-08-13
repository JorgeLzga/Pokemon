import SwiftUI

struct PokemonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let pokemon: Pokemon

    @StateObject private var vm = PokemonDetailViewModel()
    
    @ViewBuilder
    private func statIcon(for label: String) -> some View {
        let key = label
            .lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")

        switch key {
        case "hp":
            Image(systemName: "heart.fill").foregroundStyle(.red)
        case "attack":
            Image(systemName: "flame.fill").foregroundStyle(.orange)
        case "defense":
            Image(systemName: "shield.fill").foregroundStyle(.blue)
        case "specialattack":
            Image(systemName: "sparkles").foregroundStyle(.pink)
        case "specialdefense":
            Image(systemName: "shield.lefthalf.fill").foregroundStyle(.teal)
        case "speed":
            Image(systemName: "speedometer").foregroundStyle(.green)
        default:
            Image(systemName: "circle.fill").foregroundStyle(.secondary)
        }
    }

    private func prettyStatName(_ s: String) -> String {
        let t = s.replacingOccurrences(of: "-", with: " ").capitalized
        return t == "Hp" ? "HP" : t
    }

    
    var body: some View {
        VStack(spacing: 0) {
            // Header reutilizado
            PokedexHeader()

            ScrollView {
                VStack(spacing: 16) {

                    // Encabezado: nombre + imagen
                    VStack(spacing: 12) {
                        // Imagen grande arriba
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .overlay(
                                AsyncImage(url: vm.imageURL ?? pokemon.imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .padding(16)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(16)
                                            .opacity(0.5)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            )
                            .frame(height: 160)
                            .padding(.horizontal, 12)

                        // Nombre abajo, más pequeño que la imagen
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                            .overlay(
                                Text(vm.detail?.name ?? pokemon.name.capitalized)
                                    .font(.system(size: 28, weight: .bold)) // ← menor que antes
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .minimumScaleFactor(0.7)
                            )
                            .frame(height: 60)
                            .padding(.horizontal, 12)
                    }

                    .padding(.horizontal, 12)

                    // Info rápida: tipos / altura / peso
                    if vm.detail != nil || vm.isLoading {
                        VStack(spacing: 8) {
                            if !vm.typesText.isEmpty {
                                Text(vm.typesText)
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule().fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                                    )
                            }

                            HStack(spacing: 12) {
                                infoChip(title: "Height", value: vm.heightText)
                                infoChip(title: "Weight", value: vm.weightText)
                            }
                        }
                        .padding(.horizontal, 12)
                    }

                    // Tabla de stats
                    // Reemplaza tu bloque de "Tabla de stats" por este:
                    VStack(spacing: 0) {
                        ForEach(Array(vm.stats.enumerated()), id: \.offset) { index, stat in
                            HStack(spacing: 12) {
                                statIcon(for: stat.label)          // ⬅️ icono
                                    .frame(width: 22)

                                Text(prettyStatName(stat.label))   // nombre formateado
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("\(stat.value)")
                                    .font(.subheadline)
                                    .frame(width: 60, alignment: .trailing)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal)
                            .background(Color(.systemBackground))

                            if index < vm.stats.count - 1 {
                                Divider()
                            }
                        }

                        if vm.isLoading && vm.stats.isEmpty {
                            HStack {
                                Text("Loading stats...")
                                    .font(.subheadline).foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ProgressView().frame(width: 60, alignment: .trailing)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal)
                            .background(Color(.systemBackground))
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 12)


                    // Error banner + Retry
                    if let msg = vm.errorMessage {
                        VStack(spacing: 8) {
                            Text(msg)
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.9))
                                .cornerRadius(8)
                            Button("Reintentar") {
                                vm.loadByID(pokemon.id)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal, 12)
                    }

                    // Botón Back
                    Button {
                        dismiss()
                    } label: {
                        Text("BACK")
                            .font(.headline)
                            .padding(.vertical, 12)
                            .frame(maxWidth: 220)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.95, green: 0.27, blue: 0.27))
                                    .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                            )
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 12)
            }
        }
        .overlay(alignment: .topTrailing) {
            if vm.isLoading {
                ProgressView().padding().background(.thinMaterial).cornerRadius(12).padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            vm.loadByID(pokemon.id)
        }
    }

    // MARK: - Subviews
    @ViewBuilder
    private func infoChip(title: String, value: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            .overlay(
                VStack(spacing: 4) {
                    Text(title).font(.caption).foregroundColor(.secondary)
                    Text(value).font(.subheadline.bold())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            )
            .frame(height: 48)
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView(
            pokemon: Pokemon(
                id: 25,
                name: "Pikachu",
                imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png")!,
                stats: []
            )
        )
    }
}
