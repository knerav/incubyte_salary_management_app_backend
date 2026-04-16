module ApplicationHelper
  def salary_change_percentage(previous, current)
    return nil if previous.nil?

    change = ((current - previous) / previous.to_f * 100).round(2)
    sign   = change >= 0 ? "+" : ""
    "#{sign}#{change}%"
  end

  def country_options
    ISO3166::Country.all
                    .map { |c| [ c.iso_short_name, c.alpha2 ] }
                    .sort_by(&:first)
  end

  def currency_options
    ISO3166::Country.all
                    .map(&:currency_code)
                    .compact
                    .uniq
                    .sort
                    .map { |code| [ code, code ] }
  end
end
