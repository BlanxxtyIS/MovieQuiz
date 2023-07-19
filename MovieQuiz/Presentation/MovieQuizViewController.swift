import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    //Типы на экране
    struct ViewModel {
        let image: UIImage
        let questions: String
        let questionNumber: String
    }
    
    //номер текущего вопроса
    private var currentQuestionIndex = 0
    
    //счетчик правильных ответов
    private var correctAnswers = 0
    
    //Общее кол-во вопросов для квиза
    private let questionsAmount: Int = 10
    
    //фабрика вопросов
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    
    //текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSettings()
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        
        showAnswerResults(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        
        showAnswerResults(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
    
    @IBOutlet private weak var imageViev: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // логика перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let result = QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш реузальтат \(correctAnswers)/\(questionsAmount)", buttonText: "Сыграть еще раз?")
            show(quiz: result)
        } else {
            currentQuestionIndex += 1

            show(quiz: convert(model: questionFactory.requestNextQuestion()!))
        }
    }
    
    private func buttonsIsDisabled(){
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func buttonsIsEnabled(){
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
        
        //Приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку

            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageViev.image = step.image
        textLabel.text = step.question
        indexLabel.text = step.questionNumber
        screenSettings()
    }
    
//Конвертация из QuizQuestions -> QuizStepViewModel
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    //Меняет цвет рамки
    private func showAnswerResults(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageViev.layer.masksToBounds = true
        imageViev.layer.borderWidth = 8
        imageViev.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func screenSettings() {
        questionTitleLabelStyle()
        counterLabelStyle()
        imageViewStyle()
        imageViewBorderStyle()
        textLabelStyle()
        yesButtonStyle()
        noButtonStyle()
    }
    
    private func questionTitleLabelStyle() {
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.textColor = .ypWhite
    }
    
    private func counterLabelStyle() {
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.textColor = .ypWhite
    }
    
    private func imageViewStyle() {
        imageViev.layer.cornerRadius = 20
        imageViev.contentMode = .scaleAspectFill
        imageViev.backgroundColor = .ypWhite
    }
    
    private func textLabelStyle() {
        textLabel.textColor = .ypWhite
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .center
    }
    
    private func yesButtonStyle() {
        yesButton.setTitle("Да", for: .normal)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.setTitleColor(.ypBlack, for: .normal)
        yesButton.layer.cornerRadius = 15
        yesButton.backgroundColor = .ypWhite
    }
    
    private func noButtonStyle() {
        noButton.setTitle("Нет", for: .normal)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.setTitleColor(.ypBlack, for: .normal)
        noButton.layer.cornerRadius = 15
        noButton.backgroundColor = .ypWhite
    }
    
    private func imageViewBorderStyle() {
        imageViev.layer.masksToBounds = true
        imageViev.layer.borderWidth = 8
        imageViev.layer.borderColor = UIColor.clear.cgColor
        imageViev.layer.cornerRadius = 20
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
