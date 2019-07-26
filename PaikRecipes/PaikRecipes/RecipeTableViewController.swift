//
//  RecipeTableViewController.swift
//  PaikRecipes
//
//  Created by Tars on 7/25/19.
//  Copyright © 2019 sspog. All rights reserved.
//

import UIKit

// TableViewCell 종류 (총 5가지)

class FoodImageCell: UITableViewCell {
    @IBOutlet weak var foodImageView: UIImageView!
}

class DifficultyCell: UITableViewCell {
    @IBOutlet weak var difficultyImageView: UIImageView!
}

class KeepCell: UITableViewCell {
    @IBAction func keepAction(_ sender: Any) {
    }
}

class IngredientsCell: UITableViewCell {
    @IBOutlet weak var ingredientLabel: UILabel! // 재료 이름
    @IBOutlet weak var quantityLabel: UILabel! // 재료 수량
}

class RecipeCheckCell: UITableViewCell {
    @IBAction func RecipeCheckAction(_ sender: Any) {
    }
}

// TableViewController
class RecipeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // cell마다 높이를 다양하게 하기 위해서
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44 // Default

        // title 과 status bar 흰색으로 설정
        navigationController?.navigationBar.barStyle = .black
        // large title 사용 (only iOS 11)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        // ImageCell
        case 0: return "음식 사진"
        // DifficultyCell
        case 1: return ""
        // KeepCell
        case 2: return ""
        // IngredientsCell
        case 3: return "필요한 재료"
        // RecipeCheckCell
        case 4: return ""
        default: return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        // ImageCell
        case 0:
            return 1
        // DifficultyCell
        case 1:
            return 1
        // KeepCell
        case 2:
            return 1
        // IngredientsCell
        case 3:
            return 5    // 필요한 재료의 정확한 개수는 firebase에서 해당 레시피에 필요한 재료들을 가져와서 결정한다.
                        // 일단은 임의로 dummydata의 개수인 5개로 하자.

        // RecipeCheckCell
        case 4:
            return 1
        default:
            print("RecipeTVC - numberOfRowsInsection Error")
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodImageCell", for: indexPath)
            guard let foodImageCell = cell as? FoodImageCell else {
                return cell
            }
            // 이것도 firebase에서 가져온 음식 사진으로 대체하기
            guard let foodImage = UIImage(named: "eggRoll") else {
                return cell
            }
            foodImageCell.foodImageView.image = foodImage
            return foodImageCell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "difficultyCell", for: indexPath)
            guard let difficultyCell = cell as? DifficultyCell else {
                return cell
            }
            // firebase에서 가져온 난이도에 따라 결정하기
            // firebase에는 난이도가 1, 2, 3, 4, 5 와 같이 String형으로 저장되어 있을 것.
            let difficulty: String = "3"
            let difficultyImage: UIImage?
            switch difficulty {
            case "1":
                difficultyImage = UIImage(named: "difficulty1")
            case "2":
                difficultyImage = UIImage(named: "difficulty2")
            case "3":
                difficultyImage = UIImage(named: "difficulty3")
            case "4":
                difficultyImage = UIImage(named: "difficulty4")
            case "5":
                difficultyImage = UIImage(named: "difficulty5")
            default:
                difficultyImage = UIImage(named: "difficultyError") 
                print("UnRanked")
            }
            difficultyCell.difficultyImageView.image = difficultyImage
            return difficultyCell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "keepCell", for: indexPath)
            guard let keepCell = cell as? KeepCell else {
                return cell
            }
            // class KeepCell에서 keep 버튼에 대한 동작을 수행
            return keepCell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell", for: indexPath)
            guard let ingredientsCell = cell as? IngredientsCell else {
                return cell
            }
            // 재료에 대한 정보들은 추후 Firebase에서 가져온다
            // 일단은 dummydata를 사용

            let ingredients: [String] = ["계란", "양파", "당근", "쪽파", "소금"]
            let quantity: [String] = ["5개", "1/4개", "한토막(1cm)", "3줄기", "1/2(티스푼)"]
            ingredientsCell.ingredientLabel.text = ingredients[indexPath.row]
            ingredientsCell.quantityLabel.text = quantity[indexPath.row]
            return ingredientsCell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCheckCell", for: indexPath)
            guard let recipeCheckCell = cell as? RecipeCheckCell else {
                return cell
            }
            // class RecipeCheckCell에서 RecipeCheck 버튼에 대한 동작을 수행
            return recipeCheckCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath)
            print("RecipeTVC - cellForRowAt Error")
            return cell
        }
    }
}
