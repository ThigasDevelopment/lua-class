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
            if (self.__super) and (self.__super['constructor']) and not (type (self.__super['constructor']) ~= 'function') then
                return self.__super['constructor'] (self, ...);
            end
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
    if (not classes[name]) then
        return false;
    end

    return function (...)
        if (classes[name]['constructor']) then
            classes[name]:constructor (...);

            classes[name].__loaded = true;
        end
        return classes[name];
    end
end