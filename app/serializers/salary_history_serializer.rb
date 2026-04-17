class SalaryHistorySerializer
  def initialize(histories)
    @histories = histories
  end

  def as_json
    {
      salary_history: serialize_entries
    }
  end

  private

  def serialize_entries
    @histories.each_with_index.map do |entry, i|
      prev = i > 0 ? @histories[i - 1] : nil
      {
        effective_from: entry.effective_from.iso8601,
        salary:         "%.2f" % entry.salary,
        currency:       entry.currency,
        change:         change_percentage(prev&.salary, entry.salary)
      }
    end
  end

  def change_percentage(previous, current)
    return nil if previous.nil?
    pct = ((current - previous) / previous.to_f * 100).round(2)
    sign = pct >= 0 ? "+" : ""
    "#{sign}#{pct}%"
  end
end
