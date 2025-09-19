local classes = { };

local function create (name, struct, super)
    if (classes[name]) then
        error ('Class ' .. name .. ' already exists.');
    end

    local newClass = struct;
    newClass.__name = name;

    if (super) then
        newClass.__super = super;

        newClass.super = function (self, ...)
            local super = self.__super;
            if (type (super) ~= 'table') then
                return false;
            end

            local constructorType = type (super.constructor);
            if (constructorType == 'function') then
                return super:constructor (...);
            end
            return super;
        end

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
                if (key ~= 'constructor') and (modifiers[key]) then
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
        return false;
    end

    return function (...)
        local constructorType = type (class['constructor']);
        if (constructorType == 'function') then
            class:constructor (...);
        end
        return class;
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