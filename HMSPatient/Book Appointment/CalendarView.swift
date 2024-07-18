import SwiftUI

struct CalendarView: View {
    @Binding var weeks: [[Date]]
    @Binding var currentDate: Date
    var calendarNamespace: Namespace.ID
    @Binding var isPremiumSlotsEnabled: Bool  // Add binding for isPremiumSlotsEnabled
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) { // Adjust spacing between WeekViews
                ForEach(weeks.indices, id: \.self) { weekIndex in
                    WeekView(week: weeks[weekIndex], currentDate: $currentDate, calendarNamespace: calendarNamespace, isPremiumSlotsEnabled: $isPremiumSlotsEnabled)
                        .padding(.horizontal, 15)
                }
            }
            .padding(.horizontal, 20) // Adjust overall horizontal padding
        }
    }
}

struct WeekView: View {
    let week: [Date]
    @Binding var currentDate: Date
    var calendarNamespace: Namespace.ID
    @Binding var isPremiumSlotsEnabled: Bool  // Add binding for isPremiumSlotsEnabled
    
    var body: some View {
        LazyHStack(spacing: 18) {
            ForEach(week, id: \.self) { day in
                VStack(spacing: 8) {
                    Text(day.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)

                    Text(day.format("dd"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(isSameDate(day, currentDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day, currentDate) {
                                Circle().fill(isPremiumSlotsEnabled ? Color("PremiumColor") : .customPrimary)
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: calendarNamespace)
                            }

                            if day.isToday {
                                Circle()
                                    .fill(Color.customPrimary)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 12)
                            }
                        })
                        .background(Color("SecondaryColor").shadow(.drop(radius: 1)), in: .circle)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                currentDate = day
                            }
                        }
                }
                .hSpacing(.center)
                .contentShape(.rect)
            }
        }
        .padding(.horizontal, 5) // Adjust horizontal padding for individual days
    }
    
    private func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let currentDate = Binding<Date>.constant(Date())
        let weeks: [[Date]] = [[Date(), Date(), Date(), Date(), Date(), Date(), Date()], [Date(), Date(), Date(), Date(), Date(), Date(), Date()]]
        let isPremiumSlotsEnabled = Binding<Bool>.constant(false)
        
        return CalendarView(weeks: .constant(weeks), currentDate: currentDate, calendarNamespace: Namespace().wrappedValue, isPremiumSlotsEnabled: isPremiumSlotsEnabled)
    }
}
