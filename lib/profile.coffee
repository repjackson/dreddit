if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'account_dashboard'
        ), name:'account_dashboard'
    Router.route '/user/:username/events', (->
        @layout 'layout'
        @render 'user_events'
        ), name:'user_events'
            
    Template.user_models.onCreated ->
        @autorun => Meteor.subscribe 'user_model_docs',@data.key,->
    Template.user_models.helpers
        user_model_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            # if user
            Docs.find 
                model:@key
                unit_number:user.unit_number 
                building_number:user.building_number
                
            
if Meteor.isServer
    Meteor.methods
        mark_unread_logs_read: ->
            Docs.update({
                model:'log'
                read_user_ids:$nin:[Meteor.userId()]
            },{
                $addToSet:
                    read_user_ids:Meteor.userId()
            },{multi:true})
            
if Meteor.isClient
    Template.user_inbox.helpers
        user_unread_log_docs: ->
            Docs.find 
                model:'log'
                
            
    
    Template.user_checkins.onCreated ->
        @autorun => @subscribe 'user_checkins', Router.current().params.username, ->
    Template.user_checkins.helpers 
        user_checkin_docs: ->
            Docs.find {
                model:'checkin'
                resident_username:Router.current().params.username
            }, sort:_timestamp:-1
    Template.profile_layout.onCreated ->
        Meteor.call 'calc_user_stats', Router.current().params.username, ->
        Meteor.call 'calc_user_points', Router.current().params.username, ->
if Meteor.isServer 
    Meteor.publish 'user_checkins', (username)->
        user = Meteor.users.findOne username:username
        if user 
            Docs.find {
                model:'checkin'
                resident_user_id:user._id
            }, 
                sort:_timestamp:-1
                limit:10
if Meteor.isClient
    Template.profile_layout.onRendered ->
        document.title = "profile";
        Meteor.call 'increment_profile_view', Router.current().params.username, ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
    # Template.profile_layout.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1000
        
        
                
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
            $('.avatar').popup()
        , 2000
    # Template.nav.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.item').popup()
    #     , 1000

    Template.profile_layout.events

    Template.profile_layout.helpers
        my_unread_log_docs: ->
            Docs.find 
                model:'log'
                read_user_ids:$nin:[Meteor.userId()]
        user_unread_log_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'log'
                read_user_ids:$nin:[user._id]
        current_viewing_doc: ->
            if Meteor.user().current_viewing_doc_id
                Docs.findOne Meteor.user().current_viewing_doc_id


    Template.logout_button.events
        'click .logout': (e,t)->
            # Meteor.call 'insert_log', 'logout', Session.get('current_userid'), ->
                
            Router.go '/login'
            $(e.currentTarget).closest('.grid').transition('zoom', 1000)
            
            Meteor.logout()
            $('body').toast({
                title: "logged out"
                # message: 'Please see desk staff for key.'
                class : 'success'
                position:'bottom center'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
                
            
if Meteor.isServer
    Meteor.publish 'current_viewing_doc', (username)->
        user = Meteor.users.findOne username:username
        if user.current_viewing_doc_id
            Docs.find 
                _id:user.current_viewing_doc_id
    Meteor.publish 'user_groups_member', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'group'
            member_ids:$in:[user._id]
        },
            limit:10
            # fields:
            #     title:1
            #     model:1
            #     image_id:1
            #     member_ids:1
            #     points:1
            #     tags:1
            #     _author:1
            
    Meteor.publish 'user_model_docs', (model,username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:model
            # _author_id:user._id
            # published:true
            building_number:user.building_number
            unit_number:user.unit_number
        }, 
            limit:20
            sort:
                _timestamp:-1
            # fields:
            #     title:1
            #     model:1
            #     image_id:1
            #     _author_id:1
            #     points:1
            #     views:1
            #     _timestamp:-1
            #     tags:1
    Meteor.publish 'user_from_username_param', (username)->
        Meteor.users.find 
            username:username

if Meteor.isClient
    Template.profile_layout.onCreated ->
        @autorun => Meteor.subscribe 'me', ->
        @autorun => Meteor.subscribe 'user_deposts', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_from_username_param', Router.current().params.username, ->

    Template.profile_layout.helpers
        owner_earnings: ->
            Docs.find
                model:'order'
                owner_username:Router.current().params.username
                complete:true
if Meteor.isClient
    Template.user_single_doc_ref_editor.onCreated ->
        @autorun => Meteor.subscribe 'type', @data.model

    Template.user_single_doc_ref_editor.events
        'click .select_choice': ->
            context = Template.currentData()
            current_user = Meteor.users.findOne Router.current().params._id
            Meteor.users.update current_user._id,
                $set: "#{context.key}": @slug

    Template.user_single_doc_ref_editor.helpers
        choices: ->
            Docs.find
                model:@model

        choice_class: ->
            context = Template.parentData()
            current_user = Meteor.users.findOne Router.current().params._id
            if current_user["#{context.key}"] and @slug is current_user["#{context.key}"] then 'grey' else ''



    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            if new_username
                if confirm "change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/user/#{new_username}")




    Template.password_edit.events
        # 'click .change_password': (e, t) ->
        #     Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
        #         if err
        #             alert err.reason
        #         else
        #             alert 'password changed'
        #             # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'set_password', current_user._id, new_password, (err,res)->
                if err 
                    alert err
                else if res
                    alert "password set to #{new_password}"
                    console.lgo 'res', res
                    
if Meteor.isClient
    Router.route '/user/:user_id/edit', (->
        @layout 'layout'
        @render 'account'
        ), name:'account'

    Template.account.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_id', Router.current().params.user_id

    Template.account.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
    
    Template.account.helpers
        user_from_user_id_param: ->
            Meteor.users.findOne Router.current().params.user_id
    Template.account.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/users"
    Template.user_sessions.events
        'click .signout_others': ->
            Meteor.logoutOtherClients ->
                alert 'signed out'
        'click .clear_session': (e)->
            user = Meteor.users.findOne username:Router.current().params.username
            $(e.currentTarget).closest('.item').transition('fly left', 500)
            Meteor.setTimeout =>
                Meteor.users.update Meteor.userId(),
                    $pull:
                        "services.resume.loginTokens":@
            , 500
    Template.account.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000