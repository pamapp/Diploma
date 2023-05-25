//
//  CreateModel.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 24.05.2023.
//

//import NaturalLanguage
//import Foundation
//import CreateML
//import CoreML
//
////define the input of dataset as json format
//let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/alinapotapova/Desktop/diploma/Assets/swifttest/swifttest/train.json"))
//
////let test = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/alinapotapova/Desktop/diploma/Assets/swifttest/swifttest/test.json"))
//
//// split data, 80% to train, 20% to test
//let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
//
//let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "label")
//
//// define training accuracy in %
//let trainingAccuracy = (1.0 - sentimentClassifier.trainingMetrics.classificationError) * 100
//
//// define validation accuracy in %
//let validationAccuracy = (1.0 - sentimentClassifier.validationMetrics.classificationError) * 100
//
//let evaluationMetrics = sentimentClassifier.evaluation(on: testingData, textColumn: "text", labelColumn: "label")
//
//// define evaluation accuracy in %
//let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
//
//let metadata = MLModelMetadata(author: "Alina Potapova",
//                               shortDescription: "A model trained to classify memories sentiment",
//                               version: "1.0")
//
//try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/alinapotapova/Desktop/diploma/Assets/swifttest/swifttest/SentimentClassifier.mlmodel"), metadata: metadata)
