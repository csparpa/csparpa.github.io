Title: Meditation on the Zen of Python
Date: 2014-01-22 01:00
Category: Python
Tags: zen, Python, mantra, GitHub, software
Slug: meditation-on-the-zen-of-python
Authors: csparpa
Summary: The Zen of Python does not obey the Zen of Python

### Read it

If you have ever programmed anything in Python, you probably used the `import` statement: the modules of the Python standard library 
can be imported into your code or into the interpreter. Take a look at the standard library folders and you'll find the `this.py` module... what is that?
Not much a self-explicative name for a Python module, huh? And you – Java lovers – forget about the Java `this` keyword: you're far afield.  

This module is the mystic ***"Zen of Python"***:

```python
>>> import this
 
The Zen of Python, by Tim Peters
 
Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
```

Woohaaaa!!! What?!?! A sort of mantra???  

### The Pythonic view of the software universe
Kidding apart, the Zen states the high-level development guidelines that were followed in the design of the Python language itself;
it was formerly stated into [PEP-20](http://www.python.org/dev/peps/pep-0020/) by Tim Peters, one of the fathers of the language
along with Guido Van Rossum (BDFL).  
Ok, I'm curious about it: I open the `this.py` file in my favourite text editor and I notice that...

### The Zen of Python does not obey the Zen of Python

What??? Here is the source code:  

```python
s = """Gur Mra bs Clguba, ol Gvz Crgref
 
Ornhgvshy vf orggre guna htyl.
Rkcyvpvg vf orggre guna vzcyvpvg.
Fvzcyr vf orggre guna pbzcyrk.
Pbzcyrk vf orggre guna pbzcyvpngrq.
Syng vf orggre guna arfgrq.
Fcnefr vf orggre guna qrafr.
Ernqnovyvgl pbhagf.
Fcrpvny pnfrf nera'g fcrpvny rabhtu gb oernx gur ehyrf.
Nygubhtu cenpgvpnyvgl orngf chevgl.
Reebef fubhyq arire cnff fvyragyl.
Hayrff rkcyvpvgyl fvyraprq.
Va gur snpr bs nzovthvgl, ershfr gur grzcgngvba gb thrff.
Gurer fubhyq or bar-- naq cersrenoyl bayl bar --boivbhf jnl gb qb vg.
Nygubhtu gung jnl znl abg or boivbhf ng svefg hayrff lbh'er Qhgpu.
Abj vf orggre guna arire.
Nygubhtu arire vf bsgra orggre guna *evtug* abj.
Vs gur vzcyrzragngvba vf uneq gb rkcynva, vg'f n onq vqrn.
Vs gur vzcyrzragngvba vf rnfl gb rkcynva, vg znl or n tbbq vqrn.
Anzrfcnprf ner bar ubaxvat terng vqrn -- yrg'f qb zber bs gubfr!"""
 
d = {}
for c in (65, 97):
for i in range(26):
d[chr(i+c)] = chr((i+13) % 26 + c)
 
print "".join([d.get(c, c) for c in s])
```

The first approach to this code might be bewildering... but it's not so hard to understand, in the end:
basically, you have a huge string containing the whole crypted Zen and then you decode it into readable English
characters and print it out loud. A few hints:  

- 65 is the ASCII for ‘A'
- 97 is the ASCII for ‘a'
- there are 26 letters in the English alphabet
- the `d` dictionary turns out to have uppercase/lowercase chars as keys and their corresponding translitterated chars as values. The "crypting magic" is given by: `i+13 % 26 + c`
- You have that `"A"= decrypt[crypt["A"]] = crypt[crypt["A"]]`  

Oddity: the Zen **does not follow many of its aphorisms**!  

In fact, its code is far from being explicit, and if it's true that readability counts, well, the Zen doesn't shine at it.
Ok, practicality beats purity but this is complex (not complicated) to read out; in fact the implementation could be simpler to explain,
which conveys that this could be done in a better way.

### A metaphor

My intention is not to disapprove Tim Peters's work (never be it! I am just a silly rookie!!!) but to show what I think about the Zen:
I think that it is a metaphor. It basically poses a problem to its readers, who need to "decipher" it in order to understand how it really works:
this is a strong metaphor of life – if you dig deep on problems/difficulties you come up to be sage about them.  
And so goes for Python design guidelines.

### ... and considering that "now is better than never"...

... while writing this post, I scribbeld (it was funny!) [a revised version of the Zen of Python](https://github.com/csparpa/betterzen).  
It shows a few additional features (get random aphorisms, seek for specified keywords) that can help developers to better read and lookup the original Zen of Python.
Features that – hopefully – comply with what the Zen itself says ;-)
