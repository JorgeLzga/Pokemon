import Foundation
import RxSwift
import Alamofire
class PokemonDetailViewModel: ObservableObject {
    @Published  var detail: PokemonDetail?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    var title: String { detail?.name ?? "Loading..." }
    var imageURL: URL? { detail?.imageURL }
    var stats: [PokemonStat2] { detail?.baseStats ?? [] }
    var typesText: String { (detail?.types ?? []).joined(separator: " / ") }
    var heightText: String { detail?.heightMeters ?? "-" }
    var weightText: String { detail?.weightKg ?? "-" }


    private let disposeBag = DisposeBag()

    func loadByID(_ id: Int) {
        isLoading = true
        errorMessage = nil

        getPokemonByID(id: id)
            .map { PokemonDetail.from(dto: $0) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] mapped in
                self?.detail = mapped
                self?.isLoading = false
            }, onError: { [weak self] error in
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
            })
            .disposed(by: disposeBag)
    }
}
