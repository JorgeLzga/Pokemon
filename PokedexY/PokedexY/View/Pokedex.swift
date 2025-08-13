//
//  Pokedex.swift
//  PokedexY
//
import SwiftUI

func officialArtworkURL(id: Int) -> URL {
    
    URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")!
}

// MARK: - Header estilo Pokedex

struct PokedexHeader: View {
    var body: some View {
        Rectangle()
            .fill(Color(red: 0.95, green: 0.27, blue: 0.27))
            .frame(height: 88)
            .overlay(
                Text("Pokédex")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.yellow)
                    .overlay(
                        Text("Pokédex")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundColor(.blue)
                            .offset(y: 2)
                            .opacity(0.55)
                    )
            )
            .frame(maxWidth: .infinity)
            // mismo color detrás, extendido al safe area superior
            .background(
                Color(red: 0.95, green: 0.27, blue: 0.27)
                    .ignoresSafeArea(edges: .top)
            )
    }
}


struct SearchBar: View {
    @Binding var text: String
    @StateObject private var vm = PokemonDetailViewModel()
    
    


    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField("Buscar Pokémon", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 12)
    }
}


// MARK: - Card
struct PokemonCardView: View {
    let pokemon: Pokemon

    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: pokemon.imageURL) { phase in
                switch phase {
                case .empty: ProgressView().frame(height: 80)
                case .success(let img): img.resizable().scaledToFit().frame(height: 80)
                case .failure: Image(systemName: "photo").resizable().scaledToFit().frame(height: 80).opacity(0.4)
                @unknown default: EmptyView()
                }
            }
            Text(pokemon.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 4)
    }
}

struct PokedexView: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)

    @StateObject private var vm = PokedexViewModel()
    @State private var query = ""

    private var filtered: [Pokemon] {
        guard !query.isEmpty else { return vm.pokemons }
        return vm.pokemons.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PokedexHeader()

                SearchBar(text: $query)
                    .padding(.top, 12)

                if vm.isLoading && vm.pokemons.isEmpty {
                    ProgressView("Cargando…")
                        .padding()
                }

                if let err = vm.errorMessage {
                    Text(err).foregroundColor(.red).padding(.horizontal)
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filtered) { pokemon in
                            NavigationLink(value: pokemon) {
                                PokemonCardView(pokemon: pokemon)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }
                .scrollDismissesKeyboard(.interactively)

                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Button {
                            vm.previousPage()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .padding(10)
                                .background(Circle().fill(Color(.systemBackground)))
                                .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                        }
                        .disabled(!vm.canGoPrevious)
                        .opacity(vm.canGoPrevious ? 1 : 0.4)

                        Text("Página \(vm.currentPage) de \(max(vm.totalPages, 1))")
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(Color(.systemBackground))
                            )
                            .overlay(
                                Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )

                        Button {
                            vm.nextPage()
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .padding(10)
                                .background(Circle().fill(Color(.systemBackground)))
                                .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                        }
                        .disabled(!vm.canGoNext)
                        .opacity(vm.canGoNext ? 1 : 0.4)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    
                }

                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: Pokemon.self) { pokemon in
                PokemonDetailView(pokemon: pokemon)
            }
        }
        .onAppear {
            if vm.pokemons.isEmpty { vm.loadFirstPage() }
        }
    }
}

// MARK: - Preview
struct PokedexView_Previews: PreviewProvider {
    static var previews: some View {
        PokedexView()
    }
}
