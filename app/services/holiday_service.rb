class HolidayService
  class << self
    def next_three
      upcoming_holidays[..3].map do |data|
        HolidayPoro.new(data)
      end
    end

    private

    def upcoming_holidays
      HolidayClient.upcoming_holidays
    end
  end
end
