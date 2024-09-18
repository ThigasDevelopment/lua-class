# 🚩 MTA Lua System Class.

## Description
A simple class system adapted to the lua language, using syntax from other languages.

## Installation
### Requirements
- MTA:SA 1.6.0
### Download and Installation Instructions
1. Clone or download the repository.
2. Download MTA:SA to your machine: https://multitheftauto.com/
3. Place this .lua in the resource you want to use.

## Example
### In this example, a people system was created.
```lua
class 'People' {
    constructor = function (self, name, lastname)
        self.name, self.lastname = name, lastname;

        return self;
    end;

    getName = function (self)
        return self.name;
    end;

    setName = function (self, newName)
        self.name = (newName or self.name);

        return true;
    end;

    getLastName = function (self)
        return self.lastname;
    end;

    setLastName = function (self, newLastName)
        self.lastname = (newLastName or self.lastname);

        return true;
    end;

    getFullName = function (self)
        return self.name .. ' ' .. self.lastname;
    end;
};

new 'People' ('John', 'Wick'); -- Load Class.

print (People:getName ()); -- John.
print (People:getLastName ()); -- Wick.

print (People:getFullName ()); -- John Wick.
```
### In this other example, we will create a Database manager.
```lua
class 'Database' {
    constructor = function (self, type, path)
        self.data, self.connection = { }, false;

        self.avaliableTypes = {
            ['mysql'] = true;
            ['sqlite'] = true;
        };

        self.path, self.type = path, type;

        self:connect ();

        return self;
    end;

    get = function (self)
        return self.connection;
    end;

    connect = function (self)
        if (self:get ()) then
            return false;
        end

        if (not self.avaliableTypes[self.type]) then
            return false;
        end

        self.connection = dbConnect (self.type, self.path);

        if (self:get ()) then
            return true;
        end

        return false;
    end;
};

new 'Database' ('sqlite', '__tests__/database.db');

function getConnection () -- Exports this function.
    return Database:get ();
end
```

## Contribution
To contribute, follow the contributing guidelines and submit a pull request.

## License
This project is licensed under the MIT License.

## Credits
- Lead Developer: Thigas Development (draconzx).