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
    
    var currentQuestionIndex = 0
    var correctAnswersCount = 0

    var questions: [Question] = [
        Question(text: "What is the capital of France?", answers: ["Paris", "London", "Berlin", "Madrid"], correctAnswer: "Paris"),
        Question(text: "What is 2+2?", answers: ["4", "3", "22", "17"], correctAnswer: "4"),
        // Add more questions here...
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

        // Move to the next question regardless of whether the answer was correct
        currentQuestionIndex += 1
        loadNewQuestion()
    }

    
    func loadNewQuestion() {
        DispatchQueue.main.async {
            guard self.currentQuestionIndex < self.questions.count else {
                self.questionLabel.text = "Quiz Finished"
                self.questionCardLabel.text = "Your result: \(self.correctAnswersCount)/\(self.questions.count) correct"
                    
                self.answerButtons.forEach { $0.isEnabled = false }
                return
            }

            let question = self.questions[self.currentQuestionIndex]
            self.currentQuestion = question
            
            self.questionLabel.text = "Question \(self.currentQuestionIndex + 1)/\(self.questions.count)"
            self.questionCardLabel.text = question.text
            
            for (index, button) in self.answerButtons.enumerated() {
                button.isHidden = index >= question.answers.count
                if !button.isHidden {
                    button.setTitle(question.answers[index], for: .normal)
                    button.isEnabled = true
                }
            }
        }
    }



}


struct Question {
    let text: String
    var answers: [String]
    let correctAnswer: String
        
    init(text: String, answers: [String], correctAnswer: String) {
        self.text = text
        self.correctAnswer = correctAnswer
        self.answers = answers.shuffled() // This shuffles the answers
    }
        
    func isCorrect(answer: String) -> Bool {
        return answer == correctAnswer
    }
}

