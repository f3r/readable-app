desc "Quartz popular articles scraper"
task :fetch_qz => :environment do
  require 'nokogiri'
  require 'open-uri'
  require 'watir-webdriver'

  # Quartz popular articles
  url = "http://qz.com/popular/"
  b = Watir::Browser.new :chrome
  # Opens link in browser
  b.goto url
  # scroll down page so that javascript will load
  150.times do b.send_keys :space end
  # allow some time for page to load
  sleep 70

  # nokogiri starts here
  doc = Nokogiri::HTML.parse(b.html)

  full = doc.css('.item')
  full.each do |article|
    title = article.at_css('.item-header h1')
    author = article.at_css('div.item-content a.author-name')
    pub_date = article.at_css('div.timestamp.item-meta-row')
    main_img_url = article.at_css('picture source')
    link_identifier = article.at_css('.short-url input')
    content = article.at_css('div.item-body')

    unless title.nil? or author.nil? or pub_date.nil? or main_img_url.nil? or link_identifier.nil? or content.nil?
      title = title.text
      author = author.text
      if pub_date.text.include? "ago"
        pub_date = Date.today
      else
        pub_date = article.at_css('div.timestamp.item-meta-row').text
      end
      main_img_url = main_img_url['srcset']
      link_identifier = link_identifier['value'].to_s
      content = content.to_s
      Article.create(:title => title, :author => author, :pub_date => pub_date, :content => content, :main_img_url => main_img_url, :link_identifier => link_identifier)
    else
      next
    end

  end

  b.close
end