# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

from scrapy.exceptions import DropItem


class KijijiPipeline(object):
    def __init__(self):
        self.names_seen = set()
    def process_item(self, item, spider):
        if item['title'] in self.names_seen:
            raise DropItem("Duplicate item found: %s" % item)
        else:
            self.names_seen.add(item['title'])
        
        item['price'] = item['price'].replace("\u00a0","").split(',')[0]
        return item

