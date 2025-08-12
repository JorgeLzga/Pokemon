
//  DetailPokemon.swift
//  PokedexY
import SwiftUI

struct PokemonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let pokemon: Pokemon

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
               
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        .overlay(
                            Text(pokemon.name.capitalized)
                                .font(.system(size: 34, weight: .bold))
                                .padding(.horizontal)
                                .minimumScaleFactor(0.6)
                        )
                        .frame(height: 72)

                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        .overlay(
                            AsyncImage(url: pokemon.imageURL) { phase in
                                switch phase {
                                case .empty: ProgressView()
                                case .success(let image): image.resizable().scaledToFit().padding(10)
                                case .failure: Image(systemName: "photo").resizable().scaledToFit().padding(10).opacity(0.5)
                                @unknown default: EmptyView()
                                }
                            }
                        )
                        .frame(width: 90, height: 72)
                }
                .padding(.horizontal, 12)

                // Tabla de stats
                VStack(spacing: 0) {
                    ForEach(Array(pokemon.stats.enumerated()), id: \.offset) { index, stat in
                        HStack {
                            Text(stat.label)
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("\(stat.value)")
                                .font(.subheadline)
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal)
                        .background(Color(.systemBackground))

                        if index < pokemon.stats.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 12)

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
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true) 
    }
}
