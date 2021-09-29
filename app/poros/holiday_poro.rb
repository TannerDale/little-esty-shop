
class HolidayPoro
  attr_reader :name, :date

  def initialize(data)
    @name = data[:name]
    @date = format_date(data[:date])
  end

  def format_date(date)
    numeric = date.split('-').map(&:to_i)
    Date.new(numeric.first, numeric[1], numeric.last)
  end
end
