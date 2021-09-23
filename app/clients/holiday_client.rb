class HolidayClient
  class << self
    def upcoming_holidays
      response = conn.get('/v2/NextPublicHolidays/us')
      parse_data(response)
    end

    def conn
      Faraday.new('https://date.nager.at/api')
    end

    def parse_data(response)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
