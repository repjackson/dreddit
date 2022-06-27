if Meteor.isClient
    Router.route '/search/', (->
        @layout 'layout'
        @render 'search'
        ), name:'search'

    Template.search.onCreated ->
        @autorun => Meteor.subscribe 'global_search', Session.get('global_search'), ->


    Template.search.helpers
        current_search: ->
            Session.get('global_search')
            
        search_results: ->
            search = Session.get('global_search')
            Docs.find 
                title: {$regex:Session.get('global_search'), $options: 'i'}

                
                
    Template.search.events
        'keyup .search_input': ->
            val = $('.search_input').val().trim().toLowerCase()
            if val.length > 2
                Session.set('search_input',val)
                Meteor.setTimeout ->
                    count = Docs.find(
                        title: {$regex:"#{val}", $options: 'i'}
                    ).count()
                    if count is 1
                        result = Docs.findOne(
                            title: {$regex:"#{val}", $options: 'i'}
                        )
                        Router.go "/doc/#{result._id}"
                
        
if Meteor.isServer
    Meteor.publish 'global_search', (search)->
        if search and search.length > 0
            Docs.find(
                {
                    model:$in:['service','product','event','group']
                    title: {$regex:"#{search}", $options: 'i'}
                    # group_id:Meteor.user().current_group_id
                }, limit:20
            )
        
        