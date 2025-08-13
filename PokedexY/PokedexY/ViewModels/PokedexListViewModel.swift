import Foundation
import RxSwift

class PokedexViewModel: ObservableObject {
    @Published private(set) var pokemons: [Pokemon] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var currentPage: Int = 1
    @Published private(set) var totalPages: Int = 0
    
 
    private let pageSize: Int = 20
    private let disposeBag = DisposeBag()

    var canGoPrevious: Bool { currentPage > 1 }
    var canGoNext: Bool { totalPages > 0 && currentPage < totalPages }

    func loadFirstPage() { goToPage(1) }

    func goToPage(_ page: Int) {
        guard page >= 1 else { return }
        isLoading = true
        errorMessage = nil

        let offset = (page - 1) * pageSize

        getPokemonPageRequestFull(limit: pageSize, offset: offset)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                let mapped: [Pokemon] = response.results.compactMap { item in
                    if let id = item.idFromURL {
                        return Pokemon(
                            id: id,
                            name: item.name.capitalized,
                            imageURL: officialArtworkURL(id: id), stats: []
                        )
                    }
                    return nil
                }

                self.pokemons = mapped
                self.currentPage = page

                let pages = Int(ceil(Double(response.count) / Double(self.pageSize)))
                self.totalPages = max(pages, 1)

                self.isLoading = false
            }, onError: { [weak self] error in
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
            })
            .disposed(by: disposeBag)
    }

    func nextPage()     { guard canGoNext     else { return }; goToPage(currentPage + 1) }
    func previousPage() { guard canGoPrevious else { return }; goToPage(currentPage - 1) }
}


