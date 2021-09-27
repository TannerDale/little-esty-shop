class HolidayClient
  class << self
    def upcoming_holidays
      response = Faraday.get('https://date.nager.at/api/v2/NextPublicHolidays/us')
      parse_data(response)
    end

    def parse_data(response)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
