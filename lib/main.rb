require_relative './tasks/pagereader'

url = 'https://dou.ua/'
pageReader = PageReader.new(url)

puts "Heads on the page:"
pageReader.extract_headings.each do |heading|
  puts heading
end
