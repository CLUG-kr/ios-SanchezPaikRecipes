//
//  dataCenter.swift
//  PaikRecipes
//
//  Created by Tars on 7/29/19.
//  Copyright © 2019 sspog. All rights reserved.
//

import Foundation
import UIKit

var dataCenter: DataCenter = DataCenter()

class DataCenter {
    var recipe:[Recipe]
    // 카메라에 보이는 식재료를 담는 Set (중복 제거)
    var ingredients:Set<String>
    // confidence가 어느 정도 넘어야 식재료로 확신한다.
    let standardConfidence: Float

    init() {
        self.recipe = []
        self.ingredients = []
        self.standardConfidence = 0.8
    }
}

class Recipe {
    let foodImage:UIImage?
    let difficulty:String
    let ingredientsName:[String]
    let ingredientsQuantity:[String]
    let recipeURL:String

    init() {
        self.foodImage = UIImage(named: "eggRoll")
        self.difficulty = "0"
        self.ingredientsName = []
        self.ingredientsQuantity = []
        self.recipeURL = ""
    }
}
