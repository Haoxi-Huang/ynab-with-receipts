module ApplicationHelper
  def format_ynab_amount(milliunits)
    return "N/A" unless milliunits
    dollars = milliunits / 1000.0
    number_to_currency(dollars.abs)
  end

  def format_ynab_date(date)
    return "N/A" unless date
    date = Date.parse(date) if date.is_a?(String)
    date.strftime("%b %d, %Y")
  end
end
