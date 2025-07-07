//
//  AlertPresenter.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//


import SwiftUI

struct AlertPresenter: UIViewControllerRepresentable {
    let title: String
    let message: String

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController() // empty base
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Prevent multiple alerts
        guard uiViewController.presentedViewController == nil else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default))

        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true)
        }
    }
}