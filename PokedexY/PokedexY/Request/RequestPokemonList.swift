import Foundation
import Alamofire
import RxSwift

func getPokemonPageRequestFull(limit: Int = 20, offset: Int = 0) -> Observable<PokemonListResponse> {
    let url = "https://pokeapi.co/api/v2/pokemon"
    let params: Parameters = ["limit": limit, "offset": offset]

    return Observable.create { obs in
        let req = AF.request(url, method: .get, parameters: params)
            .validate()
            .responseDecodable(of: PokemonListResponse.self) { res in
                switch res.result {
                case .success(let result):
                    obs.onNext(result)
                    obs.onCompleted()
                case .failure(let error):
                    obs.onError(error)
                }
            }
        return Disposables.create { req.cancel() }
    }
}

func getPokemonByID(id: Int) -> Observable<PokemonDetailDTO> {
    let url = "https://pokeapi.co/api/v2/pokemon/\(id)"
    return Observable.create { obs in
        let req = AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: PokemonDetailDTO.self) { res in
                switch res.result {
                case .success(let dto):
                    obs.onNext(dto)
                    obs.onCompleted()
                case .failure(let error):
                    obs.onError(error)
                }
            }
        return Disposables.create { req.cancel() }
    }
}

