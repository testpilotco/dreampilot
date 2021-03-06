class DreamPilot.Parser
    self = @

    constructor: ->

    @quotes: '\'"`'
    @operators:
        binary:
            '+': (a, b) -> a + b
            '-': (a, b) -> a - b
            '*': (a, b) -> a * b
            '/': (a, b) -> a / b
            '%': (a, b) -> a % b
            '>': (a, b) -> a > b
            '>=': (a, b) -> a >= b
            '<': (a, b) -> a < b
            '<=': (a, b) -> a <= b
            '==': (a, b) -> `a == b` or (not a and not b)
            '===': (a, b) -> a is b
            '!==': (a, b) -> a isnt b
            '!=': (a, b) -> `a != b`
            'in': (a, b) -> a in b
            'not in': (a, b) -> a not in b
        unary:
            '-': (a) -> -a
            '+': (a) -> -a
            '!': (a) -> !a
        logical:
            '&&': (a, b) -> a and b
            '||': (a, b) -> a or b

    @lastUsedVariables: []
    @lastUsedObjects: []
    @lastErrors: []
    @lastScopes: []

    @SCOPE_IS_UNDEFINED = 1
    @MEMBER_OBJECT_IS_UNDEFINED = 2
    @MEMBER_OBJECT_NOT_A_MODEL = 3

    @object: (dataStr, options = {}) ->
        options = $dp.fn.extend
            delimiter: ','
            assign: ':'
            curlyBracketsNeeded: true
        , options

        dataStr = $dp.fn.trim dataStr
        if options.curlyBracketsNeeded
            return null if dataStr[0] isnt '{' or dataStr.slice(-1) isnt '}'
            dataStr = dataStr.slice 1, dataStr.length - 1

        o = {}
        pair =
            key: ''
            value: ''
        addPair = ->
            pair.key = $dp.fn.trim pair.key
            if pair.key.charAt(0) in self.quotes and pair.key.charAt(0) is pair.key.charAt(pair.key.length - 1)
                pair.key = pair.key.substr 1, pair.key.length - 2
            o[pair.key] = pair.value #$dp.fn.trim
            pair.key = pair.value = ''
        quoteOpened = null
        underCursor = 'key'

        for ch, i in dataStr
            skip = false
            isSpace = /\s/.test ch
            isQuote = ch in self.quotes

            if isQuote
                unless quoteOpened
                    quoteOpened = ch
                    #skip = true
                else if quoteOpened and ch is quoteOpened
                    quoteOpened = null
                    #skip = true
                #console.log 'opened', quoteOpened

            if underCursor is 'border' and not isSpace
                underCursor = 'value'
            else if not quoteOpened
                if ch is options.assign
                    underCursor = 'border'
                #else if underCursor is 'key' and isSpace
                #    skip = true
                else if ch is options.delimiter
                    underCursor = 'key'
                    addPair()
                    skip = true

            pair[underCursor] += ch if underCursor in ['key', 'value'] and not skip

        addPair() if pair.key or pair.value
        o

    @evalNode: (node, Scope, element = null, promiseCallback = null) ->
        # console.log 'evalNode', node, Scope, element
        scopeSuitableType = Scope instanceof DreamPilot.Model or Scope instanceof DreamPilot.Collection
        unless scopeSuitableType or node.type in ['Literal', 'ThisExpression']
            unless Scope
                self.addToLastErrors self.SCOPE_IS_UNDEFINED
                promiseCallback() if promiseCallback
                return false
            throw "Scope should be a DreamPilot.Model/Collection instance, but #{$dp.fn.getType(Scope)} given: '#{Scope}'"
        #if $dp.fn.getType(Scope) isnt 'object'
        #    throw 'Scope should be an object, but ' + $dp.fn.getType(Scope) + " given: #{$dp.fn.print_r(Scope)}"
        @addToLastScopes Scope if Scope instanceof DreamPilot.Model and not Scope.isMainScope()
        switch node.type
            when 'CallExpression'
                if node.callee.type? and node.callee.type is 'Identifier' and node.callee.name
                    args = (self.evalNode arg, Scope, element, promiseCallback for arg in node.arguments)
                    fn = Scope.get node.callee.name
                    if fn and typeof fn is 'function'
                        fn args...
                    else
                        fn = Scope[node.callee.name]
                        if fn and typeof fn is 'function'
                            Scope[node.callee.name] args...
                        else
                            $dp.log.error "No function '#{node.callee.name}' found in scope"
                else
                    throw 'Unable to call node, type: ' + node.callee.type + ', name: ' + node.callee.name
            when 'BinaryExpression'
                if typeof self.operators.binary[node.operator] is 'undefined'
                    throw 'No callback for binary operator ' + node.operator
                self.operators.binary[node.operator] self.evalNode(node.left, Scope, element, promiseCallback), self.evalNode(node.right, Scope, element, promiseCallback)
            when 'UnaryExpression'
                if typeof self.operators.unary[node.operator] is 'undefined'
                    throw 'No callback for unary operator ' + node.operator
                self.operators.unary[node.operator] self.evalNode(node.argument, Scope, element, promiseCallback)
            when 'LogicalExpression'
                if typeof self.operators.logical[node.operator] is 'undefined'
                    throw 'No callback for logical operator ' + node.operator
                self.operators.logical[node.operator] self.evalNode(node.left, Scope, element, promiseCallback), self.evalNode(node.right, Scope, element, promiseCallback)
            when 'MemberExpression'
                #console.log '[1]', node.object
                if node.property.type is 'Literal'
                    node.property.type = 'Identifier'
                    node.property.name = node.property.value
                obj = self.evalNode node.object, Scope, element, promiseCallback
                #console.log '[2]', obj, node, Scope
                #console.log 'MemberExpression obj', obj, 'property', node.property, 'object', node.object, 'scope', Scope
                #console.log '[2.2] Collection got', obj if obj instanceof DreamPilot.Collection
                if obj instanceof DreamPilot.Model or obj instanceof DreamPilot.Collection
                    self.addToLastUsedObjects obj, node.property.name if obj instanceof DreamPilot.Model and not obj.isMainScope()
                    #console.log '[2.3]', self.getLastUsedObjects()
                else
                    #console.log '[2.5]', obj, node, Scope
                    self.addToLastErrors if obj then self.MEMBER_OBJECT_NOT_A_MODEL else self.MEMBER_OBJECT_IS_UNDEFINED
                    promiseCallback() if promiseCallback
                    # todo: fields of objects get listed here
                    self.addToLastUsedVariables node.object.name
                    #self.addToLastUsedVariables [node.object.name, node.property.name]
                    return null
                self.evalNode node.property, obj, element, promiseCallback
            when 'Identifier'
                switch node.name
                    when '$event'
                        element.dpEvent
                    else
                        # adding to last used variables only when working with the main scope
                        self.addToLastUsedVariables node.name if Scope.isMainScope and Scope.isMainScope()
                        if scopeSuitableType
                            Scope.get node.name
                        else
                            if Scope[node.name]? then Scope[node.name] else null
            #when 'Literal' then node.value
            when 'Literal'
                #if Scope then Scope.get(node.value) or node.value else null
                if Scope then node.value else null
            when 'ArrayExpression'
                node.elements.map (el) => self.evalNode el, Scope, element, promiseCallback
            when 'ThisExpression' then element
            else throw 'Unknown node type ' + node.type

    @getExpressionNamespace: (node, useLast = false) ->
        namespace = []
        while true
            namespace.push node.name or node.property.name or node.property.value
            break unless node = node.object
        $dp.fn.arrayReverse namespace.slice if useLast then 0 else 1

    @getScopeOf: (expr, Scope) ->
        node = jsep expr
        useLast = false
        if node.type is 'CallExpression' and node.callee?.object?
            node = node.callee.object
            useLast = true
        else if node.type isnt 'MemberExpression'
            return Scope

        namespace = self.getExpressionNamespace node, useLast
        for key in namespace
            Scope = Scope.get key
            break unless Scope
        Scope

    @getPropertyOfExpression: (expr) ->
        node = jsep expr
        if node.type is 'MemberExpression'
            node.property.name
        else if node.type is 'CallExpression' and node.callee?.property?.name?
            arguments: node.arguments
            callee: node.callee.property
            type: node.type
        else
            expr

    @isExpressionTrue: (expr, App, element = App.getActiveElement(), promiseCallback = null) ->
        try
            self.resetRecentData()
            !! self.evalNode jsep(expr), App.getScope(), element, promiseCallback
        catch e
            $dp.log.error 'Expression parsing (isExpressionTrue) error ', e, ' Full expression:', expr
            false

    @executeExpressions: (allExpr, App, element = App.getActiveElement(), event = null) ->
        rows = @object allExpr,
            delimiter: ';'
            assign: '='
            curlyBracketsNeeded: false
        self.resetRecentData()
        element.dpEvent = event
        for key, expr of rows
            try
                if key.indexOf('(') > -1 and expr is ''
                    Scope = $dp.Parser.getScopeOf key, App.getScope()
                    method = $dp.Parser.getPropertyOfExpression key
                    method = jsep method if $dp.fn.getType(method) is 'string'
                    self.evalNode method, Scope, element
                else
                    keyScope = $dp.Parser.getScopeOf key, App.getScope()
                    keyMethod = $dp.Parser.getPropertyOfExpression key
                    #keyMethod = jsep keyMethod if $dp.fn.getType(keyMethod) is 'string'
                    #console.log 'keyScope', keyScope, 'keyMethod', keyMethod

                    Scope = $dp.Parser.getScopeOf expr, App.getScope()
                    method = $dp.Parser.getPropertyOfExpression expr
                    method = jsep method if $dp.fn.getType(method) is 'string'
                    keyScope.set keyMethod, self.evalNode method, Scope, element
            catch e
                throw e
                $dp.log.error 'Expression parsing (executeExpressions) error', e, ':', key, expr
                false
        true

    @resetRecentData: ->
        self.resetLastUsedVariables()
        self.resetLastUsedObjects()
        self.resetLastErrors()
        self.resetLastScopes()

    @resetLastUsedVariables: -> self.lastUsedVariables = []
    @inLastUsedVariables: (key) -> self.lastUsedVariables.indexOf(key) isnt -1
    @getLastUsedVariables: -> self.lastUsedVariables
    @addToLastUsedVariables: (key) -> self.lastUsedVariables.push key if key and not self.inLastUsedVariables key
    @eachLastUsedVariables: (callback) -> callback field for field in self.lastUsedVariables

    @resetLastUsedObjects: -> self.lastUsedObjects = []
    @inLastUsedObjects: (object, field) ->
        for row in self.lastUsedObjects
            return true if row.object is object and row.field is field
        false
    @getLastUsedObjects: -> self.lastUsedObjects
    @addToLastUsedObjects: (object, field) -> self.lastUsedObjects.push object: object, field: field if object and field and not self.inLastUsedObjects object, field
    @eachLastUsedObjects: (callback) -> callback row.object, row.field for row in self.lastUsedObjects

    @resetLastErrors: -> self.lastErrors = []
    @getLastErrors: -> self.lastErrors
    @hasLastErrors: -> self.lastErrors.length > 0
    @addToLastErrors: (error) -> self.lastErrors.push error

    @resetLastScopes: -> self.lastScopes = []
    @getLastScopes: -> self.lastScopes
    @hasLastScopes: -> self.lastScopes.length > 0
    @addToLastScopes: (scope) -> self.lastScopes.push scope
