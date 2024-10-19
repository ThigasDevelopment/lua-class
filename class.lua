local function create (name, struct, super)
    if (_G[name]) then
        error ('Class ' .. name .. ' already exists.');
    end

    local newClass = struct;
    newClass.__name, newClass.__loaded = name, false;

    if (super) then
        newClass.__super = super;

        newClass.super = function (self, ...)
            if (self.__super) and (self.__super['constructor']) and not (type (self.__super['constructor']) ~= 'function') then
                return self.__super['constructor'] (self, ...);
            end
        end

        setmetatable (newClass, { __index = super });
    end

    _G[name] = newClass;

    return _G[name];
end

function class (name)
    local modifiers = {
        extends = function (self, super)
            return function (methods)
                return create (name, methods, _G[super]);
            end
        end;
    };

    return setmetatable ({ },
        {
            __index = function (self, key)
                if (key ~= 'constructor') and (modifiers[key]) then
                    return modifiers[key];
                end

                if (_G[name]) then
                    return _G[name][key];
                end
                    
                return false;
            end;

            __call = function (self, ...)
                if (_G[name]) then
                    return false;
                end

                return create (name, ...);
            end;
        }
    );
end

function new (name)
    if (not _G[name]) then
        return false;
    end

    if (_G[name].__loaded) then
        return _G[name];
    end

    return function (...)
        if (_G[name]['constructor']) then
            _G[name]:constructor (...);

            _G[name].__loaded = true;
        end

        return _G[name];
    end
end