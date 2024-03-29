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

    // 나의 레시피
    var myRecipe:[Recipe]
    
    // confidence가 어느 정도 넘어야 식재료로 확신한다.
    let standardConfidence: Float

    var foundRecipe:Recipe?

    init() {
        self.recipe = []
        self.myRecipe = []
        self.standardConfidence = 0.8
    }
}

class Recipe {
    var foodName:String
    var foodImage:UIImage?
    var difficulty:String
    var ingredientsName:[String]
    var ingredientsQuantity:[String]
    var recipeURL:String

    init(foodName:String,
         foodImage:UIImage,
         difficulty:String,
         ingredientsName:[String],
         ingredientsQuantity:[String],
         recipeURL:String) {
        self.foodName = foodName
        self.foodImage = foodImage
        self.difficulty = difficulty
        self.ingredientsName = ingredientsName
        self.ingredientsQuantity = ingredientsQuantity
        self.recipeURL = recipeURL
    }
}
