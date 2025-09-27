local classes, interfaces = { }, { };

local function create (name, struct, super, implements)
    if (classes[name]) then
        error ('Class ' .. name .. ' already exists.');
    end

    local newClass = { };
    newClass.__name, newClass.__super, newClass.__implements = name, super, implements;

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

    if (#newClass.__implements > 0) then
        for _, interfaceName in pairs (newClass.__implements) do
            local interface = interfaces[interfaceName];
            if (not interface) then
                error ('Interface ' .. interfaceName .. ' not found.');
            end

            for key, value in pairs (interface) do
                if (type (newClass[key]) ~= value) then
                    error ('Class ' .. name .. ' does not implement interface ' .. interfaceName .. ' correctly. Field "' .. key .. '" is of type "' .. type (newClass[key]) .. '", expected "' .. value .. '".');
                end
            end
        end
    end

    classes[name] = newClass;
    return classes[name];
end

function class (name)
    local options = {
        super = nil,
        implements = { },
    };

    local modifiers = {
        extends = function (self, super)
            options.super = classes[super];
            
            return self;
        end,

        implements = function (self, interface)
            options.implements[#options.implements + 1] = interface;

            return self;
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

            __call = function (self, methods)
                if (classes[name]) then
                    return false;
                end
                return create (name, methods, options.super, options.implements);
            end,
        }
    );
end

function interface (name, fields)
    if (interfaces[name]) then
        return interfaces[name];
    end

    interfaces[name] = fields;
    return interfaces[name];
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