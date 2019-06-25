-- multiple inheritance class
function class(...)
    local cls = {}

    if select("#", ...) > 0 then
        local supers = {...}
        cls.supers = supers
        setmetatable(cls, {
            __index = function(_, k)
                for _,super in ipairs(supers) do
                    local v = super[k]
                    if v then
                        return v
                    end
                end
            end
        })
    end

    -- 为了防止共同基类的 ctor 被调用多次，使用 has_been_called 来记录已经调过的 ctor
    function cls.new(...)
        local instance = setmetatable({}, {__index = cls})
        local has_been_called = {} -- function ctor ==> bool(has been called?)
        local create
        create = function(c, ...)
            local supers = rawget(c, "supers")
            if supers then
                for _,super in ipairs(supers) do
                    create(super, ...)
                end
            end
            local ctor = rawget(c, "ctor")
            if ctor and not has_been_called[ctor] then
                ctor(instance, ...)
                has_been_called[ctor] = true
            end
        end
        create(cls, ...)
        return instance
    end

    return cls
end

function new(cls, ...)
    return cls.new(...)
end

--[[
此函数仅仅会自动调用对象的析构函数而已，并不会释放对象, 对象的
释放还是要靠 Lua 的垃圾回收，当然，首先该对象的引用要为 0,
手动调用 instance 的 dtor 也可以，但只会调用其自身的 dtor,
基类的 dtor 不会被调用。
]]
function delete(instance)
    local has_been_called = {} -- 这个表的作用和 cls.new 里的相同
    local destroy
    destroy = function(cls)
        local dtor = rawget(cls, "dtor")
        if dtor and not has_been_called[dtor] then
            dtor(instance)
            has_been_called[dtor] = true
        end
        local supers = rawget(cls, "supers")
        if supers then
            for _,super in ipairs(supers) do
                destroy(super)
            end
        end
    end

    local mt = getmetatable(instance)
    if mt and mt.__index then
        destroy(mt.__index) -- mt.__index is cls
    end
end
