import Foundation
import SwiftUI

// MARK: - Protocols
protocol StoryDiffusionServiceProtocol {
    func generateStory(request: StoryDiffusionAPIRequest) async throws -> UIImage
}

// MARK: - Models
struct StoryDiffusionAPIRequest: Encodable {
    let seed: Int = 42
    let numIds: Int
    let sdModel: String = "Unstable"
    let numSteps: Int = 25
    let imageWidth: Int = 768
    let imageHeight: Int = 768
    let sa32Setting: Double = 0.5
    let sa64Setting: Double = 0.5
    let outputFormat: String = "webp"
    let guidanceScale: Int = 5
    let outputQuality: Int = 80
    let negativePrompt: String = "bad anatomy, bad hands, missing fingers, extra fingers, three hands, three legs, bad arms, missing legs, missing arms, poorly drawn face, bad face, fused face, cloned face, three crus, fused feet, fused thigh, extra crus, ugly fingers, horn, cartoon, cg, 3d, unreal, animate, amputation, disconnected limbs"
    let characterDescription: String
    let comicDescription: String
    let styleStrengthRatio: Int = 20
    let styleName: String
    let comicStyle: String = "Classic Comic Style"
    
    enum CodingKeys: String, CodingKey {
        case seed
        case numIds = "num_ids"
        case sdModel = "sd_model"
        case numSteps = "num_steps"
        case imageWidth = "image_width"
        case imageHeight = "image_height"
        case sa32Setting = "sa32_setting"
        case sa64Setting = "sa64_setting"
        case outputFormat = "output_format"
        case guidanceScale = "guidance_scale"
        case outputQuality = "output_quality"
        case negativePrompt = "negative_prompt"
        case characterDescription = "character_description"
        case comicDescription = "comic_description"
        case styleStrengthRatio = "style_strength_ratio"
        case styleName = "style_name"
        case comicStyle = "comic_style"
    }
}

// MARK: - Implementation
class StoryDiffusionService: StoryDiffusionServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.segmind.com/v1/storydiffusion"
    private let session: URLSession
    
    init(apiKey: String, timeout: TimeInterval = 180) {
        self.apiKey = apiKey
        
        print("🔧 Initializing StoryDiffusionService")
        print("⚙️ Timeout configuration: \(timeout) seconds")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        self.session = URLSession(configuration: config)
    }
    
    func generateStory(request: StoryDiffusionAPIRequest) async throws -> UIImage {
        print("\n=== 🌟 STORY GENERATION START ===")
        let maxRetries = 3
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                print("\n📡 Attempt \(attempt) of \(maxRetries)")
                let result = try await makeRequest(request)
                print("✅ Story generation successful on attempt \(attempt)")
                print("=== 🌟 STORY GENERATION END ===\n")
                return result
            } catch {
                lastError = error
                print("❌ Attempt \(attempt) failed: \(error.localizedDescription)")
                
                if attempt < maxRetries {
                    let delay = Double(attempt) * 2
                    print("⏳ Waiting \(delay) seconds before retry...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        print("❌ All retry attempts exhausted")
        print("=== 🌟 STORY GENERATION END ===\n")
        throw lastError ?? StoryDiffusionError.apiError("All retry attempts failed")
    }
    
    private func makeRequest(_ request: StoryDiffusionAPIRequest) async throws -> UIImage {
        print("\n=== 🌟 API REQUEST START ===")
        print("🔗 URL: \(baseURL)")
        print("🔑 Headers: x-api-key: [HIDDEN]")
        
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid URL format: \(baseURL)")
            throw StoryDiffusionError.invalidURL
        }
        
        let boundary = UUID().uuidString
        print("🔲 Using boundary: \(boundary)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let formData = createMultipartFormData(for: request, boundary: boundary)
        print("📦 Form data size: \(formData.count) bytes")
        urlRequest.httpBody = formData
        
        print("\n📤 Request Parameters:")
        Mirror(reflecting: request).children.forEach { child in
            if let label = child.label {
                print("- \(label): \(child.value)")
            }
        }
        
        print("\n⏳ Making API request...")
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Response is not HTTPURLResponse")
            throw StoryDiffusionError.invalidResponse
        }
        
        print("\n📥 Response received:")
        print("- Status code: \(httpResponse.statusCode)")
        print("- Content type: \(httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "unknown")")
        print("- Data size: \(data.count) bytes")
        
        if httpResponse.statusCode != 200 {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API Error: \(errorString)")
            throw StoryDiffusionError.apiError("Status: \(httpResponse.statusCode)")
        }
        
        guard let image = UIImage(data: data) else {
            print("❌ Failed to create UIImage from response data")
            throw StoryDiffusionError.invalidImageData
        }
        
        print("✅ Successfully created image")
        print("=== 🌟 API REQUEST END ===\n")
        return image
    }
    
    private func createMultipartFormData(for request: StoryDiffusionAPIRequest, boundary: String) -> Data {
        var formData = Data()
        let mirror = Mirror(reflecting: request)
        
        print("🏗️ Creating multipart form data")
        
        for case let (label?, value) in mirror.children {
            let fieldName = getFormFieldName(for: label)
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
            formData.append("\(value)\r\n".data(using: .utf8)!)
            print("📎 Added field: \(fieldName)")
        }
        
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        print("✅ Multipart form data created")
        return formData
    }
    
    private func getFormFieldName(for label: String) -> String {
        switch label {
            case "numIds": return "num_ids"
            case "sdModel": return "sd_model"
            case "numSteps": return "num_steps"
            case "imageWidth": return "image_width"
            case "imageHeight": return "image_height"
            case "sa32Setting": return "sa32_setting"
            case "sa64Setting": return "sa64_setting"
            case "outputFormat": return "output_format"
            case "guidanceScale": return "guidance_scale"
            case "outputQuality": return "output_quality"
            case "negativePrompt": return "negative_prompt"
            case "characterDescription": return "character_description"
            case "comicDescription": return "comic_description"
            case "styleStrengthRatio": return "style_strength_ratio"
            case "styleName": return "style_name"
            case "comicStyle": return "comic_style"
            default: return label
        }
    }
}

// MARK: - Error Types
enum StoryDiffusionError: Error {
    case invalidURL
    case invalidResponse
    case invalidImageData
    case apiError(String)
}
