Title: Check truthiness in Python
Date: 2015-02-23 11:00
Category: Python
Tags: Python, truthiness, nonethiness, caveat
Slug: python-truthiness
Authors: csparpa
Summary: Check truthiness values in Python but pay attention to what you're doing!


Today I just want to share with you how to check truth values in Python. **Truthiness** is the boolean meaning of a value, and sometimes checking it can save you a lot of hassle. 

### In Python veritas ###

Each Python built-in type has a truthiness value:

 Type         |     True when   |   False when 
:------------:|:---------------:|:--------------:
 `NoneType`   |  never          |  always
 `bool`       |  `True`         |  `False`
 `str`        |  non-empty      |  empty
 `int`        |  not `0`        |  `0`
 `tuple       |  non-empty      |  empty
 `list`       |  non-empty      |  empty
 `dict`       |  non-empty      |  empty
 `set`        |  non-empty      |  empty


### Checking truthiness ###
You can explicitly check the truth value of a value using the `bool` built-in function:

```python
bool(4)           # True
bool('Hello')     # True
boole([1, 2, 3])  # True
```

So this - funny fact - means that `bool('False') is `True`: in Python there are no such things as Java's

```python
Boolean b1 = Boolean.valueOf("false");       # b1 is false
boolean b2 = Boolean.parseBoolean("false");  # b2 is false
```

### Truthiness vs nonethiness ###

In example, if you have a list and you want to check if it's empty or not, you can do:

```python
my_list = []
if len(my_list) == 0:
  print 'Empty'
```

but also - more concisely and more Pythonically:

```python
my_list = []
if not my_list:
  print 'Empty'
```

this is because the truth value of an empty list is `False`. But, be aware that if you do:

```python
my_list = None
if not my_list:
  print 'Empty'
```

you will get the same result ("Empty" being printed)! This is because the truth value of `None` is `False` as well. So this raises a flag: *checks for truthiness and nonethiness overlap, and therefore must be differentiated on a syntactical base*. I usually do this by *explicitly* checking for nonethiness:

```python
my_list = None
if my_list is None:  # explicit check for nonethiness
  print 'None'
if not my_list:      # check for emptiness
  print 'Empty'
```


### Defining truthiness for your class ###
You can define the behaviour of your own objects when processed by the `bool` built-in. This is done by redefining the `__bool__` hook

```python
class MyClass():
    __bool__(self):
        return False

o = MyClass()
bool(o)    # False, always
```

What happens if you don't redefine the hook? The Python documentation says:

> object.**__bool__(self)**
>
> > Called to implement truth value testing and the built-in operation `bool()`; should return `False` or `True`. When this method is not defined, `__len__()` is called, if it is defined, and the object is considered true if its result is nonzero. If a class defines neither `__len__()` nor `__bool__()`, all its instances are considered true.


### References ###
For a complete reference on Python datamodel's truthiness check out [the official documentation](https://docs.python.org/3/reference/datamodel.html).

