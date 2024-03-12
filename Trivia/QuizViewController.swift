//
//  QuizViewController.swift
//  Trivia
//
//  Created by Priyanka Bose on 3/10/24.
//

import UIKit

class QuizViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var questionCardLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    var currentQuestionIndex = 0
    var correctAnswersCount = 0

    var questions: [Question] = [
        Question(text: "What is the capital of France?", answers: ["Paris", "London", "Berlin", "Madrid"], correctAnswer: "Paris", category: "Geography"),
        Question(text: "What is 2+2?", answers: ["4", "3", "22", "17"], correctAnswer: "4", category: "Math"),
        Question(text: "Who is the known as the \"King of Pop\"?", answers: ["MJ", "Elvis Presley", "Madonna", "Beyonce"], correctAnswer: "MJ", category: "Music"),
        Question(text: "In the iconic game \"Super Mario Bros.,\" what is the name of Mario's brother?", answers: ["Wario", "Yoshi", "Luigi", "Toad"], correctAnswer: "Luigi", category: "Video Games"),
    ]
    var currentQuestion: Question?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadNewQuestion()
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle?.trimmingCharacters(in: .whitespacesAndNewlines),
              let question = currentQuestion else {
            print("Something went wrong with unwrapping the button title or current question.")
            return
        }

        if question.isCorrect(answer: title) {
            correctAnswersCount += 1
            print("Correct!")
        } else {
            print("Wrong!")
        }

        currentQuestionIndex += 1
        loadNewQuestion()
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        questions.shuffle()
        loadNewQuestion()
        
        answerButtons.forEach {
            $0.isHidden = false
            $0.isEnabled = true
        }
        
        loadNewQuestion()
    }
    
    func loadNewQuestion() {
        if currentQuestionIndex >= questions.count {
            // The quiz is over, show the alert
            showGameOverAlert()
            return
        }

        // Load the question
        let question = questions[currentQuestionIndex]
        currentQuestion = question
        
        self.questionLabel.text = "Question \(self.currentQuestionIndex + 1)/\(self.questions.count)"
        self.categoryLabel.text = question.category
        self.questionCardLabel.text = question.text
        
        for (index, button) in answerButtons.enumerated() {
            let buttonTitle = index < question.answers.count ? question.answers[index] : ""
            button.setTitle(buttonTitle, for: .normal)
            button.isHidden = buttonTitle.isEmpty
            button.isEnabled = !buttonTitle.isEmpty
        }
    }

    func showGameOverAlert() {
        let alert = UIAlertController(
            title: "Game Over!",
            message: "Your result: \(correctAnswersCount)/\(questions.count) correct",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Restart Game",
            style: .default,
            handler: { [weak self] _ in
                self?.restartGame()
            }
        ))
        
        present(alert, animated: true, completion: nil)
    }
}

struct Question {
    let text: String
    let answers: [String]
    let correctAnswer: String
    let category: String

    init(text: String, answers: [String], correctAnswer: String, category: String) {
        self.text = text
        self.correctAnswer = correctAnswer
        self.answers = answers.shuffled() // This shuffles the answers
        self.category = category // Initialize the category here
    }

    func isCorrect(answer: String) -> Bool {
        return answer == correctAnswer
    }
}

