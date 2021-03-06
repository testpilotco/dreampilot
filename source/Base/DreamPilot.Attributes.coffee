class DreamPilot.Attributes
    self = @

    @classAttr = 'class'
    @showAttr = 'show'
    @ifAttr = 'if'
    @initAttr = 'init'
    @hrefAttr = 'href'
    @srcAttr = 'src'
    @altAttr = 'alt'
    @titleAttr = 'title'
    @disabledAttr = 'disabled'
    @readOnlyAttr = 'readonly'
    @requiredAttr = 'required'
    @valueWriteToAttr = 'value-write-to'
    @valueReadFromAttr = 'value-read-from'
    @valueBindAttr = 'value-bind'

    @simpleAttributes = [
        self.hrefAttr
        self.srcAttr
        self.altAttr
        self.titleAttr
    ]
    @stateAttributes = [
        self.disabledAttr
        self.readOnlyAttr
        self.requiredAttr
    ]

    ScopePromises: null

    constructor: (@App) ->
        @setupScopePromises()
        .setupAttributes()

    setupScopePromises: ->
        @ScopePromises = new DreamPilot.ScopePromises()
        @

    setupAttributes: ($element = null) ->
        @setupInitAttribute $element
        .setupClassAttribute $element
        .setupShowAttribute $element
        .setupIfAttribute $element
        .setupValueBindAttribute $element
        .setupValueWriteToAttribute $element
        .setupValueReadFromAttribute $element
        .setupSimpleAttributes $element
        .setupStateAttributes $element

    getApp: -> @App
    getScope: -> @getApp().getScope()
    getWrapper: -> @getApp().getWrapper()

    eachByAttr: (attr, $element = null, callback = null) ->
        $elements = $dp.e $dp.selectorForAttribute(attr), $element or @getWrapper()
        $elements = $elements.add $element.filter $dp.selectorForAttribute(attr) if $element
        $elements.each callback
        @

    setupClassAttribute: ($element = null) ->
        that = @

        @eachByAttr self.classAttr, $element, ->
            el = @
            $el = $dp.e el
            obj = $dp.Parser.object $el.attr $dp.attribute self.classAttr

            #console.log '1)', obj

            # todo: keep parsed expressions as closures connected to elements
            for cssClass, expression of obj
                do (cssClass, expression) =>
                    $el.toggleClass cssClass, $dp.Parser.isExpressionTrue expression, that.getApp(), el, =>
                        that.classAddPromise cssClass, expression, el

                    #console.log '2) ', $dp.Parser.getLastUsedVariables(), $dp.Parser.getLastUsedObjects()

                    # setting up watchers
                    for field in $dp.Parser.getLastUsedVariables()
                        that.getScope().onChange field, (field, value) ->
                            #console.log expression, 'changed CLASS: ', field, '=', value, ':', cssClass
                            $el.toggleClass cssClass, $dp.Parser.isExpressionTrue expression, that.getApp(), el

                    $dp.Parser.eachLastUsedObjects (object, field) ->
                        #console.log '2) objects: ', object, field
                        object.onChange field, (field, value) ->
                            #console.log expression, 'changed CLASS #2: ', field, '=', value, ':', cssClass
                            $el.toggleClass cssClass, $dp.Parser.isExpressionTrue expression, that.getApp(), el

            true

        @

    classAddPromise: (cssClass, expression, el) ->
        @ScopePromises.add
            expression: expression
            app: @getApp()
            scope: @getScope()
            element: el
            cb: (App, Scopes, vars) =>
                #console.log 'classAddPromise', Scopes, vars
                for i in [vars.length - 1..0]
                    for j in [Scopes.length - 1..0]
                        if true #Scopes[j].exists vars[i]
                            Scopes[j].onChange vars[i], (field, value) ->
                                $el = $dp.e el
                                $el.toggleClass cssClass, $dp.Parser.isExpressionTrue expression, App, el
                            #break
                # console.log 'we got', cssClass, expression
        @

    setupShowAttribute: ($element = null) ->
        that = @

        @eachByAttr self.showAttr, $element, ->
            el = @
            $el = $dp.e el
            expression = $el.attr $dp.attribute self.showAttr

            $el.toggle $dp.Parser.isExpressionTrue expression, that.getApp(), el, =>
                that.showAddPromise expression, el

            # setting up watchers
            $dp.Parser.eachLastUsedVariables (field) ->
                that.getScope().onChange field, (field, value) ->
                    # console.log 'changed SHOW: ', field, '=', value
                    $el.toggle $dp.Parser.isExpressionTrue expression, that.getApp(), el

            $dp.Parser.eachLastUsedObjects (object, field) ->
                object.onChange field, (field, value) ->
                    $el.toggle $dp.Parser.isExpressionTrue expression, that.getApp(), el

            true

        @

    showAddPromise: (expression, el) ->
        @ScopePromises.add
            expression: expression
            app: @getApp()
            scope: @getScope()
            element: el
            cb: (App, Scopes, vars) =>
                for i in [vars.length - 1..0]
                    for j in [Scopes.length - 1..0]
                        if true #Scopes[j].exists vars[i]
                            Scopes[j].onChange vars[i], (field, value) ->
                                $el = $dp.e el
                                $el.toggle $dp.Parser.isExpressionTrue expression, App, el
                            #break
                # console.log 'we got', expression
        @

    getReplacerFor: ($element, expression) ->
        return $element.data 'replacer' if $element.data 'replacer'

        $replacer = $ "<!-- dp-if: #{expression} --><script type='text/placeholder'></script><!-- end of dp-if: #{expression} -->"
        $element.data 'replacer', $replacer

        $replacer

    toggleElementExistence: ($element, state, expression) ->
        if state
            unless document.body.contains $element.get 0
                $anchor = @getReplacerFor($element, expression).filter 'script'
                $element.insertAfter $anchor
        else
            $element
            .after @getReplacerFor $element, expression
            .detach()
        @

    toggleAttribute: ($element, attribute, state, expression) ->
        if state
            $element.attr attribute, state if $element.attr(attribute) isnt state
        else
            $element.removeAttr attribute
        @

    setupIfAttribute: ($element = null) ->
        that = @

        @eachByAttr self.ifAttr, $element, ->
            el = @
            $el = $dp.e el
            expression = $el.attr $dp.attribute self.ifAttr

            that.toggleElementExistence $el, $dp.Parser.isExpressionTrue(expression, that.getApp(), el), expression, =>
                that.ifAddPromise expression, el

            # setting up watchers
            for field in $dp.Parser.getLastUsedVariables()
                that.getScope().onChange field, (field, value) ->
                    # console.log 'changed IF: ', field, '=', value, expression
                    that.toggleElementExistence $el, $dp.Parser.isExpressionTrue(expression, that.getApp(), el), expression

            $dp.Parser.eachLastUsedObjects (object, field) ->
                object.onChange field, (field, value) ->
                    that.toggleElementExistence $el, $dp.Parser.isExpressionTrue(expression, that.getApp(), el), expression

            true

        @

    ifAddPromise: (expression, el) ->
        that = @

        @ScopePromises.add
            expression: expression
            app: @getApp()
            scope: @getScope()
            element: el
            cb: (App, Scopes, vars) =>
                for i in [vars.length - 1..0]
                    for j in [Scopes.length - 1..0]
                        if true #Scopes[j].exists vars[i]
                            Scopes[j].onChange vars[i], (field, value) ->
                                $el = $dp.e el
                                that.toggleElementExistence $el, $dp.Parser.isExpressionTrue(expression, App, el), expression
                            #break
        @

    setupInitAttribute: ($element = null) ->
        that = @
        @eachByAttr self.initAttr, $element, ->
            el = @
            $el = $dp.e el
            expression = $el.attr $dp.attribute self.initAttr
            $dp.Parser.executeExpressions expression, that, el
            true
        @

    setupValueWriteToAttribute: ($element = null) ->
        that = @
        @eachByAttr self.valueWriteToAttr, $element, ->
            $el = $dp.e @
            expr = $el.attr $dp.attribute self.valueWriteToAttr
            Scope = $dp.Parser.getScopeOf expr, that.getScope()
            field = $dp.Parser.getPropertyOfExpression expr
            return true if self.bindValueCheckScope expr, $el, Scope, that, false, true
            self.bindValueWriteToAttribute field, $el, Scope
        @

    setupValueReadFromAttribute: ($element = null) ->
        that = @
        @eachByAttr self.valueReadFromAttr, $element, ->
            $el = $dp.e @
            expr = $el.attr $dp.attribute self.valueReadFromAttr
            Scope = $dp.Parser.getScopeOf expr, that.getScope()
            field = $dp.Parser.getPropertyOfExpression expr
            return true if self.bindValueCheckScope expr, $el, Scope, that, true, false
            self.bindValueReadFromAttribute field, $el, Scope
        @

    setupValueBindAttribute: ($element = null) ->
        that = @
        @eachByAttr self.valueBindAttr, $element, ->
            $el = $dp.e @
            expr = $el.attr $dp.attribute self.valueBindAttr
            Scope = $dp.Parser.getScopeOf expr, that.getScope()
            field = $dp.Parser.getPropertyOfExpression expr
            return true if self.bindValueCheckScope expr, $el, Scope, that, true, true
            self.bindValueWriteToAttribute field, $el, Scope
            self.bindValueReadFromAttribute field, $el, Scope
        @

    @bindValueCheckScope: (field, $el, Scope, that, read = false, write = false) ->
        if Scope is null
            that.ScopePromises.add
                field: field
                scope: that.getScope()
                cb: (_scope) ->
                    field = $dp.Parser.getPropertyOfExpression field
                    self.bindValueWriteToAttribute field, $el, _scope if write
                    self.bindValueReadFromAttribute field, $el, _scope if read

            return true
        false

    @bindValueWriteToAttribute: (field, $el, Scope) ->
        if $el.is('input') and $el.attr('type') in ['radio', 'checkbox']
            eventName = 'change'
        else
            eventName = 'input'
        $el.on eventName, ->
            value = $dp.fn.getValueOfElement $el
            Scope.set field, value
        $el.trigger eventName if $dp.fn.getValueOfElement $el
        true

    @bindValueReadFromAttribute: (field, $el, Scope) ->
        Scope.onChange field, (field, value) ->
            $dp.fn.setValueOfElement $el, value if $dp.fn.getValueOfElement($el) isnt value
        Scope.trigger 'change', field if Scope.get field
        true

    setupSimpleAttributes: ($element = null) ->
        that = @
        jQuery.each self.simpleAttributes, (idx, attrName) =>
            @eachByAttr attrName, $element, ->
                $el = $dp.e @
                expr = $el.attr $dp.attribute attrName
                Scope = $dp.Parser.getScopeOf expr, that.getScope()
                field = $dp.Parser.getPropertyOfExpression expr
                return true if self.bindAttributeCheckScope attrName, expr, $el, Scope, that
                self.bindAttribute attrName, field, $el, Scope
        @

    setupStateAttributes: ($element = null) ->
        that = @

        jQuery.each self.stateAttributes, (idx, attrName) =>
            @eachByAttr attrName, $element, ->
                el = @
                $el = $dp.e el
                expression = $el.attr $dp.attribute attrName
                state = $dp.Parser.isExpressionTrue(expression, that.getApp(), el)

                # setting up watchers
                for field in $dp.Parser.getLastUsedVariables()
                    that.getScope().onChange field, (field, value) ->
                        that.toggleAttribute $el, attrName, $dp.Parser.isExpressionTrue(expression, that.getApp(), el), expression

                $dp.Parser.eachLastUsedObjects (object, field) ->
                    object.onChange field, (field, value) ->
                        that.toggleAttribute $el, attrName, $dp.Parser.isExpressionTrue(expression, that.getApp(), el), expression

                true

        jQuery.each self.stateAttributes, (idx, attrName) =>
            @eachByAttr attrName, $element, ->
                $el = $dp.e @
                expr = $el.attr $dp.attribute attrName
                Scope = $dp.Parser.getScopeOf expr, that.getScope()
                field = $dp.Parser.getPropertyOfExpression expr
                return true if self.bindAttributeCheckScope attrName, expr, $el, Scope, that
                self.bindAttribute attrName, field, $el, Scope, true
        @

    @bindAttributeCheckScope: (attrName, field, $el, Scope, that) ->
        if Scope is null
            that.ScopePromises.add
                field: field
                scope: that.getScope()
                cb: (_scope) ->
                    field = $dp.Parser.getPropertyOfExpression field
                    self.bindAttribute attrName, field, $el, _scope
            return true
        false

    @bindAttribute: (attribute, field, $el, Scope, isStateAttribute = false) ->
        Scope.onChange field, (field, value) ->
            if isStateAttribute and not value
                $el.removeAttr attribute
            else
                $el.attr attribute, value if $el.attr(attribute) isnt value
        Scope.trigger 'change', field if isStateAttribute or Scope.get field
        true
