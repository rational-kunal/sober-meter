//
//  ViewController.swift
//  SoberMeter
//
//  Created by Kunal Kamble on 12/09/23.
//

import CoreML
import PencilKit
import TinyConstraints
import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {
  let DEFAULT_BG_COLOR = UIColor(red: 0.11, green: 0.10, blue: 0.15, alpha: 1.00)
  let SUCCESS_BG_COLOR = UIColor(red: 0.01, green: 0.53, blue: 0.29, alpha: 1.00)
  let FAILURE_BG_COLOR = UIColor(red: 0.91, green: 0.03, blue: 0.24, alpha: 1.00)
  let CANVAS_BG_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
  let FG_COLOR = UIColor.white

  let HERO_TEXT = "Are you sure you can drive?"
  let NEW_QUESTION_TEXT = "New Question"
  let RESULT_SUBTITLE_PLACEHOLDER_TEXT = "--"
  let RESULT_TEXT = (
    QUESTION: "⁉️",
    CORRECT: "👍",
    WRONG: "🙅"
  )

  lazy var debugImageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.layer.borderColor = UIColor.white.cgColor
    imageView.layer.borderWidth = 2.0
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.isHidden = true  // Set to false for debugging
    return imageView
  }()

  lazy var heroLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 0
    label.font = UIFont(name: "Futura-Medium", size: 24.0)
    label.textAlignment = .center
    label.textColor = FG_COLOR
    label.text = HERO_TEXT
    return label
  }()

  lazy var questionLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 0
    label.font = UIFont(name: "Futura-Bold", size: 64.0)
    label.textAlignment = .center
    label.textColor = FG_COLOR
    return label
  }()

  lazy var canvasView: PKCanvasView = {
    let canvasView = PKCanvasView(frame: .zero)
    canvasView.delegate = self
    canvasView.backgroundColor = CANVAS_BG_COLOR
    canvasView.tool = PKInkingTool(ink: PKInk(.marker, color: .white), width: 80)
    canvasView.drawingPolicy = .anyInput
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.layer.cornerRadius = 20
    return canvasView
  }()

  lazy var newQuestionButton: UIButton = {
    let newQuestionButton = UIButton(type: .system)
    newQuestionButton.tintColor = FG_COLOR
    newQuestionButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
    newQuestionButton.setTitle(NEW_QUESTION_TEXT, for: .normal)
    newQuestionButton.imageEdgeInsets = .left(-12.0)
    newQuestionButton.addTarget(self, action: #selector(newQuestion), for: .touchUpInside)
    return newQuestionButton
  }()

  lazy var resultSubtitleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 0
    label.font = UIFont(name: "Menlo", size: 10.0)
    label.textAlignment = .center
    label.textColor = FG_COLOR.withAlphaComponent(0.5)
    label.text = RESULT_SUBTITLE_PLACEHOLDER_TEXT
    return label
  }()

  lazy var resultLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 0
    label.font = UIFont(name: "Menlo", size: 70.0)
    label.textAlignment = .center
    label.textColor = FG_COLOR
    return label
  }()

  lazy var mainStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [
      heroLabel,
      questionLabel,
      canvasView,
      newQuestionButton,
      resultSubtitleLabel,
      resultLabel,
    ])
    stack.axis = .vertical
    stack.spacing = 16
    return stack
  }()

  var currentQuestion: Question!

  var questionText: String { "\(currentQuestion.x) - \(currentQuestion.y) = ?" }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = DEFAULT_BG_COLOR

    view.addSubview(mainStack)
    view.addSubview(debugImageView)
    view.bringSubviewToFront(debugImageView)
    setUpConstraints()

    // Start new question immediatly
    newQuestion()
  }

  func setUpConstraints() {
    mainStack.centerInSuperview()

    canvasView.aspectRatio(1)
    canvasView.width(to: view, offset: -12)

    debugImageView.topToSuperview(usingSafeArea: true)
    debugImageView.rightToSuperview(offset: -10, usingSafeArea: true)
    debugImageView.width(28)
    debugImageView.height(28)
  }

  func didRecognizeInput(value recognizedInput: Int, probabilty: Double) {
    let resultSubtitleText = "You:\(recognizedInput.formatted()), Answer:\(currentQuestion.answer)"
      .uppercased()
    resultSubtitleLabel.text = resultSubtitleText

    let isGuessCorrect = recognizedInput == currentQuestion.answer
    resultLabel.text = isGuessCorrect ? RESULT_TEXT.CORRECT : RESULT_TEXT.WRONG

    // Update Background
    UIView.animate(withDuration: 0.3) {
      self.view.backgroundColor = isGuessCorrect ? self.SUCCESS_BG_COLOR : self.FAILURE_BG_COLOR
    }

    // Disable user from drawing further
    canvasView.isUserInteractionEnabled = false
  }

  @objc func newQuestion() {
    // Clear canvas
    clearCanvas()
    canvasView.isUserInteractionEnabled = true

    // Update question
    currentQuestion = Question.new()
    questionLabel.text = questionText

    // Update Background
    UIView.animate(withDuration: 0.3) {
      self.view.backgroundColor = self.DEFAULT_BG_COLOR
    }
  }

  func clearCanvas() {
    canvasView.drawing = PKDrawing()
    resultSubtitleLabel.text = RESULT_SUBTITLE_PLACEHOLDER_TEXT
    self.resultLabel.text = self.RESULT_TEXT.QUESTION
  }
}

// ML Related stuff - Should be added in something like ML Manager
extension ViewController {
  func didDraw(image: UIImage) {
    guard let sanitizedInputImage = sanitizeInput(image: image) else {
      assertionFailure("Unable to create CVPixelBuffer from UIImage")
      return
    }

    // Convert the cv pixel buffer back to UIImage for debugging
    let debugImage = UIImage(pixelBuffer: sanitizedInputImage)
    debugImageView.image = debugImage

    let config = MLModelConfiguration()
    let model = try? MNISTClassifier(configuration: config)
    guard let result = try? model?.prediction(image: sanitizedInputImage) else {
      print("No result")
      return
    }

    let recognizedValue = Int(result.classLabel)
    let recognitionConfidence = result.labelProbabilities[result.classLabel] ?? -1.0
    didRecognizeInput(value: recognizedValue, probabilty: recognitionConfidence)
  }

  func sanitizeInput(image: UIImage) -> CVPixelBuffer? {
    // By default image should have a transparent background.
    // Add a black background for MNIST model.
    let imageWithBlackBG = image.blackBackground()
    return imageWithBlackBG.pixelBufferGray(width: 28, height: 28)
  }
}

extension ViewController: PKCanvasViewDelegate {
  func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    // Early return if user did not draw anything
    guard canvasView.drawing.strokes.count > 0 else {
      return
    }

    let drawnImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
    didDraw(image: drawnImage)
  }
}
