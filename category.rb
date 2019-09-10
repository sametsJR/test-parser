require 'curb'
require 'nokogiri'
require_relative 'product'

class Category

  PRODUCTS_PER_PAGE = 25
  PRODUCTS_COUNT = '//*[@id="center_column"]/span'
  PRODUCTS_URLS = '//a[@class="product-name"]/@href'
  BASE_NAME = '//h1[@itemprop="name"]'
  IMAGE_LINK = '//img[@id="bigpic"]/@src'
  WEIGHT = '//ul[@class="attribute_radio_list"]//label'
  PRICE = './span[@class="price_comb"]'
  NAME = './span[@class="radio_label"]'

  attr_accessor :url

  def initialize(args = {})
    @url = args.fetch(:url)
  end

  def all_category_urls
    all_urls = []
    puts 'Parsing category urls'
    offset = 0
    page_number = 1
    while offset < products_count
      if page_number == 1
        all_urls << url
      else
        all_urls << "#{url}?p=#{page_number}"
      end
      offset += PRODUCTS_PER_PAGE
      page_number += 1
    end
    all_urls
  end

  def category_pages
    @category_pages ||= all_category_urls.map { |url| Nokogiri::HTML(Curl.get(url).body_str) }
  end

  def products_count
    @products_count = doc.xpath(PRODUCTS_COUNT).children.to_s.to_i
  end


  def doc
    @doc ||= Nokogiri::HTML(Curl.get(url).body_str)
  end

  def products_urls
    products_urls = []
    category_pages.each do |doc|
      products_urls += doc.xpath(PRODUCTS_URLS).map(&:text)
    end
    products_urls
  end

  def products
    products = []
    products_urls.each do |url|
      puts "Parsing product by url #{url}"
      doc = Nokogiri::HTML(Curl.get(url).body_str)
      base_name = doc.xpath(BASE_NAME).text.strip
      image_link = doc.xpath(IMAGE_LINK).text
      weight = doc.xpath(WEIGHT)
      weight.each do |node|
        products << Product.new(
          image: image_link,
          price: node.xpath(PRICE).text.to_f,
          name: "#{base_name}, #{node.xpath(NAME).text}"
        )
      end
    end
    products
  end
end
