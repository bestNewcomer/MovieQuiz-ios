import Foundation
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    private weak var viwController: UIViewController?
    
    init(viwController: UIViewController? = nil) {
        self.viwController = viwController
    }
    // метод отображает алерт
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        alert.view?.accessibilityIdentifier = "Game results"
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.buttonAction()
        }
        alert.addAction(action)
        
        viwController?.present(alert, animated: true, completion: nil)
    }
}
