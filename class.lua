local classes = { };

local function create (name, struct, super)
    if (classes[name]) then
        error ('Class ' .. name .. ' already exists.');
    end

    local newClass = { };
    newClass.__name, newClass.__super = name, super;

    for key, value in pairs (struct) do
        if (super) and (type (super[key]) == 'function') then
            local method = super[key];
            newClass[key] = function (self, ...)
                local old = rawget (self, 'super');
                self.super = function (t, ...)
                    return method (self, ...);
                end

                local result = value (self, ...);
                self.super = old;

                return result;
            end
        else
            newClass[key] = value;
        end
    end

    if (super) then
        setmetatable (newClass, { __index = super });
    end

    classes[name] = newClass;
    return classes[name];
end

function class (name)
    local modifiers = {
        extends = function (self, super)
            return function (methods)
                return create (name, methods, classes[super]);
            end
        end,
    };

    return setmetatable ({ },
        {
            __index = function (self, key)
                if (modifiers[key]) then
                    return modifiers[key];
                end

                if (classes[name]) then
                    return classes[name][key];
                end
                return false;
            end,

            __call = function (self, ...)
                if (classes[name]) then
                    return false;
                end
                return create (name, ...);
            end,
        }
    );
end

function new (name)
    local class = classes[name];
    if (not class) then
        return function ()
            return false;
        end
    end

    return function (...)
        local instance = setmetatable ({ }, { __index = class });

        local consType = type (instance.constructor);
        if (consType == 'function') then
            return instance:constructor (...);
        end

        return instance;
    end
end

function bind (func, self)
    local funcType = type (func);
    if (funcType ~= 'function') then
        return false;
    end

    return function (...)
        return func (self, ...);
    end
end