import Foundation

extension CanvasModel {
    var drawingsArray: [DesignModel] {
        let set = drawings as? Set<DesignModel> ?? []
        return set.sorted { (a: DesignModel, b: DesignModel) in
            (a.timestamp ?? Date()) < (b.timestamp ?? Date())
        }
    }
}
