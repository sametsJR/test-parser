require_relative 'category'
require 'csv'


category = Category.new(url: ARGV[0])

CSV.open(ARGV[1], 'w', force_quotes: true) do |csv|
  csv << ['Name', 'Price', 'Image']
  category.products.each  do |p|
    csv << [
      p.name,
      p.price,
      p.image
    ]
  end
end
