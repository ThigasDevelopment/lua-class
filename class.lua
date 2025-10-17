local classes, interfaces = { }, { };

local function create (name, struct, options)
    if (classes[name]) then
        error ('Class ' .. name .. ' already exists.');
    end

    local newClass = {
        __name = name,
        __super = options.super,
        __implements = options.implements,
        __metamethods = options.metamethods,
    };

    for key, value in pairs (struct) do
        if (newClass.__super) and (type (newClass.__super[key]) == 'function') then
            local method = newClass.__super[key];
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

    if (newClass.__super) then
        setmetatable (newClass, { __index = newClass.__super });
    end

    local isLuaType = {
        ['nil'] = true,

        ['table'] = true,
        
        ['number'] = true,
        ['string'] = true,
        ['thread'] = true,

        ['boolean'] = true,
        
        ['function'] = true,
        ['userdata'] = true,
    };

    local function checkImplements (name, check, object)
        local class, interface = newClass, interfaces[name];
        if (not interface) then
            error ('Interface \'' .. name .. '\' does not exist.');
        end

        if (check) then
            local objectType = type (object);
            if (objectType ~= 'table') then
                error ('Class \'' .. newClass.__name .. '\' does not implement interface \'' .. name .. '\'. Expected \'table\', got \'' .. objectType .. '\'.');
            end

            class = object;
        end

        for method, value in pairs (interface) do
            local isLua = isLuaType[value];
            if (isLua) then
                local realType = type (class[method]);
                if (realType ~= value) then
                    error ('Class \'' .. newClass.__name .. '\' does not implement method \'' .. method .. '\' of interface \'' .. name .. '\'. Expected type \'' .. value .. '\', got \'' .. realType .. '\'.');
                end
            else
                checkImplements (value, true, newClass[method]);
            end
        end
        return true;
    end
    
    for _, interfaceName in pairs (newClass.__implements) do
        checkImplements (interfaceName);
    end

    classes[name] = newClass;
    return classes[name];
end

function class (name)
    local options = {
        super = nil,
        implements = { },
        metamethods = nil,
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

        metamethods = function (self, metamethods)
            options.metamethods = metamethods;

            return self;
        end,
    };

    return setmetatable ({ }, {
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
            return create (name, methods, options);
        end,
    });
end

function interface (name)
    local interface = interfaces[name];
    if (interface) then
        return function ()
            return interface;
        end
    end

    return function (struct)
        interfaces[name] = struct;

        return interfaces[name];
    end
end

function new (name)
    local class = classes[name];
    if (not class) then
        return function ()
            return false;
        end
    end

    return function (...)
        local meta = { __index = class };
        if (class.__metamethods) then
            local blockeds = {
                ['__call'] = true,
                ['__index'] = true,
                ['__newindex'] = true,
            };

            for key, value in pairs (class.__metamethods) do
                local blocked = blockeds[key];
                if (blocked) then
                    error ('Cannot override metamethod ' .. key .. '.');
                else
                    meta[key] = value;
                end
            end
        end

        local instance = setmetatable ({ }, meta);

        local consType = type (instance.constructor);
        if (consType == 'function') then
            instance:constructor (...);
        end

        return instance;
    end
end

function bind (func, self)
    local funcType = type (func);
    if (funcType ~= 'function') then
        return function ()
            return false;
        end
    end

    return function (...)
        return func (self, ...);
    end
end

function enum (names)
    local t = { };
    if (type (names) ~= 'table') then
        return t;
    end

    for i = 0, (#names - 1) do
        local name = names[i + 1];
        t[name] = i;
    end
    return t;
end