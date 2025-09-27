# 🚩 lua-class

Um micro-sistema de classes para Lua que prioriza legibilidade e baixo atrito. Escreva classes, métodos e herança com uma sintaxe enxuta — sem precisar montar metatables manualmente a cada vez.

Por que usar?
- ✨ Sintaxe simples: `class 'Nome' { ... }` e `class 'Filha' :extends 'Base' { ... }`.
- ⚙️ Configuração zero: importe um único arquivo (`class.lua`) e use.
- 🌍 Multiambiente: scripts Lua em geral e também MTA:SA.

Observação: este sistema funciona como um “singleton por classe”: `new 'Nome' (...)` inicializa e retorna a própria tabela da classe. É comum armazenar em uma variável local: `local Nome = new 'Nome' (...)`.

## 📦 Instalação
1) Copie `class.lua` para o seu projeto.
2) Requisite/importe no seu script (mecanismo padrão do seu ambiente).

Pronto. Sem dependências externas.

## 🔢 Exemplo 1 — Counter (contagem simples)
```lua
class 'Counter' {
    constructor = function (self, start)
        self.value = start or 0
        return self
    end;

    inc = function (self, n)
        self.value = self.value + (n or 1)
        return self.value
    end;

    get = function (self)
        return self.value
    end;
};

local Counter = new 'Counter' (10)
print(Counter:get())   -- 10
print(Counter:inc())   -- 11
print(Counter:inc(5))  -- 16
```

## 📝 Exemplo 2 — Logger (níveis e formatação)
```lua
class 'Logger' {
    constructor = function (self, level)
        self.levels = { error = 1, warn = 2, info = 3, debug = 4 }
        self.level  = self.levels[level or 'info']
        return self
    end;

    log = function (self, level, ...)
        if self.levels[level] <= self.level then
            print(string.format('[%s]', level:upper()), ...)
        end
    end;

    error = function (self, ...)
        self:log('error', ...)
    end;
    warn = function (self, ...)
        self:log('warn', ...)
    end;
    info = function (self, ...)
        self:log('info', ...)
    end;
    debug = function (self, ...)
        self:log('debug', ...)
    end;
};

local Logger = new 'Logger' ('debug')
Logger:info('Hello')
Logger:debug('a =', 42)
```

## 🔶 Exemplo 3 — Herança (Shape -> Rectangle)
```lua
class 'Shape' {
    constructor = function (self, color)
        self.color = color or 'black'
        return self
    end;

    getColor = function (self)
        return self.color
    end;
};

class 'Rectangle' :extends 'Shape' {
    constructor = function (self, color, w, h)
        self:super(color)
        self.w, self.h = w or 0, h or 0
        return self
    end;

    area = function (self)
        return self.w * self.h
    end;
};

local Rectangle = new 'Rectangle' ('red', 3, 4)
print(Rectangle:getColor()) -- red
print(Rectangle:area())     -- 12
```

## 🔗 Exemplo 4 — bind (fechando contexto)
O helper `bind(func, self)` (já disponível neste projeto) cria um closure que injeta `self` ao chamar a função — útil para callbacks e integração com bibliotecas de eventos.

```lua
class 'Emitter' {
    constructor = function (self)
        self.handlers = {}
        return self
    end;

    on = function (self, name, fn)
        self.handlers[name] = self.handlers[name] or {}
        table.insert(self.handlers[name], fn)
    end;

    emit = function (self, name, ...)
        local hs = self.handlers[name]; if not hs then return end
        for _, fn in ipairs(hs) do fn(...) end
    end;
};

local Emitter = new 'Emitter' ()

class 'Greeter' {
    constructor = function (self, name, emitter)
        self.name = name
        emitter:on('hello', bind(self.onHello, self))
        return self
    end;

    onHello = function (self, from)
        print(("Hi %s! I'm %s."):format(from, self.name))
    end;
};

local Greeter = new 'Greeter' ('Alice', Emitter)
Emitter:emit('hello', 'Bob')
```

> Nota: Em MTA:SA, você pode usar `bind(self.onClick, self)` com `addEventHandler`. Mas o `bind` é genérico e funciona em qualquer ambiente Lua.

## ✨ Exemplo 5 — Metamethods e constructor
Um exemplo simples mostrando um `constructor` que imprime quando a classe é carregada e um metamethod `__tostring`.

```lua
class 'Example' :metamethod {
    __tostring = function(self)
        return 'Hello World'
    end
} {
    constructor = function(self)
        print('LOADED')
        return self
    end;
};

local Example = new 'Example' ()
print(Example) -- output: 'LOADED' (from constructor) seguido por 'Hello World' (via __tostring)
```

## 🎮 Exemplo 6 — Uso de `bind` com `addEventHandler` (MTA:SA)
No MTA:SA a função `addEventHandler` recebe um handler; `bind` é útil para manter o `self` correto em métodos de instância.

```lua
-- suponha que `myGuiButton` seja um elemento GUI já criado
class 'Button' {
    constructor = function(self, element)
        self.element = element
        -- registra o handler com o método ligado ao contexto da instância
        addEventHandler('onClientGUIClick', element, bind(self.onClick, self), false)
        return self
    end;

    onClick = function(self, button)
        print('Botão clicado por', button)
    end;
};

local btn = new 'Button' (myGuiButton)
```

## 🔐 Interfaces e `implements`
Este projeto pode suportar um sistema simples de interfaces (contratos) para validar que uma classe implementa certos métodos. A ideia básica:

- `interface(name, { 'metodo1', 'metodo2' })` registra o contrato.
- `class 'X' :implements 'IExample' { ... }` valida automaticamente que todos os métodos exigidos por `IExample` existem na classe (ou na sua super).

Exemplo

```lua
-- declara interfaces
interface('IPrintable', {
    ['toString'] = 'function',
})

-- declara e valida na criação
class 'Person' :implements 'IPrintable' {
    constructor = function(self, name)
        self.name = name
        return self
    end;

    toString = function(self)
        return 'Person: ' .. tostring(self.name)
    end;
};

local Person = new 'Person' ('Ana')
print(Person:toString()) -- Person: Ana
```

## API de Referência
- `class(name)`
  - Cria (ou retorna) um “builder” para definir a classe `name`.
  - Formas de uso:
    - `class 'Nome' { ... }`
        - `class 'Filha' :extends 'Base' { ... }`
        - `class 'Filha' :implements 'IExample' { ... }` (valida contrato)
        - `class 'Filha' :extends 'Base' :implements 'I1' { ... }` (herança + interfaces)

- `new(name)`
  - Retorna uma função que executa o `constructor` (se existir) e retorna a própria tabela da classe.
  - Uso recomendado: `local Nome = new 'Nome' (args...)`

- `bind(func, self)`
  - Devolve uma função que chama `func(self, ...)`.

- `interface(name, methods)`
    - Registra uma interface (contrato) com uma lista de métodos obrigatórios: `interface('IName', { 'm1', 'm2' })`.

## Dicas e Boas Práticas
- Prefira `local Class = new 'Class' (...)` para evitar poluir o escopo global do seu script.
- Mantenha métodos coesos: retorne `self` quando fizer sentido encadear operações.
- Para herança, reutilize campos da base conforme necessário. Se quiser um helper `super`, você pode adicionar um método utilitário no seu projeto para padronizar a chamada do construtor da base.

## Contribuição
Sugestões e PRs são bem-vindos! Abra uma issue descrevendo sua ideia ou envie diretamente uma melhoria.

## Licença
MIT License.

## Créditos
- Lead Developer: Thigas Development (draconzx)