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
    var triviaQuestions: [TriviaQuestion] = []

    var questions: [Question] = [
        Question(text: "What is the capital of France?", answers: ["Paris", "London", "Berlin", "Madrid"], correctAnswer: "Paris", category: "Geography"),
        Question(text: "What is 2+2?", answers: ["4", "3", "22", "17"], correctAnswer: "4", category: "Math"),
        Question(text: "Who is the known as the \"King of Pop\"?", answers: ["MJ", "Elvis Presley", "Madonna", "Beyonce"], correctAnswer: "MJ", category: "Music"),
        Question(text: "In the iconic game \"Super Mario Bros.,\" what is the name of Mario's brother?", answers: ["Wario", "Yoshi", "Luigi", "Toad"], correctAnswer: "Luigi", category: "Video Games"),
    ]
    var currentQuestion: Question?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //loadNewQuestion()
        fetchTriviaQuestions()
    }
    
    func fetchTriviaQuestions() {
           let service = TriviaQuestionService()
           service.fetchTriviaQuestions { [weak self] questions, error in
               guard let self = self else { return }
               if let error = error {
                   print("Error fetching trivia questions:", error.localizedDescription)
               } else if let questions = questions {
                   // Ensure at least 5 questions
                   if questions.count < 5 {
                       print("Received fewer than 5 questions. Fetching additional questions...")
                       self.fetchAdditionalTriviaQuestions()
                   } else {
                       self.triviaQuestions = Array(questions.prefix(5))
                       DispatchQueue.main.async {
                           self.loadNewQuestion()
                       }
                   }
               }
           }
       }
       
       func fetchAdditionalTriviaQuestions() {
           let service = TriviaQuestionService()
           service.fetchTriviaQuestions { [weak self] additionalQuestions, error in
               guard let self = self else { return }
               if let error = error {
                   print("Error fetching additional trivia questions:", error.localizedDescription)
               } else if let additionalQuestions = additionalQuestions {
                   let remainingCount = 5 - self.triviaQuestions.count
                   if additionalQuestions.count >= remainingCount {
                       self.triviaQuestions.append(contentsOf: Array(additionalQuestions.prefix(remainingCount)))
                       DispatchQueue.main.async {
                           self.loadNewQuestion()
                       }
                   } else {
                       print("Insufficient additional questions available.")
                       // Handle case where there are not enough additional questions
                   }
               }
           }
       }
       
    func loadNewQuestion() {
        if currentQuestionIndex >= triviaQuestions.count {
            showGameOverAlert()
            return
        }
        
        let question = triviaQuestions[currentQuestionIndex]
        
        questionLabel.text = "Question \(currentQuestionIndex + 1)/\(triviaQuestions.count)"
        
        if let attributedCategory = try? NSAttributedString(data: question.category.data(using: .utf8)!,
                                                            options: [.documentType: NSAttributedString.DocumentType.html],
                                                            documentAttributes: nil) {
            categoryLabel.attributedText = attributedCategory
        } else {
            categoryLabel.text = question.category
        }
        
        if let attributedQuestion = try? NSAttributedString(data: question.question.data(using: .utf8)!,
                                                            options: [.documentType: NSAttributedString.DocumentType.html],
                                                            documentAttributes: nil) {
            questionCardLabel.attributedText = attributedQuestion
        } else {
            questionCardLabel.text = question.question
        }
        
        for (index, button) in answerButtons.enumerated() {
            let option = index < question.options.count ? question.options[index] : ""
            button.setTitle(option, for: .normal)
            button.isHidden = option.isEmpty
            button.isEnabled = !option.isEmpty
        }
    }

    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("Error: Unable to get button title.")
            return
        }

        let currentQuestion = triviaQuestions[currentQuestionIndex]

        if title == currentQuestion.correctAnswer {
            correctAnswersCount += 1
            print("Correct!")
            displayAnswerFeedback(isCorrect: true)
        } else {
            print("Wrong!")
            displayAnswerFeedback(isCorrect: false)
        }

        currentQuestionIndex += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadNewQuestion()
        }
    }

    func displayAnswerFeedback(isCorrect: Bool) {
        let currentQuestion = triviaQuestions[currentQuestionIndex]
        let correctAnswer = currentQuestion.correctAnswer
        
        let feedbackMessage: String
        let feedbackColor: UIColor
        
        if isCorrect {
            feedbackMessage = "Correct!"
            feedbackColor = UIColor.green
        } else {
            feedbackMessage = "Wrong! The correct answer is: \(correctAnswer)"
            feedbackColor = UIColor.red
        }

        answerButtons.forEach { $0.backgroundColor = feedbackColor }
        
    
        let feedbackLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        feedbackLabel.backgroundColor = feedbackColor.withAlphaComponent(0.8)
        feedbackLabel.textColor = UIColor.white
        feedbackLabel.textAlignment = .center
        feedbackLabel.text = feedbackMessage
        view.addSubview(feedbackLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            feedbackLabel.removeFromSuperview()
        }
    }


    func restartGame() {
            currentQuestionIndex = 0
            correctAnswersCount = 0
            triviaQuestions.removeAll()
            fetchTriviaQuestions()
        }

    func showGameOverAlert() {
        let alert = UIAlertController(
            title: "Game Over!",
            message: "Your result: \(correctAnswersCount)/\(triviaQuestions.count) correct",
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
        self.answers = answers.shuffled()
        self.category = category
    }

    func isCorrect(answer: String) -> Bool {
        return answer == correctAnswer
    }
}

struct TriviaQuestion {
    let question: String
    let options: [String]
    let correctAnswer: String
    let category: String
    
    init(from result: TriviaResult) {
        self.question = result.question
        self.options = result.incorrectAnswers + [result.correctAnswer]
        self.correctAnswer = result.correctAnswer
        self.category = result.category
    }
}

struct TriviaResult: Codable {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case question = "question"
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
        case category = "category"
    }
}

struct TriviaResponse: Codable {
    let results: [TriviaResult]
}

