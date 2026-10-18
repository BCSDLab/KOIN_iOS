//
//  CoopOpen.swift
//  koin
//

struct CoopOpen {
    let dayOfWeek: DayOfWeek
    let type: MealType
    let openTime, closeTime: String
}

extension CoopOpen {
    /// hh:mm 포맷 String이 openItem, closeItem 범위 내에 속하는지 확인한다.
    func contains(time targetTime: String) -> Bool {
        do {
            let openTime = try openTime.fromHHMMToMinutes()
            let closeTime = try closeTime.fromHHMMToMinutes()
            let targetTime = try targetTime.fromHHMMToMinutes()
            return (openTime...closeTime).contains(targetTime)
        } catch {
            return false
        }
    }
}

private extension String {
    /// hh:mm 포맷 String을 분단위 Int 로 변환한다.
    func fromHHMMToMinutes() throws -> Int {
        guard count == 5 else {
            return 0
        }
        let components = components(separatedBy: ":")
        guard components.count == 2 else {
            return 0
        }
        guard let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return 0
        }
        return hour * 60 + minute
    }
}
