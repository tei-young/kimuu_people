import SwiftUI

struct AppointmentBlockView: View {
    let appointment: Appointment
    let color: Color
    let timeScale: TimeScale
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(appointment.customerName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            if blockHeight > 40 {
                Text(appointment.treatmentType)
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: blockHeight)
        .background(color.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(4)
        .offset(y: topOffset)
        .padding(.horizontal, 2)
    }
    
    private var blockHeight: CGFloat {
        let minutes = CGFloat(appointment.durationMinutes)
        let pixelsPerMinute = timeScale.rowHeight / CGFloat(timeScale.rawValue)
        return max(minutes * pixelsPerMinute, 20)
    }
    
    private var topOffset: CGFloat {
        let (hour, minute) = appointment.startTime.hourAndMinute
        let totalMinutes = CGFloat(hour * 60 + minute)
        let pixelsPerMinute = timeScale.rowHeight / CGFloat(timeScale.rawValue)
        return totalMinutes * pixelsPerMinute
    }
}

#Preview {
    let user = User.mock
    let appointment = Appointment.mock(for: user.id)
    
    return VStack {
        AppointmentBlockView(
            appointment: appointment,
            color: Color(hex: user.color),
            timeScale: .hour
        )
        .frame(width: 100)
    }
    .padding()
}
