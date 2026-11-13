import re
def elem(s,start):
    tag=re.match(r'<(\w+)',s[start:]).group(1); depth=0
    for m in re.compile(r'<(/?)'+tag+r'\b[^>]*?(/?)>').finditer(s,start):
        if m.group(1): depth-=1
        elif not m.group(2): depth+=1
        if depth==0: return m.end()
