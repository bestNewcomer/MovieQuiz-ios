import Foundation
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    private weak var viwController: UIViewController?
    
    init(viwController: UIViewController? = nil) {
        self.viwController = viwController
    }
    
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.buttonAction()
        }
        alert.addAction(action)
        
        viwController?.present(alert, animated: true)
    }
}
