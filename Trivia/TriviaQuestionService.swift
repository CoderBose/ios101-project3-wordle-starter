//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Priyanka Bose on 3/15/24.
//

import Foundation

class TriviaQuestionService {
    private let apiUrl = "https://opentdb.com/api.php?amount=5&type=multiple" // 5 questions being pulled

    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(TriviaResponse.self, from: data)
                let triviaQuestions = result.results.map { triviaResult in
                    return TriviaQuestion(from: triviaResult)
                }
                completion(triviaQuestions, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

