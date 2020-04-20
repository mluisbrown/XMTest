import Foundation

struct World {
    var api: API

    init(
        makeAPIRequest: @escaping (Resource) -> Response
    ) {
        self.api = API(makeAPIRequest: makeAPIRequest)
    }
}

extension World {
    static var production: World {
        let baseURL = URL(string: "https://powerful-peak-54206.herokuapp.com/")!
        let network = Network(baseURL: baseURL)
        return World(
            makeAPIRequest: network.makeRequest(_:)
        )
    }

    static var mock: World {
        let network = MockNetwork()
        return World(
            makeAPIRequest: network.makeRequest(_:)
        )
    }

    static var failingMock: World {
        let network = MockNetwork(submitFails: true)
        return World(
            makeAPIRequest: network.makeRequest(_:)
        )
    }
}

#if DEBUG
var Current: World = .production
//var Current: World = .mock
#else
let Current: World = .production
#endif


