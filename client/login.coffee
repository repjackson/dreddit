if Meteor.isClient
    Template.login.onCreated ->
        Session.setDefault 'username', ''
        Session.setDefault 'password', ''

    Template.login.events
        'keyup .username': ->
            username = $('.username').val().trim()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set('enter_mode', 'login')

        'blur .username': ->
            username = $('.username').val().trim()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set('enter_mode', 'login')

        'click .enter': (e,t)->
            # e.preventDefault()
            username = $('.username').val().trim()
            password = $('#pass').val()
            Meteor.loginWithPassword username, password, (err,res)=>
                if err
                    $('body').toast({
                        message: err.reason
                    })
                else
                    # Router.go "/user/#{username}"
                    $(e.currentTarget).closest('.grid').transition('zoom', 500)
                    Meteor.setTimeout ->
                        # Router.go "/user/#{username}"
                        Router.go "/"
                    , 500
                    $('body').toast({
                        title: "logged in"
                        # message: 'Please see desk staff for key.'
                        class : 'success'
                        position:'bottom right'
                        # className:
                        #     toast: 'ui massive message'
                        # displayTime: 5000
                        transition:
                          showMethod   : 'zoom',
                          showDuration : 250,
                          hideMethod   : 'fade',
                          hideDuration : 250
                        })



        'keyup #pass, keyup .username': (e,t)->
            if e.which is 13
                e.preventDefault()
                username = $('.username').val().trim()
                password = $('#pass').val()
                if username and username.length > 0 and password and password.length > 0
                    Meteor.loginWithPassword username, password, (err,res)=>
                        if err
                            $('body').toast({
                                message: err.reason
                            })
                        else
                            # Router.go "/user/#{username}"
                            Router.go "/"


    Template.login.helpers
        username: -> Session.get 'username'
        logging_in: -> Session.equals 'enter_mode', 'login'
        enter_class: ->
            if Session.get('username').length
                if Meteor.loggingIn() then 'loading disabled' else ''
            else
                'disabled'
        is_logging_in: -> Meteor.loggingIn()



if Meteor.isClient
    Router.route '/register', (->
        @layout 'layout'
        @render 'register'
        ), name:'register'



    Template.register.onCreated ->
        Session.setDefault 'username', ''
        Session.setDefault 'password', ''
        
    Template.register.events
        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'

        'blur .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'
        
        'blur #pass': ->
            password = $('#pass').val()
            Session.set 'password', password

        'click .register': (e,t)->
            username = $('.username').val()
            password = $('#pass').val()
            # if Session.equals 'enter_mode', 'register'
            # if confirm "register #{username}?"
            # Meteor.call 'validate_email', email, (err,res)->
            # options = {
            #     username:username
            #     password:password
            # }
            options = {
                username:username
                password:password
                }
            Meteor.call 'create_user', options, (err,res)=>
                if err
                    alert err
                else
                    Meteor.loginWithPassword username, password, (err,res)=>
                        if err
                            alert err.reason
                            # if err.error is 403
                            #     Session.set 'message', "#{username} not found"
                            #     Session.set 'enter_mode', 'register'
                            #     Session.set 'username', "#{username}"
                        else
                            Router.go '/'
                            # Router.go "/user/#{username}"
                # else
                #     Meteor.loginWithPassword username, password, (err,res)=>
                #         if err
                #             if err.error is 403
                #                 Session.set 'message', "#{username} not found"
                #                 Session.set 'enter_mode', 'register'
                #                 Session.set 'username', "#{username}"
                #         else
                #             Router.go '/'


    Template.register.helpers
        can_register: ->
            true
            # # Session.get('first_name') and Session.get('last_name') and Session.get('email_status', 'valid') and Session.get('password').length>3
            # Session.get('username') and Session.get('password').length>3

            # # Session.get('username')

        # email: -> Session.get 'email'
        username: -> Session.get 'username'
        # first_name: -> Session.get 'first_name'
        # last_name: -> Session.get 'last_name'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
        # email_valid: ->
        #     Session.equals 'email_status', 'valid'
        # email_invalid: ->
        #     Session.equals 'email_status', 'invalid'

if Meteor.isServer
    Meteor.methods
        set_user_password: (user, password)->
            result = Accounts.setPassword(user._id, password)
            result

        # verify_email: (email)->
        #     (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email))


        create_user: (options)->
            Accounts.createUser options

        find_username: (username)->
            res = Accounts.findUserByUsername(username)
            if res
                unless res.disabled
                    return res

        new_demo_user: ->
            current_user_count = Meteor.users.find().count()

            options = {
                username:"user#{current_user_count}"
                password:"user#{current_user_count}"
                }

            create = Accounts.createUser options
            new_user = Meteor.users.findOne create
            return new_user