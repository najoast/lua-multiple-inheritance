
# 说明
最近项目里有个模块的继承体系比较复杂，需要用到多继承，找了下目前已有的实现，都不是很满意，要么代码量太多不知所云，要么就是太简单不能满足现有需求，于是干脆就自己重新写一个，因为目前我们项目里正在用的`class`函数就是我写的，所以重新写一个并不难。

代码是基于原有的单继承版本，这个版本也是基于云风的实现做了微调，主要思想就是把类的 __index 元方法由之前的 super 改为函数，在这个函数内遍历所有父类，去找想要找的字段，这里不用担心性能问题，因为父类一般不会太多，找到后也不要做缓存，否则当热更了基类函数后，派生类不会变化，没必要为了这一点性能开销而做出这种牺牲。

最后 `new` 函数基本就是云风的代码，只改成遍历 super 类了，这里需要注意的是要把执行过了构造函数标记一下，不能重复执行，否则当出现`菱形继承`时，共同基类的构造会被调用多次，而这是我们不希望看到的。Lua 的对象不像 C++ 那样里面包含有整个继承体系里所有类的实例，再由这些实例组成一个大的实例，Lua 就是一个表而已，类的函数都是通过元表来访问的，可以理解为 Lua 里类的实例就只是最终派生类的实例，不含有基类实例，这样其实就天生避免了很多问题，不像 C++ 还要虚继承才能避免多基类实例问题。

# The diamond problem
The "diamond problem" (sometimes referred to as the "Deadly Diamond of Death"[4]) is an ambiguity that arises when two classes B and C inherit from A, and class D inherits from both B and C. If there is a method in A that B and C have overridden, and D does not override it, then which version of the method does D inherit: that of B, or that of C?

关于这个问题，我们的处理方法比较简单，先找到哪个就用哪个：
```lua
for _,super in ipairs(supers) do
    local v = super[k]
    if v then
        return v
    end
end
```
这里用的是 super[k], 而不是 rawget(super, k), 也就是说会先顺着一条线找到底，找不到才会从下一个 super 那条线找。

为什么这么写，而不是先遍历所有爸爸，再遍历爷爷呢？  
很简单，因为这样代码好写，试想下代码要怎么写才能达到上述效果，使用 rawget 先遍历一遍，找不到怎么办？不好意思，开始遍历爷爷，先通过 supers 字段取出爷爷们，再遍历他们，还要去重，这是一个 O(n*n) 的循环，等于是做了 lua 底层帮我们做的事，费了半天劲，最后得到一个奇丑无比的代码，实现了一个伪需求。

所以我是不打算这样做的，如果你们项目有这个需求，就自己实现吧，本来 Lua 的 OO 就是模拟出来的，可以灵活的根据项目定制，我们不是要造一个 100% 完备的 OO 机制出来，而是要一个足够简洁，刚好够用的 OO。

# Features
总结下这个 class 的特性
1. 支持多继承
2. 菱形继承时，共享基类的构造函数只会执行一次
3. 不在实例中或派生类中缓存任何父类的函数地址，每次都触发元表遍历所有父类去找
4. The diamond problem: 使用第一个找到的版本，采用“深度优先”方式查找
5. 代码简洁，不到40行代码，容易维护，定制也方便


> https://en.wikipedia.org/wiki/Multiple_inheritance
https://www.geeksforgeeks.org/multiple-inheritance-in-c/
https://www.lua.org/pil/16.3.html
http://lua-users.org/wiki/MultipleInheritanceClasses
