//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Марат Хасанов on 18.07.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
