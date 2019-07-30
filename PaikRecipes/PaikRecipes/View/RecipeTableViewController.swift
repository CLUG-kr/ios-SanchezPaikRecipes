//
//  RecipeTableViewController.swift
//  PaikRecipes
//
//  Created by Tars on 7/25/19.
//  Copyright © 2019 sspog. All rights reserved.
//

import UIKit
import SafariServices // SFSafariViewController 사용
import Firebase

// TableViewCell 종류 (총 5가지)

class FoodImageCell: UITableViewCell {
    @IBOutlet weak var foodImageView: UIImageView!
}

class DifficultyCell: UITableViewCell {
    @IBOutlet weak var difficultyImageView: UIImageView!
}

class KeepCell: UITableViewCell {
    @IBAction func keepAction(_ sender: Any) {
        dataCenter.myRecipe.append(dataCenter.foundRecipe!)
    }
}

class IngredientsCell: UITableViewCell {
    @IBOutlet weak var ingredientLabel: UILabel! // 재료 이름
    @IBOutlet weak var quantityLabel: UILabel! // 재료 수량
}

class RecipeCheckCell: UITableViewCell {
}

// TableViewController
class RecipeTableViewController: UITableViewController {

    // MyRecipesView에서 넘어온 것인지 확인
    var isFromMyRecipesView: Bool = false

    // Firebase Realtime Database
    private var ref: DatabaseReference!
    private var databaseHandle:DatabaseHandle?

    var segueRecipe: Recipe?

    override func viewDidLoad() {
        super.viewDidLoad()

        // segue에서 넘어온 레시피 가져오기
        // foundRecipe = segueRecipe

        var topItemTitle: String = ""
        if isFromMyRecipesView {
            topItemTitle = "나의 레시피"
        } else {
            topItemTitle = "메인"
        }
        // navigationBar의 Back Button 이름 바꾸기
        self.navigationController?.navigationBar.topItem?.title = topItemTitle // backItem?이 아니다..

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !isFromMyRecipesView { // 만약 나의 레시피로 넘어가는 것이 아니면 바로 메인화면으로 이동
            if self.isMovingFromParent {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    func showRecipe(_ url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }

    @IBAction func checkRecipeAction(_ sender: Any) {
        showRecipe(dataCenter.foundRecipe!.recipeURL) // firebase에서 레시피 주소 가져오기
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if isFromMyRecipesView {
            return 3
        } else {
            return 5
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        // ImageCell
        case 0: return dataCenter.foundRecipe?.foodName   // 이전에 Firebase에서 가져온 레시피 데이터와 비교해서 매치되는 음식 이름
        case 1:
            if isFromMyRecipesView {
                return "필요한 재료" // IngredientsCell
            } else {
                return "" // DifficultyCell
            }
        case 2:
            if isFromMyRecipesView {
                return "" // RecipeCheckCell
            } else {
                return "" // KeepCell
            }
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
        case 1:
            if isFromMyRecipesView {
                return dataCenter.foundRecipe!.ingredientsName.count // IngredientsCell - Firebase에서 정확한 각 재료 개수 가져오기
            } else {
                return 1 // DifficultyCell
            }
        case 2:
            if isFromMyRecipesView {
                return 1 // RecipeCheckCell
            } else {
                return 1 // KeepCell
            }
        // IngredientsCell
        case 3:
            return (dataCenter.foundRecipe?.ingredientsName.count)!
            // 필요한 재료의 정확한 개수는 firebase에서 해당 레시피에 필요한 재료들을 가져와서 결정한다.
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
            var foodImage:UIImage = UIImage(named: "eggRoll")!
            if dataCenter.foundRecipe?.foodName == "달걀말이" {
                foodImage = UIImage(named: "eggRoll")!
            } else if dataCenter.foundRecipe?.foodName == "매운갈비찜" {
                foodImage = UIImage(named: "spicyPork")!
            } else {

            }

            foodImageCell.foodImageView.image = foodImage
            return foodImageCell
        case 1:
            if isFromMyRecipesView {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell", for: indexPath)
                guard let ingredientsCell = cell as? IngredientsCell else {
                    return cell
                }

                // 재료에 대한 정보들은 Firebase에서 가져온다
                ingredientsCell.ingredientLabel.text = dataCenter.foundRecipe?.ingredientsName[indexPath.row]
                ingredientsCell.quantityLabel.text = dataCenter.foundRecipe?.ingredientsQuantity[indexPath.row]

                return ingredientsCell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "difficultyCell", for: indexPath)
                guard let difficultyCell = cell as? DifficultyCell else {
                    return cell
                }
                // firebase에서 가져온 난이도에 따라 결정하기
                // firebase에는 난이도가 1, 2, 3, 4, 5 와 같이 String형으로 저장되어 있을 것.
                let difficultyImage: UIImage?
                switch dataCenter.foundRecipe?.difficulty {
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
            }
        case 2:
            if isFromMyRecipesView {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCheckCell", for: indexPath)
                guard let recipeCheckCell = cell as? RecipeCheckCell else {
                    return cell
                }
                // class RecipeCheckCell에서 RecipeCheck 버튼에 대한 동작을 수행
                return recipeCheckCell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "keepCell", for: indexPath)
                guard let keepCell = cell as? KeepCell else {
                    return cell
                }
                // class KeepCell에서 keep 버튼에 대한 동작을 수행
                return keepCell
            }
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell", for: indexPath)
            guard let ingredientsCell = cell as? IngredientsCell else {
                return cell
            }

            ingredientsCell.ingredientLabel.text = dataCenter.foundRecipe?.ingredientsName[indexPath.row]
            ingredientsCell.quantityLabel.text = dataCenter.foundRecipe?.ingredientsQuantity[indexPath.row]

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
