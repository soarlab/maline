#!/usr/bin/env python

# add this package to prepare-node.sh: python-beautifulsoup

import sys
from bs4 import BeautifulSoup

class xml_parser:
    def __init__(self, filename):
        self.filename = filename
        self.package  = None
        self.process  = None
        self.activity = None
        self.soup = BeautifulSoup(open(filename).read())

    def find_activity(self):
        activities = self.soup.findAll(lambda tag: tag.name=="activity")

        for activity in activities:
            if self.activity:
                break
            intent_filters = activity.findAll(lambda tag: tag.name=="intent-filter")
            for intent_filter in intent_filters:
                categories = intent_filter.findAll(
                    lambda tag: tag.name=="category" and
                    "android.intent.category.DEFAULT" in (dict(tag.attrs))[u'android:name'])
                if len(categories) > 0:
                    self.activity = str(dict(activity.attrs)[u'android:name'])
                    break

    def find_package(self):
        packages = self.soup.findAll(lambda tag: "package" in dict(tag.attrs))
        if len(packages) > 0:
            self.package = str(dict(packages[0].attrs)[u'package'])

    def find_process(self):
        # Multiple tags could have the android:process attribute
        # declared. Most of the time it's the same process name so
        # just pick the first one in case there are multiple
        # android:process attributes.
        processes = self.soup.findAll(lambda tag: "android:process" in dict(tag.attrs))
        if len(processes) > 0:
            self.process = str(dict(processes[0].attrs)[u'android:process'])
            if self.process[0] == ':':
                self.process = self.package + self.process
        else:
            self.process = self.package

if __name__ == "__main__":
    parser = xml_parser(sys.argv[1])
    parser.find_activity()
    parser.find_package()
    parser.find_process()
    print "%s %s %s" % (parser.package, parser.process, parser.activity)
