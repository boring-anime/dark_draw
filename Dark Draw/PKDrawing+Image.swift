import PencilKit
import UIKit

// PKDrawing to UIImage preview feature is temporarily removed due to async API change in PKDrawing.draw
// extension PKDrawing {
//     func image(from rect: CGRect, traitCollection: UITraitCollection? = nil) -> UIImage {
//         let format = UIGraphicsImageRendererFormat()
//         if let traitCollection = traitCollection {
//             format.scale = traitCollection.displayScale
//         } else {
//             format.scale = 1.0 // fallback, but always prefer passing traitCollection from UIView/UIViewController
//         }
//         let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
//         return renderer.image { ctx in
//             UIColor.clear.setFill()
//             ctx.fill(rect)
//             self.draw(
//                 in: ctx.cgContext,
//                 frame: rect,
//                 from: rect,
//                 darkUserInterfaceStyle: false
//             )
//         }
//     }
// }