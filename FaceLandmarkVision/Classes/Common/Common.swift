//
//  Common.swift
//  FaceLandmarkVision
//
//  Created by Nirzar Gandhi on 02/06/25.
//

import Foundation
import UIKit

// MARK: - UI / Device Related Functions
func getStoryBoard(identifier: String, storyBoardName: String) -> UIViewController {
    return UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
}

