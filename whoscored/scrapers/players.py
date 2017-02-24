#!/usr/bin/env python

import mechanize
br = mechanize.Browser()
br.set_handle_robots(False)
br.open("http://myanimelist.net/anime.php?letter=B")
response = br.response().read()
print(response)
