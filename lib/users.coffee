if Meteor.isClient
    Router.route '/users', -> @render 'users'
    @picked_porn_tags = new ReactiveArray []
    Template.user_item.onCreated ->
        @autorun => Meteor.subscribe 'user_groups_small', @data.username, -> 
        
        
    Router.route '/u/:name', (->
        @layout 'layout'
        @render 'redditor_view'
        ), name:'redditor_view'
        
    Template.redditor_view.onCreated ->
        @autorun => @subscribe 'redditor_by_name', Router.current().params.name, ->
    Template.redditor_view.helpers
        current_redditor: ->
            Docs.findOne 
                model:'redditor'
    Template.users.onCreated ->
        @autorun => Meteor.subscribe 'redditor_counter', ->
    Template.user_post_doc.events
        'click .call_watson_comment': ->
            Meteor.call 'call_watson', @_id, 'reddit_data.body', 'comment', ->
    Template.users.onCreated ->
        Session.set('view_friends', false)
        # @autorun -> Meteor.subscribe('users')
        Session.setDefault 'limit', 42
        Session.setDefault 'sort_key', 'points'
        Session.setDefault('view_mode','grid')
        @autorun => Meteor.subscribe 'redditors_pub',
            Session.get('current_search')
            picked_user_tags.array()
            picked_porn_tags.array()
            # Session.get('view_friends')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
            Session.get('dummy')
            ->
        @autorun => Meteor.subscribe 'redditor_tags', 
            picked_user_tags.array()
            picked_porn_tags.array()
            Session.get('dummy')
            , ->
        # @autorun => Meteor.subscribe 'users_pub', 
        #     Session.get('current_search')
        #     picked_user_tags.array()
        #     Session.get('view_friends')
        #     Session.get('sort_key')
        #     Session.get('sort_direction')
        #     Session.get('limit')
        #     ->
        # @autorun => Meteor.subscribe 'user_tags', picked_user_tags.array(), ->
     
    Template.redditor_card.events
        'click .calc_stats': ->
            Meteor.call 'calc_redditor_stats', @reddit_data.name, ->
            
            # unless @details 
            #     Meteor.call 'redditor_details', @_id, ->
            #         console.log 'pulled redditor details'
            unless @watson
                Meteor.call 'call_watson',@_id,'reddit_data.subreddit.public_description','redditor', ->
                    console.log 'autoran watson'
                    Session.set('dummy', !Session.get('dummy'))

        'click .flat_user_tag': ->
            # picked_user_tags.clear()
            picked_user_tags.push @valueOf()
            Meteor.call 'search_redditors', picked_user_tags.array(),true, ->
            
            $('body').toast({
                title: "browsing #{@valueOf()}"
                # message: 'Please see desk staff for key.'
                class : 'success'
                showIcon:'hashtag'
                # showProgress:'bottom'
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
    Template.redditor_view.onCreated ->
        @autorun => @subscribe 'redditor_posts', Router.current().params.name, ->
    Template.redditor_view.helpers
        user_post_docs: ->
            Docs.find
                model:'reddit'
    Template.redditor_view.events
        'click .calc_redditor_stats': ->
            Meteor.call 'calc_redditor_stats', Router.current().params.name, ->
        'click .get_user_posts': ->
            Meteor.call 'get_user_posts', Router.current().params.name, ->
        'click .pick_flat_tag': ->
            picked_user_tags.clear()
            picked_user_tags.push @valueOf()
            Meteor.call 'search_redditors', picked_user_tags.array(),true, ->
            Router.go "/users"
            $('body').toast({
                title: "browsing #{@valueOf()}"
                # message: 'Please see desk staff for key.'
                class : 'success'
                showIcon:'hashtag'
                # showProgress:'bottom'
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
     
            
if Meteor.isServer 
    Meteor.publish 'redditor_posts', (name)->
        Docs.find {
            model:'reddit'
            "reddit_data.author": name
        }, 
            limit:42
            sort:_timestamp:-1
    Meteor.publish 'redditor_by_name', (name)->
        Docs.find 
            model:'redditor'
            "reddit_data.name":name
    Meteor.publish 'redditors_pub', (
        username_search, 
        picked_user_tags=[], 
        picked_porn_tags=[]
        view_friends=false
        sort_key='_timestamp'
        sort_direction=-1
        limit=50
        dummy
    )->
        match = {model:'redditor'}
        if picked_user_tags.length > 0 then match.tags = $all:picked_user_tags 
        if picked_porn_tags.length > 0 then match['reddit_data.subreddit.over_18'] = $all:picked_porn_tags 
        
        # console.log 'redditor pub match', match
        Docs.find match, {
            # sort:_timestamp:-1
            "#{sort_key}":sort_direction
            limit:20
        }
    # Meteor.publish 'users_pub', (
    #     username_search, 
    #     picked_user_tags=[], 
    #     view_friends=false
    #     sort_key='points'
    #     sort_direction=-1
    #     limit=50
    # )->
    #     match = {}
    #     if view_friends
    #         match._id = $in: Meteor.user().friend_ids
    #     if picked_user_tags.length > 0 then match.tags = $all:picked_user_tags 
    #     if username_search
    #         match.username = {$regex:"#{username_search}", $options: 'i'}
    #     Meteor.users.find(match,{ 
    #         limit:20, 
    #         sort:
    #             "#{sort_key}":sort_direction
    #         fields:
    #             username:1
    #             image_id:1
    #             tags:1
    #             points:1
    #             credit:1
    #             first_name:1
    #             last_name:1
    #             group_memberships:1
    #             createdAt:1
    #             profile_views:1
    #     })
            
if Meteor.isClient
    Template.users.events
        'click .toggle_friends': -> Session.set('view_friends', !Session.get('view_friends'))
        'click .pick_user_tag': -> 
            picked_user_tags.push @name
            $('body').toast({
                title: "searching #{@name}"
                # message: 'Please see desk staff for key.'
                class : 'search'
                icon:'checkmark'
                position:'bottom right'
            })
            Meteor.call 'search_redditors',picked_user_tags.array(),true, ->
                # console.log 'searched users for', @name
                $('body').toast({
                    title: "search complete"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    icon:'checkmark'
                    position:'bottom right'
                    # className:
                    #     toast: 'ui massive message'
                    # displayTime: 5000
                })
                Meteor.setTimeout ->
                    Session.set('dummy', !Session.get('dummy'))
                , 5000
                        
            
        'click .unpick_user_tag': -> 
            picked_user_tags.remove @valueOf()
            if picked_user_tags.array().length > 0
                Meteor.call 'search_redditors',picked_user_tags.array(),true, ->
        'click .pick_porn_tag': -> picked_porn_tags.push @name
        'click .unpick_porn_tag': -> picked_porn_tags.remove @valueOf()
        # 'click .add_user': ->
        #     new_username = prompt('username')
        #     splitted = new_username.split(' ')
        #     formatted = new_username.split(' ').join('_').toLowerCase()
        #     console.log formatted
        #         #   return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
        #     Meteor.call 'add_user', formatted, (err,res)->
        #         console.log res
        #         new_user = Meteor.users.findOne res
        #         Meteor.users.update res,
        #             $set:
        #                 first_name:splitted[0]
        #                 last_name:splitted[1]

        #         Router.go "/user/#{formatted}"
        #         $('body').toast({
        #             title: "user created"
        #             # message: 'Please see desk staff for key.'
        #             class : 'success'
        #             icon:'user'
        #             position:'bottom right'
        #             # className:
        #             #     toast: 'ui massive message'
        #             # displayTime: 5000
        #             transition:
        #               showMethod   : 'zoom',
        #               showDuration : 250,
        #               hideMethod   : 'fade',
        #               hideDuration : 250
        #             })
                
        # 'keyup .search_user': (e,t)->
        #     username_query = $('.search_user').val()
        #     if e.which is 8
        #         if username_query.length is 0
        #             Session.set 'username_query',null
        #             # Session.set 'checking_in',false
        #         else
        #             Session.set 'username_query',username_query
        #     else
        #         Session.set 'username_query',username_query

        'click .clear_query': ->
            Session.set('username_query',null)
    
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        # 'keyup .username_search': (e,t)->
        #     username_search = $('.username_search').val()
        #     if e.which is 8
        #         if username_search.length is 0
        #             Session.set 'username_search',null
        #             Session.set 'checking_in',false
        #         else
        #             Session.set 'username_search',username_search
        #     else
        #         Session.set 'username_search',username_search
        'keyup .user_search': (e,t)->
            val = $('.user_search').val().trim().toLowerCase()
            if val.length > 2
                # Session.set('user_search',val)
                if e.which is 13
                    # picked_user_tags.clear()
                    picked_user_tags.push val
                    $('body').toast({
                        title: "searching #{val}"
                        # message: 'Please see desk staff for key.'
                        class : 'search'
                        icon:'checkmark'
                        position:'bottom right'
                    })
                    Meteor.call 'search_redditors',picked_user_tags.array(),true, ->
                        console.log 'searched users for', picked_user_tags.array()
                        $('body').toast({
                            title: "search complete"
                            # message: 'Please see desk staff for key.'
                            class : 'success'
                            icon:'checkmark'
                            position:'bottom right'
                            # className:
                            #     toast: 'ui massive message'
                            # displayTime: 5000
                        })
                    $('.user_search').val('')
            
            
    Template.users.helpers
        redditor_count: ->  Counts.get('redditor_counter')
        toggle_friends_class: -> if Session.get('view_friends',true) then 'blue large' else ''
        picked_user_tags: -> picked_user_tags.array()
        all_user_tags: -> Results.find model:'user_tag'
        
        location_tags: -> Results.find model:'location_tag'
        # all_user_tags: -> Results.find model:'user_tag'
        
        picked_porn_tags: -> picked_porn_tags.array()
        porn_tag_results: -> Results.find model:'porn_tag'
        one_result: ->
            # console.log 'one'
            Meteor.users.find({_id:$ne:Meteor.userId()}).count() is 1
        username_query: -> Session.get('username_query')
        user_docs: ->
            match = {}
            username_query = Session.get('username_query')
            if username_query
                match.username = {$regex:"#{username_query}", $options: 'i'}
            if picked_user_tags.array().length > 0
                match.tags = $all: picked_user_tags.array()
                
            match._id = $ne:Meteor.userId()
            Meteor.users.find(match
                # roles:$in:['resident','owner']
            ,
                # limit:Session.get('limit')
                limit:42
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
            )
        redditor_docs: ->
            match = {model:'redditor'}
            username_query = Session.get('username_query')
            # if username_query
            #     match.username = {$regex:"#{username_query}", $options: 'i'}
            # if picked_user_tags.array().length > 0
            #     match.tags = $all: picked_user_tags.array()
                
            Docs.find(match
                # roles:$in:['resident','owner']
            ,
                # limit:Session.get('limit')
                limit:42
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
            )
        # users: ->
        #     username_search = Session.get('username_search')
        #     Meteor.users.find({
        #         username: {$regex:"#{username_search}", $options: 'i'}
        #         # healthclub_checkedin:$ne:true
        #         # roles:$in:['resident','owner']
        #         },{ 
        #             limit:100
        #             sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
        #     })


if Meteor.isServer
    Meteor.methods
        calc_redditor_stats: (user_name)->
            user = 
                Docs.findOne 
                    model:'redditor'
                    "reddit_data.name":user_name
            console.log 'getting user posts', user
            if user 
                count = 
                    Docs.find(
                        model:'redditor'
                        "reddit_data.comment_karma":$gt:user.reddit_data.comment_karma
                    ).count()
                console.log count
                Docs.update user._id, 
                    $set:
                        comment_karma_rank:count
                
        get_user_posts: (user_name)->
            user = 
                Docs.findOne 
                    model:'redditor'
                    "reddit_data.name":user_name
            console.log 'getting user posts', user
            # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
            # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
            # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
            
            link = "http://reddit.com/user/#{user_name}.json?raw_json=1"
            HTTP.get link,(err,response)=>
                # console.log response
                if response.data.data.dist > 1
                    _.each(response.data.data.children, (item)=>
                        data = item.data
                        console.log 'item', item.data
                        found = 
                            Docs.findOne 
                                model:'reddit'
                                "reddit_data.id":data.id
                        unless found 
                            Docs.insert 
                                model:'reddit'
                                reddit_data:data
                    )
        search_redditors: (query,porn)->
            console.log 'searching redditors', query
            # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
            # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
            # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
            
            if porn 
                link = "http://reddit.com/users/search.json?q=#{query}&nsfw=1&include_over_18=on&raw_json=1&limit=100"
            else
                link = "http://reddit.com/users/search.json?q=#{query}&nsfw=0&include_over_18=off&raw_json=1&limit=100"
            HTTP.get link,(err,response)=>
                # console.log response
                if response.data.data.dist > 1
                    _.each(response.data.data.children, (item)=>
                        # console.log 'item', item
                        data = item.data
                        # len = 200
                        # # added_tags = [query]
                        # # added_tags.push data.domain.toLowerCase()
                        # # added_tags.push data.author.toLowerCase()
                        # # added_tags = _.flatten(added_tags)
                        # # console.log 'data', data
                        # redditor_doc =
                            # reddit_name: data.name
                        #     public_description: data.public_description
                        #     banner_background_image: data.banner_background_image
                        #     community_icon: data.community_icon
                        #     description_html: data.description_html
                        #     published:true
                        #     reddit_data:data
                        #     # reddit_id: data.id
                        #     # url: data.url
                        #     # domain: data.domain
                        #     # comment_count: data.num_comments
                        #     # permalink: data.permalink
                        #     # title: data.title
                        #     # # root: query
                        #     # ups:data.ups
                        #     # num_comments:data.num_comments
                        #     # # selftext: false
                        #     # points:0
                        #     # over_18:data.over_18
                        #     # thumbnail: data.thumbnail
                        #     tags: [query]
                        #     model:'group'
                        #     source:'reddit'
                        existing_doc = Docs.findOne 
                            model:'redditor'
                            "reddit_data.name":data.name
                        if existing_doc
                            # if Meteor.isDevelopment
                            if typeof(existing_doc.tags) is 'string'
                                Docs.update existing_doc._id,
                                    $unset: tags: 1
                            Docs.update existing_doc._id,
                                $addToSet: tags: $each: query
                                # $addToSet: tags: query
                                # $set:
                                #     reddit_data:data
                                #     title:data.title
                                #     ups:data.ups
                                #     over_18:data.over_18
                                #     header_img:data.header_img
                                #     display_name:data.display_name
                                #     permalink:data.permalink
                                #     member_count:data.subscribers
                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                            # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                        unless existing_doc
                            new_reddit_post_id = Docs.insert 
                                model:'redditor'
                                tags:query
                                reddit_data:data
                            console.log 'added new redditor', data.display_name
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                            # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                        return true
                )
    
    Meteor.publish 'user_tags', (picked_tags)->
        # user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd
    
        self = @
        match = {}
    
        # picked_tags.push current_herd
        if picked_tags.length > 0
            match.tags = $all: picked_tags
        count = Meteor.users.find(match).count()
        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        cloud.forEach (tag, i) ->
    
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'user_tag'
                index: i
    
        self.ready()
        
        
    Meteor.publish 'redditor_tags', (
        picked_tags
        picked_porn_tags
        )->
        # user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd
    
        self = @
        match = {model:'redditor'}
    
        # picked_tags.push current_herd
        if picked_tags.length > 0
            match.tags = $all: picked_tags
        if picked_porn_tags.length > 0 then match['reddit_data.subreddit.over_18'] = $all:picked_porn_tags 
            
        count = Docs.find(match).count()
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        cloud.forEach (tag, i) ->
    
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'user_tag'
                index: i
        location_cloud = Docs.aggregate [
            { $match: match }
            { $project: location_tags: 1 }
            { $unwind: "$location_tags" }
            { $group: _id: '$location_tags', count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        location_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'location_tag'
                index: i
        porn_cloud = Docs.aggregate [
            { $match: match }
            { $project: "reddit_data.subreddit.over_18": 1 }
            # { $unwind: "$tags" }
            { $group: _id: "$reddit_data.subreddit.over_18", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        porn_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'porn_tag'
                index: i

        self.ready()
        
        
        
if Meteor.isServer 
    Meteor.methods
        calc_user_tags: (user_id)->
            debit_tags = Meteor.call 'omega', user_id, 'debit'
            # debit_tags = Meteor.call 'omega', user_id, 'debit', (err, res)->
            # console.log res
            # console.log 'res from async agg'
            Meteor.users.update user_id, 
                $set:
                    debit_tags:debit_tags
    
            credit_tags = Meteor.call 'omega', user_id, 'credit'
            # console.log res
            # console.log 'res from async agg'
            Meteor.users.update user_id, 
                $set:
                    credit_tags:credit_tags
    
    
        omega: (user_id, direction)->
            user = Meteor.users.findOne user_id
            options = {
                explain:false
                allowDiskUse:true
            }
            match = {}
            match.model = 'debit'
            if direction is 'debit'
                match._author_id = user_id
            if direction is 'credit'
                match.target_id = user_id
    
            console.log 'found debits', Docs.find(match).count()
            # if omega.selected_tags.length > 0
            #     limit = 42
            # else
            # limit = 10
            # console.log 'omega_match', match
            # { $match: tags:$all: omega.selected_tags }
            pipe =  [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                # { $match: _id: $nin: omega.selected_tags }
                { $sort: count: -1, _id: 1 }
                { $limit: 42 }
                { $project: _id: 0, title: '$_id', count: 1 }
            ]
    
            if pipe
                agg = global['Docs'].rawCollection().aggregate(pipe,options)
                # else
                res = {}
                if agg
                    agg.toArray()
                    # printed = console.log(agg.toArray())
                    # console.log(agg.toArray())
                    # omega = Docs.findOne model:'omega_session'
                    # Docs.update omega._id,
                    #     $set:
                    #         agg:agg.toArray()
            else
                return null
            
            
            


if Meteor.isServer
    Meteor.publish 'user_search', (username, role)->
        if role
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
                roles:$in:[role]
            },{ limit:150})
        else
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
            },{ limit:150})
            
            
    Meteor.publish 'redditor_counter', ()->
        Counts.publish this, 'redditor_counter', 
            Docs.find({
                model:'redditor'
            })
        return undefined    # otherwise coffeescript returns a Counts.publish
                          # handle when Meteor expects a Mongo.Cursor object.
            