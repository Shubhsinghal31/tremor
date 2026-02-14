import SwiftUI
import Charts

// MARK: - Data Models
struct TremorSession: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let tag: String
    let tagColor: Color
    let duration: String
    let pressure: String
    let score: Int
}

struct TrendPoint: Identifiable {
    let id = UUID()
    let timeLabel: String
    let value: Double
}

// MARK: - Dashboard View
struct TremorAnalyticsView: View {
    @State private var selectedMetric: Int = 0 // 0 velocity, 1 pressure, 2 accuracy
    // State to present the assessment view
    @State private var showAssessment = false
    @ObservedObject var manager: PencilSensorManager

    let points: [TrendPoint] = [
        .init(timeLabel: "08:00", value: 2.0),
        .init(timeLabel: "10:00", value: 4.2),
        .init(timeLabel: "12:00", value: 3.8),
        .init(timeLabel: "14:00", value: 2.9),
        .init(timeLabel: "16:00", value: 5.1),
        .init(timeLabel: "18:00", value: 4.5),
        .init(timeLabel: "20:00", value: 3.2),
    ]

    let sessions: [TremorSession] = [
        .init(title: "Today, 09:41 AM", time: "45s", tag: "Post-Meds", tagColor: DS.green, duration: "45s", pressure: "High", score: 92),
        .init(title: "Yesterday, 08:30 PM", time: "52s", tag: "Fatigue", tagColor: DS.orange, duration: "52s", pressure: "Normal", score: 84),
        .init(title: "Yesterday, 02:15 PM", time: "48s", tag: "Pre-Meds", tagColor: DS.blue, duration: "48s", pressure: "Low", score: 78),
        .init(title: "Mon 12, 10:00 AM", time: "50s", tag: "Resting", tagColor: .gray, duration: "50s", pressure: "Normal", score: 88),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                DottedBackground()

                ScrollView {
                    VStack(spacing: 16) {

                        headerRow

                        dateChips

                        HStack(spacing: 10) {
                            Card {
                                HStack {
                                    Text("Filter: All Contexts")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(DS.subtext)
                                }
                            }
                            .frame(height: 44)

                            Pill(text: "• Pre-medication", color: DS.blue, filled: false)
                                .padding(.horizontal, 6)
                        }

                        trendCard

                        HStack(spacing: 14) {
                            stabilityCard
                            amplitudeCard
                        }

                        recentSessionsCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90) // for CTA
                }

                bottomCTA
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showAssessment) {
                 SpiralExerciseView(manager: manager)
            }
        }
    }

    private var headerRow: some View {
        HStack {
            Button { } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Home")
                }
                .foregroundStyle(DS.subtext)
            }

            Spacer()

            Text("Tremor Analytics")
                .font(.headline.weight(.semibold))

            Spacer()

            HStack(spacing: 14) {
                Image(systemName: "calendar")
                Image(systemName: "square.and.arrow.up")
            }
            .foregroundStyle(DS.subtext)
        }
        .padding(.top, 8)
    }

    private var dateChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(["Sun\n11","Mon\n12","Tue\n13","Wed\n14","Thu\n15","Fri\n16","Sat\n17"], id: \.self) { t in
                    let isSelected = t.contains("14")
                    VStack(spacing: 6) {
                        Text(t.components(separatedBy: "\n")[0])
                            .font(.caption2)
                            .foregroundStyle(isSelected ? Color.white.opacity(0.8) : DS.subtext)
                        Text(t.components(separatedBy: "\n")[1])
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(isSelected ? Color.white : DS.text)
                    }
                    .frame(width: 52, height: 56)
                    .background(isSelected ? DS.blue : Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: isSelected ? 0 : 1)
                    )
                }
            }
        }
    }

    private var trendCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Trend Analysis")
                        .font(.headline.weight(.semibold))
                    Spacer()
                    Picker("", selection: $selectedMetric) {
                        Text("Velocity").tag(0)
                        Text("Pressure").tag(1)
                        Text("Accuracy").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                }

                TrendLine(points: points)
                    .frame(height: 220)

                HStack(spacing: 18) {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.18))
                            .frame(width: 14, height: 10)
                        Text("Normal Range")
                            .font(.caption)
                            .foregroundStyle(DS.subtext)
                    }

                    HStack(spacing: 8) {
                        Circle().fill(DS.blue).frame(width: 8, height: 8)
                        Text("Patient Data")
                            .font(.caption)
                            .foregroundStyle(DS.subtext)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private var stabilityCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Stability\nScore")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DS.subtext)
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(DS.green)
                }

                HStack {
                    ZStack {
                        Circle().stroke(Color.black.opacity(0.08), lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: 0.85)
                            .stroke(DS.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 2) {
                            Text("85")
                                .font(.system(size: 34, weight: .bold))
                            Text("/ 100")
                                .font(.caption)
                                .foregroundStyle(DS.subtext)
                        }
                    }
                    .frame(width: 110, height: 110)
                    Spacer()
                }

                Text("+2.4% vs last week")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DS.green)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var amplitudeCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Tremor\nAmplitude")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DS.subtext)

                HStack(alignment: .bottom, spacing: 10) {
                    bar(height: 18, color: .gray.opacity(0.25))
                    bar(height: 46, color: DS.orange)
                    bar(height: 34, color: .gray.opacity(0.25))
                    bar(height: 16, color: .gray.opacity(0.25))
                    bar(height: 10, color: .gray.opacity(0.25))
                }
                .frame(height: 60)

                Text("AVERAGE")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DS.subtext)

                Text("0.4 mm")
                    .font(.title3.weight(.bold))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func bar(height: CGFloat, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(color)
            .frame(width: 34, height: height)
    }

    private var recentSessionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Sessions")
                    .font(.headline.weight(.semibold))
                Spacer()
                Button("See All") { }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DS.blue)
            }

            VStack(spacing: 10) {
                ForEach(sessions) { s in
                    Card {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.04))
                                .frame(width: 54, height: 54)
                                .overlay(Image(systemName: "scribble.variable").foregroundStyle(DS.blue))

                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Text(s.title).font(.subheadline.weight(.semibold))
                                    Pill(text: s.tag, color: s.tagColor, filled: true)
                                }
                                HStack(spacing: 10) {
                                    Label(s.duration, systemImage: "clock")
                                        .font(.caption)
                                        .foregroundStyle(DS.subtext)
                                    Text("Pressure: \(s.pressure)")
                                        .font(.caption)
                                        .foregroundStyle(DS.subtext)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(s.score)%")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(s.score >= 90 ? DS.green : (s.score >= 80 ? DS.blue : DS.orange))
                                Text("Score")
                                    .font(.caption2)
                                    .foregroundStyle(DS.subtext)
                            }

                            Image(systemName: "chevron.right")
                                .foregroundStyle(DS.subtext)
                        }
                    }
                }
            }
        }
        .padding(.top, 6)
    }

    private var bottomCTA: some View {
        VStack {
            Spacer()
            Button {
                showAssessment = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "pencil")
                    Text("Start New Assessment")
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(DS.blue)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: DS.blue.opacity(0.25), radius: 18, x: 0, y: 12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }
}

// Marker component used in Charts (TrendLine)
struct TrendLine: View {
    let points: [TrendPoint]
    
    var body: some View {
        Chart {
            ForEach(points) { point in
                LineMark(
                    x: .value("Time", point.timeLabel),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(DS.blue)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Time", point.timeLabel),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [DS.blue.opacity(0.3), DS.blue.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Time", point.timeLabel),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(DS.blue)
            }
        }
        // Simplified Axis
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}
