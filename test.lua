local class = require "class"

local A = class()
function A:ctor()
    print("A's constructor called")
end

local B = class(A)
function B:ctor()
    print("B's constructor called")
end

local C = class(A)
function C:ctor()
    print("C's constructor called")
end

local D = class(B, C)
function D:ctor()
    print("D's constructor called")
end

local d = D.new()