import PencilKit

extension DesignModel {
    var drawing: PKDrawing {
        get {
            guard let data = drawingData else { return PKDrawing() }
            return (try? PKDrawing(data: data)) ?? PKDrawing()
        }
        set {
            drawingData = newValue.dataRepresentation()
        }
    }
}