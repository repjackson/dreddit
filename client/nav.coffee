Template.nav.helpers
    is_connected: -> 
        # console.log Meteor.status().connected
        Meteor.status().connected
    unread_count: ->
        Docs.find(
            model:'log'
            read_user_ids:$nin:[Meteor.userId()]
        ).count()
Template.nav_item.helpers
    nav_item_class: (model)->
        # console.log model
        if Router.current().params.model is model then 'active' else ''
        
        
Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
    , 3000
    Meteor.setTimeout ->
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_leftbar')
    , 4000
    Meteor.setTimeout ->
        $('.ui.rightbar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 3000
    Meteor.setTimeout ->
        $('.ui.topbar.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_topbar')
    , 2000
    
        
        
Template.rightbar.events
    'click .logout': (e,t)->
        Session.set('logging_out',true)
        $('body').toast({
            title: "logging out"
            # message: 'Please see desk staff for key.'
            class : 'black'
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
        Meteor.logout ->
            Session.set('logging_out',false)
            $('body').toast({
                title: "logged out"
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
            Router.go '/login'
            $('.ui.rightbar').sidebar('hide')
            
        # log_item = {
        #     type:'logout'
        #     body: "#{Meteor.user().username} logged out"
        #     }
        # Meteor.call 'create_log', log_item,->
            
        # $(e.currentTarget).closest('.grid').transition('slide left', 500)
        

Template.nav.events
    'keyup .global_search': ->
        val = $('.global_search').val()
        if val.length > 2
            Session.set('global_search',val)
            Router.go "/search"
    'click .refresh_gps': ->
        navigator.geolocation.getCurrentPosition (position) =>
            console.log 'navigator position', position
            Session.set('current_lat', position.coords.latitude)
            Session.set('current_long', position.coords.longitude)
            
            console.log 'saving long', position.coords.longitude
            console.log 'saving lat', position.coords.latitude
        
            pos = Geolocation.currentLocation()
            Docs.update Router.current().params.doc_id, 
                $set:
                    lat:position.coords.latitude
                    long:position.coords.longitude

    'click .reconnect': -> Meteor.reconnect()
    'click .clear_search': ->
        Session.set('current_search',null)
        picked_tags.clear()
        Session.set('limit',10)
    'click .add': ->
        new_id = Docs.insert {}
        Router.go "/doc/#{new_id}/edit"
    'mouseenter img': (e)->
        # console.log 'hi'
        $(e.currentTarget).closest('.image').addClass('spinning')
    'mouseleave img': (e)->
        # console.log 'hi'
        $(e.currentTarget).closest('.image').removeClass('spinning')
        
Template.nav_item.events 
    'click .go_route': -> 
        Session.set('model',@key)
        picked_tags.clear()
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me', ->
    # @autorun -> Meteor.subscribe 'all_users', ->
    # @autorun -> Meteor.subscribe 'model_docs','group', ->
    @autorun -> Meteor.subscribe 'unread_logs', ->


Template.nav.events
    'click .clear_read': ->
        $('.ui.toast').toast('close')
        Meteor.call 'mark_unread_logs_read', ->

    'click .add_doc': ->
        new_id = 
            Docs.insert {model:Session.get('model')}
        Router.go "/doc/#{new_id}/edit"
    'click .locate': ->
        navigator.geolocation.getCurrentPosition (position) =>
            console.log 'navigator position', position
            Session.set('current_lat', position.coords.latitude)
            Session.set('current_long', position.coords.longitude)

Template.nav.events
    'click .tada': (e,t)-> $(e.currentTarget).closest('.icon').transition('bounce', 1000)
Template.nav_item.events
    'click .tada': (e,t)-> $(e.currentTarget).closest('.icon').transition('bounce', 1000)
Template.layout.events
    'click .fly_down': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade down', 500)
    'click .fly_up': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade up', 500)
    'click .fly_left': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade left', 500)
    'click .fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .card_fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.card').transition('fade right', 500)
    'click .zoom': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .flip': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('flip', 500)
        
    # 'click a': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)


# Template.layout.helpers
#     usersOnline:()->
#         Meteor.users.find({ "status.online": true })

# Template.user_pill.helpers
#     labelClass:->
#         if @status.idle 
#             "yellow"
#         else if @status.online
#             "green"
#         else
#             ""

# Meteor.users.find({ "status.online": true }).observe({
#     added: (id)->
#         console.log id, 'just came online'
#     removed: (id)->
#         console.log id, 'just went offline'
# })


# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
Router.route '/', (->
    @layout 'layout'
    @render 'users'
    ), name:'home'
# Router.route '/', (->
#     @redirect('/');
#     ), name:'home'
Router.route '/docs', (->
    @redirect('/posts');
    ), name:'docs'

Router.route '/m/:model', (->
    @layout 'layout'
    @render 'docs'
    ), name:'model'


# Router.route '/docs', (->
#     @layout 'layout'
#     @render 'docs'
#     ), name:'docs'
    
