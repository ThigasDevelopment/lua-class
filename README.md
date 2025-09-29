# 🚩 lua-class — simples, direto e idiomático

Uma implementação pequena e prática para declarar classes em Lua com sintaxe enxuta. Ideal para scripts Lua e MTA:SA.

Use recomendado: `local My = new 'My' (...)` (o sistema age como "singleton por classe").

## ✨ Por que usar

- Sintaxe concisa e fácil de ler
- Suporte básico a herança com `:extends`
- Helpers úteis: `bind` (callbacks), `:metamethods` e checagem simples de interfaces

## 👨‍💻 Exemplos rápidos

1) Counter

```lua
class 'Counter' {
  constructor = function(self, start)
    self.value = start or 0
    return self
  end;

  inc = function(self, n)
    self.value = self.value + (n or 1)
    return self.value
  end;

  get = function(self)
    return self.value
  end;
};

local C = new 'Counter' (3)
print(C:get(), C:inc()) -- 3 4
```

2) Herança (usar `super` para chamar o construtor da base)

```lua
class 'Shape' {
  constructor = function(self, c)
    self.color = c
    return self
  end;

  getColor = function(self)
    return self.color
  end;
};

class 'Rect' :extends 'Shape' {
  constructor = function(self, c, w, h)
    self:super(c)
    self.w, self.h = w, h
    return self
  end;

  area = function(self)
    return self.w * self.h
  end;
};

local R = new 'Rect' ('green', 2, 5)
print(R:getColor(), R:area()) -- green 10
```

3) Bind (callbacks)

```lua
class 'Emitter' {
  constructor = function(self)
    self.h = {}
    return self
  end;

  on = function(self, name, fn)
    self.h[name] = self.h[name] or {}
    table.insert(self.h[name], fn)
  end;

  emit = function(self, name, ...)
    for _, fn in ipairs(self.h[name] or {}) do
      fn(...)
    end
  end;
};

local E = new 'Emitter' ()

class 'Greeter' {
  constructor = function(self, name, emitter)
    self.name = name
    emitter:on('hi', bind(self.hi, self))
    return self
  end;

  hi = function(self, from)
    print('Hi', from, '->', self.name)
  end;
};

local g = new 'Greeter' ('Bob', E)
E:emit('hi', 'Alice')
```

4) Metamethods + constructor

```lua
class 'Example' :metamethods {
  __tostring = function(self)
    return 'Hello World'
  end
} {
  constructor = function(self)
    print('LOADED')
    return self
  end;
};

local ex = new 'Example' ()
print(ex) -- LOADED \n Hello World
```

5) Interfaces (declaração)

```lua
interface 'IPrintable' {
  ['toString'] = 'function',
}

class 'Person' :implements 'IPrintable' {
  constructor = function(self, n)
    self.n = n
    return self
  end;

  toString = function(self)
    return 'Person: ' .. tostring(self.n)
  end;
};
```

## 🚀 API resumida

- `class 'Name' { ... }` — define a classe
- `:extends 'Base'` — herança
- `:implements 'I'` — valida interface registrada
- `new 'Name' (args...)` — inicializa/obtém a classe (chama `constructor` se presente)
- `bind(func, self)` — cria closure que chama `func(self, ...)`

## Dicas rápidas

- Use `local X = new 'X' (...)` para não poluir o escopo global.
- Retorne `self` do `constructor` para permitir encadeamento.

## Contribuição & Licença

- PRs e sugestões são bem-vindos — abra uma issue primeiro se for uma mudança grande.
- MIT
