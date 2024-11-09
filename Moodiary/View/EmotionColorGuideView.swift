import SwiftUI

struct EmotionColorInfo: Identifiable {
    let id = UUID()
    let emotion: String
    let color: Color
    let psychologyDescription: String
}

struct EmotionColorGuideView: View {
    @Environment(\.dismiss) var dismiss
    
    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let emotionColors: [EmotionColorInfo] = [
        EmotionColorInfo(emotion: "Joy", color: .orange, 
            psychologyDescription: "Orange represents enthusiasm and happiness. It radiates warmth and energy, promoting optimism and social connection."),
        EmotionColorInfo(emotion: "Sadness", color: .blue, 
            psychologyDescription: "Blue symbolizes depth and tranquility. While it can represent melancholy, it also brings calmness and aids in emotional processing."),
        EmotionColorInfo(emotion: "Disappointment", color: .purple, 
            psychologyDescription: "Purple represents complexity of emotions. It helps in processing disappointment through its blend of calmness and depth."),
        EmotionColorInfo(emotion: "Optimism", color: .yellow, 
            psychologyDescription: "Yellow symbolizes sunshine and hope. It brings mental clarity and promotes positive thinking."),
        EmotionColorInfo(emotion: "Neutral", color: .gray, 
            psychologyDescription: "Gray represents balance and neutrality. It provides a stable foundation for emotional equilibrium."),
        EmotionColorInfo(emotion: "Desire", color: .pink, 
            psychologyDescription: "Pink represents gentle passion and desire. It combines energy with nurturing qualities."),
        EmotionColorInfo(emotion: "Realization", color: .mint, 
            psychologyDescription: "Mint represents fresh insights and clarity. It symbolizes moments of understanding and breakthrough."),
        EmotionColorInfo(emotion: "Caring", color: .green, 
            psychologyDescription: "Green symbolizes growth and nurturing. It represents harmony and connection with others."),
        EmotionColorInfo(emotion: "Approval", color: .teal, 
            psychologyDescription: "Teal combines blue's calmness with green's balance, representing confident approval and emotional stability."),
        EmotionColorInfo(emotion: "Disapproval", color: .red, 
            psychologyDescription: "Red in disapproval represents strong emotional reactions and boundaries."),
        EmotionColorInfo(emotion: "Nervousness", color: .indigo, 
            psychologyDescription: "Indigo represents deep introspection, helping process anxiety and nervous energy."),
        EmotionColorInfo(emotion: "Grief", color: .cyan, 
            psychologyDescription: "Cyan combines blue's depth with clarity, helping process and heal from grief."),
        EmotionColorInfo(emotion: "Remorse", color: .brown, 
            psychologyDescription: "Brown represents grounding and stability, helping process feelings of remorse and regret."),
        EmotionColorInfo(emotion: "Relief", color: .mint, 
            psychologyDescription: "Mint in relief represents freshness and renewal, symbolizing the lifting of emotional burden."),
        EmotionColorInfo(emotion: "Admiration", color: .yellow, 
            psychologyDescription: "Yellow in admiration represents warmth and appreciation for others' qualities."),
        EmotionColorInfo(emotion: "Fear", color: .purple, 
            psychologyDescription: "Purple in fear represents the transformation of anxiety into understanding."),
        EmotionColorInfo(emotion: "Love", color: .pink, 
            psychologyDescription: "Pink embodies love and compassion, representing emotional warmth and acceptance."),
        EmotionColorInfo(emotion: "Confusion", color: .gray, 
            psychologyDescription: "Gray in confusion represents the space between clarity, allowing for processing uncertainty."),
        EmotionColorInfo(emotion: "Surprise", color: .orange, 
            psychologyDescription: "Orange in surprise represents sudden excitement and spontaneous joy."),
        EmotionColorInfo(emotion: "Amusement", color: .green, 
            psychologyDescription: "Green in amusement represents lighthearted joy and playful energy."),
        EmotionColorInfo(emotion: "Excitement", color: .red, 
            psychologyDescription: "Red represents passionate excitement and energetic anticipation."),
        EmotionColorInfo(emotion: "Curiosity", color: .blue, 
            psychologyDescription: "Blue in curiosity represents depth of thought and intellectual exploration."),
        EmotionColorInfo(emotion: "Disgust", color: .green, 
            psychologyDescription: "Green in disgust represents the natural response to protect oneself from harm."),
        EmotionColorInfo(emotion: "Embarrassment", color: .pink, 
            psychologyDescription: "Pink in embarrassment represents the gentle acknowledgment of human vulnerability."),
        EmotionColorInfo(emotion: "Pride", color: .yellow, 
            psychologyDescription: "Yellow in pride represents confidence and self-appreciation."),
        EmotionColorInfo(emotion: "Anger", color: .red, 
            psychologyDescription: "Red symbolizes intense emotion and passion. In anger, it represents energy that can be channeled constructively."),
        EmotionColorInfo(emotion: "Gratitude", color: .blue, 
            psychologyDescription: "Blue in gratitude represents depth of appreciation and emotional maturity.")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Understanding your emotions through colors")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.top)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                        
                        ForEach(emotionColors) { info in
                            EmotionColorCard(info: info)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Emotion Palette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct EmotionColorCard: View {
    let info: EmotionColorInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                Circle()
                    .fill(info.color)
                    .frame(width: 50, height: 50)
                    .shadow(color: info.color.opacity(0.3), radius: 5, x: 0, y: 3)
                
                Text(info.emotion)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Text(info.psychologyDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct EmotionColorGuideView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionColorGuideView()
    }
} 