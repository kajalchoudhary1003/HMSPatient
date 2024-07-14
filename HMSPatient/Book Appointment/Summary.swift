import SwiftUI

struct AppointmentSummaryView: View {
    let selectedDoctor: Doctor?
    let selectedTimeSlot: TimeSlot?
    let appointmentDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            if let doctor = selectedDoctor, let timeSlot = selectedTimeSlot {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Doctor:")
                        .font(.headline)
                    Text("\(doctor.firstName) \(doctor.lastName)")
                        .font(.body)
                    
                        Text("Age: \(calculateAge(from: doctor.dob))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    
                        Text("Experience: \(doctor.experience) years")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    
                    Text("Date:")
                        .font(.headline)
                    Text(formatDate(appointmentDate))
                        .font(.body)
                    
                    Text("Time Slot:")
                        .font(.headline)
                    Text(formatTimeSlot(timeSlot))
                        .font(.body)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                
                Spacer()
                    Button(action: {
                        // Add payment handling logic here
                    }) {
                        HStack {
                            Text("Pay: ")
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                            
                            Text("\(doctor.fees)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "0E6B60"))
                        .cornerRadius(10)
                    }
                    .padding(.vertical)

                
            } else {
                Text("No appointment details available")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
        .padding()
        .navigationBarTitle("Summary", displayMode: .large)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTimeSlot(_ timeSlot: TimeSlot) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: timeSlot.startTime)) - \(formatter.string(from: timeSlot.endTime))"
    }
    
    private func calculateAge(from birthDate: Date) -> Int {
        let now = Date()
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }
}

extension Int {
    func currencyFormatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}

struct AppointmentSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentSummaryView(selectedDoctor: nil, selectedTimeSlot: nil, appointmentDate: Date())
    }
}
