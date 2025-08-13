import Foundation

struct PokemonListResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [NamedAPIResource]
}

struct NamedAPIResource: Decodable {
    let name: String
    let url: String
}

extension NamedAPIResource {
    var idFromURL: Int? {
        url.split(separator: "/").compactMap { Int($0) }.last
    }
}


struct PokemonDetailDTO: Decodable {
    let id: Int
    let name: String
    let height: Int     
    let weight: Int
    let sprites: Sprites
    let types: [PokemonTypeSlotDTO]
    let stats: [PokemonStatDTO]

    struct Sprites: Decodable {
        let other: OtherSprites?

        struct OtherSprites: Decodable {
            let officialArtwork: OfficialArtwork?

            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }

            struct OfficialArtwork: Decodable {
                let frontDefault: String?

                enum CodingKeys: String, CodingKey {
                    case frontDefault = "front_default"
                }
            }
        }

        enum CodingKeys: String, CodingKey {
            case other
        }
    }
}

struct PokemonTypeSlotDTO: Decodable {
    let slot: Int
    let type: NamedAPIResource
}

struct PokemonStatDTO: Decodable {
    let baseStat: Int
    let stat: NamedAPIResource

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

// MARK: - Modelos de App/UI (lo que usas en vistas)

struct Pokemon: Identifiable, Hashable {
    let id: Int
    let name: String
    let imageURL: URL
    let stats: [PokemonStat]   // para la lista puedes dejarlo vacío si no lo necesitas
}

struct PokemonDetail: Hashable {
    let id: Int
    let name: String
    let imageURL: URL
    let heightMeters: String   // ej. "1.7 m"
    let weightKg: String       // ej. "65.0 kg"
    let types: [String]        // ej. ["Grass", "Poison"]
    let baseStats: [PokemonStat2]
}

struct PokemonStat: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Int
}

struct PokemonStat2: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Int
}

// MARK: - Helpers de mapeo

extension Pokemon {
    static func from(resource: NamedAPIResource) -> Pokemon? {
        guard let id = resource.idFromURL,
              let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
        else { return nil }

        return Pokemon(
            id: id,
            name: resource.name.capitalized,
            imageURL: url,
            stats: []
        )
    }
}

extension PokemonDetail {
    static func from(dto: PokemonDetailDTO) -> PokemonDetail {
        let meters = Double(dto.height) / 10.0
        let kilograms = Double(dto.weight) / 10.0

        let imageURLString =
            dto.sprites.other?.officialArtwork?.frontDefault ??
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(dto.id).png"

        let imageURL = URL(string: imageURLString)!

        
        let types = dto.types
            .sorted { $0.slot < $1.slot }
            .map { $0.type.name.capitalized }

       
        let baseStats = dto.stats.map {
            PokemonStat2(label: $0.stat.name.capitalized, value: $0.baseStat)
        }

        return PokemonDetail(
            id: dto.id,
            name: dto.name.capitalized,
            imageURL: imageURL,
            heightMeters: String(format: "%.1f m", meters),
            weightKg: String(format: "%.1f kg", kilograms),
            types: types,
            baseStats: baseStats
        )
    }
}
