---
title: Removing wbr tags from Beautiful Soup object
date: 2017-06-06 12:35:16
updated:
categories:
- Python
tags:
- Beautiful Soup
---

## Goal
Get plain text from a Beautiful Soup object with `<br />` converted into line break and `<wbr />` ignored.

<!-- more -->

## Code
``` python
import re
from bs4 import BeautifulSoup

html = """
<span>
    Here is some text.
    Here is some other text with a line break in it. <br/>And it should be divided into two lines.
    This line, <wbr />contains some word break opportunities, <wbr />which should be ignored. <wbr/>And the output should be in one line.
<span/>
"""

soup = BeautifulSoup(html, 'html.parser')
tag = soup.find('span')

# remove <wbr> tags
for wbr in soup.findAll('wbr'):
    wbr_previous = wbr.previous_sibling
    wbr_next = wbr.next_sibling
    wbr_previous.string.replace_with(wbr_previous + wbr_next)
    wbr.extract()
    wbr_next.extract()

# reformat the text
content = re.sub(r'\s*?\n+\s*', '\n', tag.get_text('\n').strip())
print(content)
```

**Result:**
```
Here is some text.
Here is some other text with a line break in it.
And it should be divided into two lines.
This line, contains some word break opportunities, which should be ignored. And the output should be in one line.
```
