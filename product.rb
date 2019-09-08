class Product
  attr_accessor :name, :price, :image

  def initialize(args = {})
    @name = args.fetch(:name)
    @price = args.fetch(:price)
    @image = args.fetch(:image)
  end
end
