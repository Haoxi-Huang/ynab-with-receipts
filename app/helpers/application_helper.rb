module ApplicationHelper
  def inline_svg(filename, **options)
    path = Rails.root.join("app", "assets", "images", filename)
    svg = File.read(path)
    svg = svg.sub("<svg ", "<svg class=\"#{options[:class]}\" ") if options[:class]
    svg.html_safe
  end

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
