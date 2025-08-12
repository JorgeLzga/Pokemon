//
//  Pokedex.swift
//  PokedexY
//
import SwiftUI


// MARK: - Modelo simple (con stats para el detalle)
struct Pokemon: Identifiable, Hashable {
    let id: Int
    let name: String
    let imageURL: URL
    let stats: [PokemonStat]
}

struct PokemonStat: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Int
}


func officialArtworkURL(id: Int) -> URL {
    URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")!
}


// MARK: - Mocks corregidos (con value:)
let mockPokemons: [Pokemon] = [
    Pokemon(id: 1, name: "Bulbasaur", imageURL: officialArtworkURL(id: 1), stats: [
        .init(label: "SPEED", value: 45),
        .init(label: "SPECIAL DEFENSE", value: 65),
        .init(label: "SPECIAL ATTACK", value: 65),
        .init(label: "DEFENSE", value: 49),
        .init(label: "ATTACK", value: 49),
        .init(label: "HP", value: 45),
    ]),
    Pokemon(id: 2, name: "Ivysaur", imageURL: officialArtworkURL(id: 2), stats: [
        .init(label: "SPEED", value: 60),
        .init(label: "SPECIAL DEFENSE", value: 80),
        .init(label: "SPECIAL ATTACK", value: 80),
        .init(label: "DEFENSE", value: 63),
        .init(label: "ATTACK", value: 62),
        .init(label: "HP", value: 60),
    ]),
    Pokemon(id: 3, name: "Venusaur", imageURL: officialArtworkURL(id: 3), stats: [
        .init(label: "SPEED", value: 80),
        .init(label: "SPECIAL DEFENSE", value: 100),
        .init(label: "SPECIAL ATTACK", value: 100),
        .init(label: "DEFENSE", value: 83),
        .init(label: "ATTACK", value: 82),
        .init(label: "HP", value: 80),
    ]),
    Pokemon(id: 4, name: "Charmander", imageURL: officialArtworkURL(id: 4), stats: [
        .init(label: "SPEED", value: 65),
        .init(label: "SPECIAL DEFENSE", value: 50),
        .init(label: "SPECIAL ATTACK", value: 60),
        .init(label: "DEFENSE", value: 43),
        .init(label: "ATTACK", value: 52),
        .init(label: "HP", value: 39),
    ]),
    Pokemon(id: 5, name: "Charmeleon", imageURL: officialArtworkURL(id: 5), stats: [
        .init(label: "SPEED", value: 80),
        .init(label: "SPECIAL DEFENSE", value: 65),
        .init(label: "SPECIAL ATTACK", value: 80),
        .init(label: "DEFENSE", value: 58),
        .init(label: "ATTACK", value: 64),
        .init(label: "HP", value: 58),
    ]),
    Pokemon(id: 6, name: "Charizard", imageURL: officialArtworkURL(id: 6), stats: [
        .init(label: "SPEED", value: 100),
        .init(label: "SPECIAL DEFENSE", value: 85),
        .init(label: "SPECIAL ATTACK", value: 109),
        .init(label: "DEFENSE", value: 78),
        .init(label: "ATTACK", value: 84),
        .init(label: "HP", value: 78),
    ]),
    Pokemon(id: 7, name: "Squirtle", imageURL: officialArtworkURL(id: 7), stats: [
        .init(label: "SPEED", value: 43),
        .init(label: "SPECIAL DEFENSE", value: 64),
        .init(label: "SPECIAL ATTACK", value: 50),
        .init(label: "DEFENSE", value: 65),
        .init(label: "ATTACK", value: 48),
        .init(label: "HP", value: 44),
    ]),
    Pokemon(id: 8, name: "Wartortle", imageURL: officialArtworkURL(id: 8), stats: [
        .init(label: "SPEED", value: 58),
        .init(label: "SPECIAL DEFENSE", value: 80),
        .init(label: "SPECIAL ATTACK", value: 65),
        .init(label: "DEFENSE", value: 80),
        .init(label: "ATTACK", value: 63),
        .init(label: "HP", value: 59),
    ]),
    Pokemon(id: 9, name: "Blastoise", imageURL: officialArtworkURL(id: 9), stats: [
        .init(label: "SPEED", value: 78),
        .init(label: "SPECIAL DEFENSE", value: 105),
        .init(label: "SPECIAL ATTACK", value: 85),
        .init(label: "DEFENSE", value: 100),
        .init(label: "ATTACK", value: 83),
        .init(label: "HP", value: 79),
    ])
]


// MARK: - Header estilo Pokedex
struct PokedexHeader: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.95, green: 0.27, blue: 0.27))
                .frame(height: 88)
                .ignoresSafeArea(edges: .top)

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
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

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

// MARK: - Detalle

// MARK: - Pantalla principal con navegación
struct PokedexView: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
    let pokemons: [Pokemon] = mockPokemons

    @State private var query = ""
    private var filtered: [Pokemon] {
        guard !query.isEmpty else { return pokemons }
        return pokemons.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PokedexHeader()

                SearchBar(text: $query)
                    .padding(.top, 12)

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
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: Pokemon.self) { pokemon in
                PokemonDetailView(pokemon: pokemon)
            }
        }
    }
}

// MARK: - Preview
struct PokedexView_Previews: PreviewProvider {
    static var previews: some View {
        PokedexView()
    }
}
