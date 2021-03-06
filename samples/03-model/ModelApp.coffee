class ModelApp extends DreamPilot.Application
    init: ->
        @initModels()

    initModels: ->
        @ff = new DreamPilot.Model
            name: false
            email: false

        @cart = new CartModel()
        @cart.set
            of_user1: new CartItemModel id: 1, count: 2
            2: new CartItemModel id: 2
            3: new CartItemModel id: 3

        @user1 = new UserModel @e('ul[data-user1]').data 'user1'
        @user2 = new UserModel @e('script[data-of="user2"]').html()
        @user3 = new UserModel @user2
        @user3.set name: 'Lars Ulrich'

        @linkToScope 'user1', 'user2', 'user3', 'cart', 'formSubmit', 'ff', 'onFocus', 'onBlur', 'reset3'

        console.log '(init) user1.name = ', @getScope().get 'user1.name'

        @user1.onChange '*', (field, value) ->
            console.log 'user1.' + field, '=', value
        @

    reset3: ->
        @user3.kill()
        @

    formSubmit: (event) ->
        event.preventDefault()
        alert 'form submitted, login: ' + @getScope().get('formLogin') + ', checkbox: ' + @getScope().get('formCheckBox')

    onFocus: (field) ->
        @ff.set field, true
        @

    onBlur: (field) ->
        @ff.set field, false
        @
