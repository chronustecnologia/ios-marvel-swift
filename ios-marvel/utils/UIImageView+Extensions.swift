//
//  UIImageView+Extensions.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL?, placeholder: UIImage? = UIImage(named: "placeholder")) {
        self.image = placeholder
        
        guard let url = url else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let data = data,
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
