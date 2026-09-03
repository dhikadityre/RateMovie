//
//  UIViewController+Extensions.swift
//  RateMovie
//
//  Created by realxnesia on 30/07/23.
//

import Foundation
import UIKit
import TTGSnackbar

extension UIViewController {
    func gotoRootViewController() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let firstWindow = firstScene.windows.first else { return }
        
        let rootController = TabBarController()
        let snapshot = firstWindow.snapshotView(afterScreenUpdates: true)!
        rootController.view.addSubview(snapshot)
        
        firstWindow.rootViewController = rootController
        
        UIView.transition(
            with: snapshot,
            duration: 0.3,
            options: .curveEaseInOut,
            animations: {
                snapshot.layer.opacity = 0
            },
            completion: { status in
                snapshot.removeFromSuperview()
            }
        )
        firstWindow.makeKeyAndVisible()
    }
    
    func gotoHistoryListTransactionViewController() {
        guard
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let firstWindow = firstScene.windows.first
        else { return }
        let controller = MovieListViewController()
        controller.viewModel = DefaultMovieListViewModel(
            useCase: DefaultFetchMovieUseCase(
                repository: DefaultBaseMovieRepository(
                    remoteData: DefaultBaseRemoteMovies(),
                    localData: DefaultBaseLocalMovies()
                )
            )
        )
        let rootController = RootViewController(
            rootViewController: controller
        )
        let snapshot = firstWindow.snapshotView(afterScreenUpdates: true)!
        rootController.view.addSubview(snapshot)
        firstWindow.rootViewController = rootController
        
        UIView.transition(
            with: snapshot,
            duration: 0.3,
            options: .curveEaseInOut,
            animations: {
                snapshot.layer.opacity = 0
            },
            completion: { status in
                snapshot.removeFromSuperview()
            }
        )
        firstWindow.makeKeyAndVisible()
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func convertPhoneNumberFormat(currNumber: String) -> (String, Bool){
        var newPhoneNumb: String = ""
        if String(currNumber.prefix(2)) == "62"{
            let tempPhoneNumb = String(currNumber.suffix(currNumber.count - 2))
            newPhoneNumb = "+62\(tempPhoneNumb)"
            return (newPhoneNumb, true)
            
        } else if String(currNumber.prefix(2)) == "08"{
            let tempPhoneNumb = String(currNumber.suffix(currNumber.count - 2))
            newPhoneNumb = "+628\(tempPhoneNumb)"
            return (newPhoneNumb, true)
            
        } else if String(currNumber.prefix(3)) == "+62"{
            newPhoneNumb = currNumber
            return (newPhoneNumb, true)
        } else{
           return (currNumber, false)
        }
    }
    
    func changeTimeToWIB(start: String, end: String) -> String {
        let startTime = start.prefix(5)
        let endTime = end.prefix(5)
        if start == "" {
            return "\(String(describing: endTime)) WIB"
        } else if end == "" {
            return "\(String(describing: startTime)) WIB"
        } else {
            return "\(String(describing: startTime)) - \(String(describing: endTime)) WIB"
        }
    }
    
    func getIntFromString(with value: String) -> String {
        var flag: String?
        let stringArray = value.components(separatedBy: .decimalDigits.inverted)
        for item in stringArray {
            if let number = Int(item) {
                flag = "\(number)"
            }
        }
        return flag ?? "nil"
    }

    func changeDateToDayMonthYear(with date: String) -> String {
        let date = date.prefix(10)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "YYYY-MM-dd"
        inputFormatter.locale = Locale(identifier: "id_ID")
        
        let outputDayFormatter = DateFormatter()
        outputDayFormatter.dateFormat = "EEE"

        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "dd"
        
        let outputMonthFormatter = DateFormatter()
        outputMonthFormatter.dateFormat = "MMMM"
        outputMonthFormatter.locale = Locale(identifier: "id_ID")
        
        let outputYearFormatter = DateFormatter()
        outputYearFormatter.dateFormat = "YYYY"

        let showDate = inputFormatter.date(from: String(date))
        let resultDateString = outputDateFormatter.string(from: showDate!)
        let resultMonthString = outputMonthFormatter.string(from: showDate!)
        let resultYearString = outputYearFormatter.string(from: showDate!)
        
        return resultDateString + " " + resultMonthString + " " + resultYearString
    }
    
    func alertRequestAuthorization(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Open Access", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString){
                if #available(iOS 10.0, *){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
}
