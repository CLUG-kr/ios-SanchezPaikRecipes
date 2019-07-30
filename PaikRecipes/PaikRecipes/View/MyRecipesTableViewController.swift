//
//  MyRecipesTableViewController.swift
//  PaikRecipes
//
//  Created by Tars on 7/26/19.
//  Copyright © 2019 sspog. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var difficultyImageView: UIImageView!
}

class MyRecipesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // navigationBar의 Back Button 이름 바꾸기
        self.navigationController?.navigationBar.topItem?.title = "메인" // backItem?이 아니다..

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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataCenter.myRecipe.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
        guard let recipeCell = cell as? RecipeCell else {
            return cell
        }
        recipeCell.recipeNameLabel.text = dataCenter.myRecipe[indexPath.row].foodName
        let difficulty: String = dataCenter.myRecipe[indexPath.row].difficulty
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
        recipeCell.difficultyImageView.image = difficultyImage

        return recipeCell
    }

    // 선택한 레시피
    // var selectedRecipe:Recipe?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataCenter.foundRecipe = dataCenter.myRecipe[indexPath.row]
        //performSegue(withIdentifier: "checkMyRecipe", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkMyRecipe" {
            if let recipeTVC = segue.destination as? RecipeTableViewController {
                recipeTVC.isFromMyRecipesView = true
                // recipeTVC.segueRecipe = selectedRecipe
            }
        }
    }
}
