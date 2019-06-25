require "class"

local A = class()
function A:ctor()
    print("A's constructor called")
end
function A:hi()
    print("A:hi")
end
function A:dtor()
    print("A's dtor called")
end

local B = class(A)
function B:ctor()
    print("B's constructor called")
end
function B:hi()
    print("B:hi")
end
function B:dtor()
    print("B's dtor called")
end

local C = class(A)
function C:ctor()
    print("C's constructor called")
end
function C:hi()
    print("C:hi")
end
function C:dtor()
    print("C's dtor called")
end

local D = class(B, C)
function D:ctor()
    print("D's constructor called")
end
function D:dtor()
    print("D's dtor called")
end

local d = D.new()
d:hi()

local d2 = new(D)
delete(d2)

--[[ OUTPUT
A's constructor called
B's constructor called
C's constructor called
D's constructor called
B:hi
A's constructor called
B's constructor called
C's constructor called
D's constructor called
D's dtor called
B's dtor called
A's dtor called
C's dtor called
]]
