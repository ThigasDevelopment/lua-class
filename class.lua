function new (name)
    return function (...)
        local object = _G[name];

        if (not object) then
            error ('Class ' .. name .. ' not found.', 2);
        end

        if (object.__loaded) then
            return false;
        end

        if (object['constructor']) and not (type (object['constructor']) ~= 'function') then
            object:constructor (...);

            _G[name].__loaded = true;
        end

        return object;
    end
end

function class (name)
    return function (methods)
        if (_G[name]) then
            error ('Class ' .. name .. ' already exists.', 2);
        end

        local newClass = { };
        newClass.__name, newClass.__index, newClass.__loaded = name, newClass, false;

        for method, callback in pairs (methods) do
            newClass[method] = callback;
        end

        _G[name] = setmetatable ({ }, newClass);

        return _G[name];
    end
end