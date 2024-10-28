//
//  TrendService.swift
//  Moodiary
//
//  Created by YI HE on 2024/10/24.
//
import Moya
import Foundation


enum TrendService {
    case getTrends(period: TrendPeriod)
}

enum TrendPeriod {
    case week
    case month
}

extension TrendService: TargetType {
    var baseURL: URL {
        return URL(string: "http://54.255.253.1:8080")!
    }
    
    var path: String {
        switch self {
        case .getTrends:
            return "/Record/heatmap"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTrends:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getTrends(let period):
            let params: [String: Any] = [
                "period": period == .week ? "week" : "month"
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        if let token = ModelContextManager.shared.getToken() {
            return [
                "Content-type": "multipart/form-data",
                "Authorization": "\(token)"
            ]
        }
        return nil
    }
}

// MARK: - Manager
class TrendManager {
    static let shared = TrendManager()
    private let provider = MoyaProvider<TrendService>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    
    private init() {}
    
    func getTrends(period: TrendPeriod, completion: @escaping (Result<TrendData, Error>) -> Void) {
        provider.request(.getTrends(period: period)) { result in
            switch result {
            case let .success(response):
                do {
                    let trendResponse = try JSONDecoder().decode(TrendResponse.self, from: response.data)
                    if trendResponse.code == 0 && trendResponse.message == "Success" {
                        // Convert API response to TrendData
                        let trendData = self.processTrendResponse(trendResponse.data, period: period)
                        completion(.success(trendData))
                    } else {
                        // Return sample data if API call fails
                        completion(.success(self.getSampleData(for: period)))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    completion(.success(self.getSampleData(for: period)))
                }
            case let .failure(error):
                print("Network error: \(error)")
                completion(.success(self.getSampleData(for: period)))
            }
        }
    }
    
    private func processTrendResponse(_ entries: [HeatMapEntry], period: TrendPeriod) -> TrendData {
        let heatMap = entries.map { entry in
            HeatMapData(date: entry.recordDate, count: entry.postCount)
        }
        
        // Generate other sample data components
        let sampleData = getSampleData(for: period)
        
        return TrendData(
            moodTrend: sampleData.moodTrend,
            heatMap: heatMap,
            wordCloud: sampleData.wordCloud,
            summary: sampleData.summary
        )
    }
    
    private func getSampleData(for period: TrendPeriod) -> TrendData {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate sample mood trend data
        let moodTrend: [MoodData] = (0..<(period == .week ? 7 : 30)).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            return MoodData(date: date, mood: Double.random(in: 1...5))
        }.reversed()
        
        // Generate sample heat map data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let heatMap: [HeatMapData] = (0..<28).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            return HeatMapData(
                date: dateFormatter.string(from: date),
                count: Int.random(in: 0...4)
            )
        }
        
        // Generate sample word cloud data
        let wordCloud = [
            WordCloudItem(id: "1", word: "happy", weight: 80),
            WordCloudItem(id: "2", word: "work", weight: 60),
            WordCloudItem(id: "3", word: "tired", weight: 40),
            WordCloudItem(id: "4", word: "family", weight: 70),
            WordCloudItem(id: "5", word: "exercise", weight: 50)
        ]
        
        return TrendData(
            moodTrend: moodTrend,
            heatMap: heatMap,
            wordCloud: wordCloud,
            summary: "[Example data] During this period, the mood was generally stable, with ups and downs. Work pressure fluctuates, but is well managed through exercise and family company. It is recommended to continue to maintain a regular schedule and exercise appropriately."
        )
    }
}
