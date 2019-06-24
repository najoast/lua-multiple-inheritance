-- multiple inheritance
local function class(...)
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

return class
