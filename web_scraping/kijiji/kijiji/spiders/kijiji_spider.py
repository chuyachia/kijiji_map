import scrapy
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from .. import items


class QuotesSpider(CrawlSpider):
    name = "kijiji"
    allowed_domains = ["www.kijiji.ca"]
    start_urls = [
        'http://www.kijiji.ca/b-appartement-condo/ville-de-quebec/c37l1700124',
    ]
    rules = [
        Rule(LinkExtractor(allow=[
            "http://www.kijiji.ca/v-appartement-condo-[1-6]-1-2.*/ville-de-quebec/.+"]),
             callback='parse_item'),
        Rule(LinkExtractor(allow=["http://www.kijiji.ca/b-appartement-condo/ville-de-quebec/page-[2-9]|1[0-9]/c37l1700124"]))
        ]
# can't scrape more than 19 pages?        
        
    def parse_item(self, response):
        adattributes = response.xpath('//table[@class="ad-attributes"]')
        appartment = items.AppartmentInfo()
        appartment['code'] = response.url.split("/")[-1]
        appartment['title'] = response.xpath('//span[@itemprop="name"]/h1/text()').extract_first()
        appartment['date'] = adattributes.xpath('./*[contains(.,"Date")]/td/text()').extract_first()
        appartment['price'] = adattributes.xpath('./*[contains(.,"Prix")]//strong/text()').extract_first()
        appartment['address'] = adattributes.xpath('./*[contains(.,"Adresse")]/td/text()').extract_first()
        appartment['room'] = response.xpath('//a[@class="category-selected"]/@href').extract()[2].split("/")[3]
        appartment['url']= response.url
        return appartment

            
            
