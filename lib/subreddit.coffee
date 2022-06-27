if Meteor.isClient
    @picked_sources = new ReactiveArray []
    
    Router.route '/subreddits', (->
        @layout 'layout'
        @render 'subreddits'
        ), name:'subreddits'
    Router.route '/r/:subreddit/', (->
        @layout 'subreddit_layout'
        @render 'subreddit_view'
        ), name:'subreddit_view'
    Router.route '/subreddit/:doc_id/', (->
        @layout 'subreddit_layout'
        @render 'subreddit_dashboard'
        ), name:'subreddit_home'
    Router.route '/subreddit/:doc_id/edit', (->
        @layout 'layout'
        @render 'subreddit_edit'
        ), name:'subreddit_edit'
    Router.route '/subreddit/:doc_id/:section', (->
        @layout 'subreddit_layout'
        @render 'subreddit_section'
        ), name:'subreddit_section'
    Template.subreddit_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.subreddit_layout.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.subreddit_section.helpers
        section_template: -> "subreddit_#{Router.current().params.section}"


    Template.subreddit_members_small.onCreated ->
        @autorun => Meteor.subscribe 'subreddit_memberships', Router.current().params.doc_id, ->
    Template.subreddit_card.events
        'click .flat_subreddit_tag_pick': -> 
            picked_tags.push @valueOf()
            Meteor.call 'search_subreddits', @valueOf(), ->
        'click .pull_subreddit': ->
            console.log @reddit_data.public_description
            if @reddit_data.public_description
                Meteor.call 'call_watson', @_id, '@reddit_data.public_description', 'subreddit', ->
    Template.subreddit_members_small.helpers
        subreddit_members:->
            Meteor.users.find 
                _id:$in:@member_ids
                # subreddit_memberships:$in:[Router.current().params.doc_id]
                
if Meteor.isServer 
    Meteor.publish 'subreddit_memberships', (subreddit_id)->
        subreddit = Docs.findOne subreddit_id
        Meteor.users.find 
            # subreddit_memberships:$in:[subreddit_id]
            _id:$in:subreddit.member_ids


if Meteor.isClient
    Template.subreddit_related.onCreated ->
        @autorun => Meteor.subscribe 'related_subreddits', Router.current().params.doc_id, ->
    Template.subreddit_related.helpers
        related_subreddit_docs: ->
            Docs.find {
                model:'subreddit'
                _id: $nin:[Router.current().params.doc_id]
            }, limit:3



if Meteor.isServer 
    Meteor.publish 'related_subreddits', (subreddit_id)->
        Docs.find {
            model:'subreddit'
            _id:$nin:[subreddit_id]
        }, limit:5
    
    Meteor.publish 'subreddit_log_docs', (subreddit_id)->
        Docs.find {
            model:'log'
            subreddit_id:subreddit_id
        }, limit:10
    




if Meteor.isClient
    # Template.subreddits.onRendered ->
    #     Session.set('model',Router.current().params.model)
    Template.subreddits.onCreated ->
        document.title = 'gr subreddits'
        
        Session.setDefault('limit',20)
        Session.setDefault('sort_key','_timestamp')
        Session.setDefault('sort_icon','clock')
        Session.setDefault('sort_label','added')
        Session.setDefault('sort_direction',-1)
        # @autorun => @subscribe 'model_docs', 'post', ->
        # @autorun => @subscribe 'user_info_min', ->
        @autorun => @subscribe 'subreddit_facets',
            picked_tags.array()
            picked_sources.array()
            Session.get('subreddit_search')
            picked_timestamp_tags.array()
    
        @autorun => @subscribe 'subreddit_results',
            picked_tags.array()
            picked_sources.array()
            Session.get('subreddit_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
    Template.subreddits.events
        'click .pick_subreddit_tag': -> 
            picked_tags.push @name
            Meteor.call 'search_subreddits',@name,true, ->
            
        'click .unpick_subreddit_tag': -> picked_tags.remove @valueOf()
        'click .pick_source': -> picked_sources.push @name
        'click .unpick_source': -> picked_sources.remove @valueOf()
        'keyup .subreddit_search': (e,t)->
            val = $('.subreddit_search').val().trim().toLowerCase()
            if val.length > 2
                # Session.set('subreddit_search',val)
                if e.which is 13
                    $('body').toast({
                        title: "searching #{val}"
                        # message: 'Please see desk staff for key.'
                        class : 'search'
                        icon:'checkmark'
                        position:'bottom right'
                    })
                    Meteor.call 'search_subreddits',val,true, ->
                        console.log 'searched subreddits'
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
                    $('.subreddit_search').val('')
                    picked_tags.clear()
                    picked_tags.push val
    Template.subreddits.helpers
        picked_sources: -> picked_sources.array()
        source_results: -> Results.find model:'source_tag'
        picked_subreddit_tags: -> picked_tags.array()
        subreddit_tag_results: -> Results.find model:'tag'
        subreddit_results: ->
            match = {model:'subreddit'}
            Docs.find match,
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')        
if Meteor.isServer
    Meteor.publish 'subreddit_facets', (
        picked_tags
        picked_source
        title_search=''
        picked_timestamp_tags
        # picked_author_ids=[]
        # picked_location_tags
        # picked_building_tags
        # picked_unit_tags
        # author_id
        # parent_id
        # tag_limit
        # doc_limit
        # sort_object
        # view_private
        )->
    
            self = @
            match = {model:'subreddit'}
    
            # match.tags = $all: picked_tags
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
    
            # if view_private is false
            #     match.published = $in: [0,1]
    
            if title_search.length > 1
            #     console.log 'searching org_query', org_query
                match.title = {$regex:"#{title_search}", $options: 'i'}
    
            if picked_tags.length > 0 then match.tags = $all: picked_tags
            if picked_source.length > 0 then match.source = picked_source
    
            # if picked_author_ids.length > 0
            #     match.author_id = $in: picked_author_ids
            #     match.published = 1
            # if picked_location_tags.length > 0 then match.location_tags = $all: picked_location_tags
            # if picked_building_tags.length > 0 then match.building_tags = $all: picked_building_tags
            # if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all: picked_timestamp_tags
    
            # if tag_limit then limit=tag_limit else limit=50
            # if author_id then match.author_id = author_id
            # match.published = true
    
            # if view_private is true then match.author_id = @userId
            # if view_resonates?
            #     if view_resonates is true then match.favoriters = $in: [@userId]
            #     else if view_resonates is false then match.favoriters = $nin: [@userId]
            # if view_read?
            #     if view_read is true then match.read_by = $in: [@userId]
            #     else if view_read is false then match.read_by = $nin: [@userId]
            # if view_published is true
            #     match.published = $in: [1,0]
            # else if view_published is false
            #     match.published = -1
            #     match.author_id = Meteor.userId()
    
            # if view_bookmarked?
            #     if view_bookmarked is true then match.bookmarked_ids = $in: [@userId]
            #     else if view_bookmarked is false then match.bookmarked_ids = $nin: [@userId]
            # if view_complete? then match.complete = view_complete
            # console.log view_complete
    
    
    
            # match.site = Meteor.settings.public.site
    
            # console.log 'match:', match
            # if view_images? then match.components?.image = view_images
    
            # lightbank models
            # if view_lightbank_type? then match.lightbank_type = view_lightbank_type
            # match.lightbank_type = $ne:'journal_prompt'
    
            # ancestor_ids_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: ancestor_array: 1 }
            #     { $unwind: "$ancestor_array" }
            #     { $subreddit: _id: '$ancestor_array', count: $sum: 1 }
            #     { $match: _id: $nin: picked_ancestor_ids }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: limit }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'theme ancestor_ids_cloud, ', ancestor_ids_cloud
            # ancestor_ids_cloud.forEach (ancestor_id, i) ->
            #     self.added 'ancestor_ids', Random.id(),
            #         name: ancestor_id.name
            #         count: ancestor_id.count
            #         index: i
            total_count = Docs.find(match).count()
            # console.log 'total count', total_count
            # console.log 'facet match', match
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $subreddit: _id: '$tags', count: $sum: 1 }
                { $match: _id: $nin: picked_tags }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme tag_cloud, ', tag_cloud
            tag_cloud.forEach (tag, i) ->
                # console.log tag
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'tag'
                    index: i
    
            # 
            #
            # # watson_keyword_cloud = Docs.aggregate [
            # #     { $match: match }
            # #     { $project: watson_keywords: 1 }
            # #     { $unwind: "$watson_keywords" }
            # #     { $subreddit: _id: '$watson_keywords', count: $sum: 1 }
            # #     { $match: _id: $nin: picked_tags }
            # #     { $sort: count: -1, _id: 1 }
            # #     { $limit: limit }
            # #     { $project: _id: 0, name: '$_id', count: 1 }
            # #     ]
            # # # console.log 'cloud, ', cloud
            # # watson_keyword_cloud.forEach (keyword, i) ->
            # #     self.added 'watson_keywords', Random.id(),
            # #         name: keyword.name
            # #         count: keyword.count
            # #         index: i
            #
            sources_cloud = Docs.aggregate [
                { $match: match }
                { $project: source: 1 }
                # { $unwind: "$_timestamp_tags" }
                { $subreddit: _id: '$source', count: $sum: 1 }
                # { $match: _id: $nin: picked_timestamp_tags }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'sources_cloud, ', sources_cloud.count()
            sources_cloud.forEach (source_tag, i) ->
                self.added 'results', Random.id(),
                    name: source_tag.name
                    count: source_tag.count
                    model:'source_tag'
                    index: i
            
            # timestamp_tags_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: _timestamp_tags: 1 }
            #     { $unwind: "$_timestamp_tags" }
            #     { $subreddit: _id: '$_timestamp_tags', count: $sum: 1 }
            #     # { $match: _id: $nin: picked_timestamp_tags }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 10 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'timestamp_tags_cloud, ', timestamp_tags_cloud.count()
            # timestamp_tags_cloud.forEach (timestamp_tag, i) ->
            #     self.added 'results', Random.id(),
            #         name: timestamp_tag.name
            #         count: timestamp_tag.count
            #         model:'timestamp_tag'
            #         index: i
            
            #
            # building_tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: building_tags: 1 }
            #     { $unwind: "$building_tags" }
            #     { $subreddit: _id: '$building_tags', count: $sum: 1 }
            #     { $match: _id: $nin: picked_building_tags }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: limit }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'building building_tag_cloud, ', building_tag_cloud
            # building_tag_cloud.forEach (building_tag, i) ->
            #     self.added 'building_tags', Random.id(),
            #         name: building_tag.name
            #         count: building_tag.count
            #         index: i
            #
            #
            # location_tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: location_tags: 1 }
            #     { $unwind: "$location_tags" }
            #     { $subreddit: _id: '$location_tags', count: $sum: 1 }
            #     { $match: _id: $nin: picked_location_tags }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: limit }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'location location_tag_cloud, ', location_tag_cloud
            # location_tag_cloud.forEach (location_tag, i) ->
            #     self.added 'location_tags', Random.id(),
            #         name: location_tag.name
            #         count: location_tag.count
            #         index: i
            #
            #
            # author_match = match
            # author_match.published = 1
            #
            # author_tag_cloud = Docs.aggregate [
            #     { $match: author_match }
            #     { $project: _author_id: 1 }
            #     { $subreddit: _id: '$_author_id', count: $sum: 1 }
            #     { $match: _id: $nin: picked_author_ids }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: limit }
            #     { $project: _id: 0, text: '$_id', count: 1 }
            #     ]
            #
            #
            # # console.log author_tag_cloud
            #
            # # author_objects = []
            # # Docs.find _id: $in: author_tag_cloud.
            #
            # author_tag_cloud.forEach (author_id) ->
            #     self.added 'author_ids', Random.id(),
            #         text: author_id.text
            #         count: author_id.count
    
            # found_docs = Docs.find(match).fetch()
            # found_docs.forEach (found_doc) ->
            #     self.added 'docs', doc._id, fields
            #         text: author_id.text
            #         count: author_id.count
    
            # doc_results = []
            # int_doc_limit = parseInt doc_limit
            # subHandle = Docs.find(match, {limit:20, sort: timestamp:-1}).observeChanges(
            #     added: (id, fields) ->
            #         # console.log 'added doc', id, fields
            #         # doc_results.push id
            #         self.added 'docs', id, fields
            #     changed: (id, fields) ->
            #         # console.log 'changed doc', id, fields
            #         self.changed 'docs', id, fields
            #     removed: (id) ->
            #         # console.log 'removed doc', id, fields
            #         # doc_results.pull id
            #         self.removed 'docs', id
            # )
    
            # for doc_result in doc_results
    
            # user_results = Docs.find(_id:$in:doc_results).observeChanges(
            #     added: (id, fields) ->
            #         # console.log 'added doc', id, fields
            #         self.added 'docs', id, fields
            #     changed: (id, fields) ->
            #         # console.log 'changed doc', id, fields
            #         self.changed 'docs', id, fields
            #     removed: (id) ->
            #         # console.log 'removed doc', id, fields
            #         self.removed 'docs', id
            # )
    
    
    
            # console.log 'doc handle count', subHandle
    
            self.ready()
    
            # self.onStop ()-> subHandle.stop()
    
    Meteor.publish 'user_subreddits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'subreddit'
            _author_id: user._id
        }, sort:_timestamp:-1
    Meteor.publish 'user_subreddits_small', (username)->
        user = Meteor.users.findOne username:username
        if user.subreddit_membership_ids
            Docs.find {
                model:'subreddit'
                _id:$in:user.subreddit_membership_ids
            }, 
                sort:_timestamp:-1
                fields:
                    title:1
                    image_id:1
                    model:1
                    
                    
    Meteor.publish 'subreddit_results', (
        picked_tags=[]
        picked_sources=[]
        current_query=''
        sort_key='_timestamp'
        sort_direction=-1
        limit=42
        # picked_timestamp_tags=[]
        # picked_location_tags=[]
        )->
        self = @
        match = {model:'subreddit'}
        # if picked_ingredients.length > 0
        #     match.ingredients = $all: picked_ingredients
        #     # sort = 'price_per_serving'
        if picked_tags.length > 0
            match.tags = $all: picked_tags
        if picked_sources.length > 0
            match.source = $all:picked_sources
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        # match.published = true
            # match.source = $ne:'wikipedia'
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        if current_query.length > 1
        #     console.log 'searching org_query', org_query
            match.title = {$regex:"#{current_query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
        # match.tags = $all: picked_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array
    
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        # unless Meteor.userId()
        #     match.private = $ne:true
            
        # console.log 'results match', match
        # console.log 'sort_key', sort_key
        # console.log 'sort_direction', sort_direction
        # console.log 'limit', limit
        console.log 'subreddit results match', match
        
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: 10
            # fields:
            #     title:1
            #     model:1
            #     image_id:1
            #     "reddit_data.display_name":1
            #     "reddit_data.header_img":1
            #     "reddit_data.banner_background_image":1
            #     "reddit_data.public_description":1
            #     "reddit_data.over_18":1
            #     tags:1
            #     content:1
            #     _author_id:1
            #     published:1
            #     target_id:1
            #     _timestamp:1
            #     subreddit_id:1
            #     emotion:1
            #     watson:1
            #     upvoter_ids:1
            #     downvoter_ids:1
            #     views:1
            #     youtube_id:1
            #     points:1
            # # sort:_timestamp:-1                    
    Meteor.publish 'user_subreddit_memberships', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'subreddit'
            member_ids: $in:[user._id]
        }, sort:_timestamp:-1
    Meteor.publish 'related_subreddit', (doc_id)->
        doc = Docs.findOne doc_id
        if doc
            Docs.find {
                model:'subreddit'
                _id:doc.subreddit_id
            }
            


    Meteor.publish 'subreddit_by_slug', (subreddit_slug)->
        Docs.find
            model:'subreddit'
            slug:subreddit_slug
    Meteor.methods
        calc_subreddit_stats: (subreddit_id)->
            subreddit = Docs.findOne
                model:'subreddit'
                _id:subreddit_id

            member_count =
                subreddit.member_ids.length

            subreddit_members =
                Meteor.users.find
                    _id: $in: subreddit.member_ids
            subreddit_posts =
                Docs.users.find
                    subreddit_id:subreddit_id
            # dish_count = 0
            # for member in subreddit_members.fetch()
            #     member_dishes =
            #         Docs.find(
            #             model:'dish'
            #             _author_id:member._id
            #         ).fetch()

            post_ids = []
            subreddit_posts =
                Docs.find
                    model:'post'
                    subreddit_id:subreddit_id
            post_count = 0
            
            for post in subreddit_posts.fetch()
                console.log 'subreddit post', post.title
                post_ids.push post._id
                post_count++
                
                
                
            subreddit_count =
                Docs.find(
                    model:'subreddit'
                    subreddit_id:subreddit._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    subreddit_id:subreddit._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            subreddit_subreddits =
                Docs.find(
                    model:'subreddit'
                    subreddit_id:subreddit._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update subreddit._id,
                $set:
                    member_count:member_count
                    subreddit_count:subreddit_count
                    event_count:event_count
                    total_credit_exchanged:total_credit_exchanged
                    post_count:post_count
                    post_ids:post_ids
        # calc_subreddit_stats: ->
        #     subreddit_stat_doc = Docs.findOne(model:'subreddit_stats')
        #     unless subreddit_stat_doc
        #         new_id = Docs.insert
        #             model:'subreddit_stats'
        #         subreddit_stat_doc = Docs.findOne(model:'subreddit_stats')
        #     console.log subreddit_stat_doc
        #     total_count = Docs.find(model:'subreddit').count()
        #     complete_count = Docs.find(model:'subreddit', complete:true).count()
        #     incomplete_count = Docs.find(model:'subreddit', complete:$ne:true).count()
        #     Docs.update subreddit_stat_doc._id,
        #         $set:
        #             total_count:total_count
        #             complete_count:complete_count
        #             incomplete_count:incomplete_count
    Meteor.methods
        search_subreddits: (query,porn)->
            # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
            # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
            # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
            
            if porn 
                link = "http://reddit.com/subreddits/search.json?q=#{query}&nsfw=1&include_over_18=on"
            else
                link = "http://reddit.com/subreddits/search.json?q=#{query}&nsfw=0&include_over_18=off"
            HTTP.get link,(err,response)=>
                # console.log response
                if response.data.data.dist > 1
                    _.each(response.data.data.children, (item)=>
                        # console.log 'item', item
                        data = item.data
                        len = 200
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        # added_tags = _.flatten(added_tags)
                        # console.log 'data', data
                        reddit_subreddit =
                            reddit_name: data.name
                            public_description: data.public_description
                            banner_background_image: data.banner_background_image
                            community_icon: data.community_icon
                            description_html: data.description_html
                            published:true
                            reddit_data:data
                            # reddit_id: data.id
                            # url: data.url
                            # domain: data.domain
                            # comment_count: data.num_comments
                            # permalink: data.permalink
                            # title: data.title
                            # # root: query
                            # ups:data.ups
                            # num_comments:data.num_comments
                            # # selftext: false
                            # points:0
                            # over_18:data.over_18
                            # thumbnail: data.thumbnail
                            tags: [query]
                            model:'subreddit'
                            source:'reddit'
                        existing_doc = Docs.findOne 
                            model:'subreddit'
                            reddit_name:data.name
                        if existing_doc
                            # if Meteor.isDevelopment
                            if typeof(existing_doc.tags) is 'string'
                                Docs.update existing_doc._id,
                                    $unset: tags: 1
                            Docs.update existing_doc._id,
                                # $addToSet: tags: $each: query
                                $addToSet: tags: query
                                $set:
                                    title:data.title
                                    ups:data.ups
                                    over_18:data.over_18
                                    header_img:data.header_img
                                    display_name:data.display_name
                                    permalink:data.permalink
                                    reddit_data:data
                                    member_count:data.subscribers
                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                            # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                        unless existing_doc
                            new_reddit_post_id = Docs.insert reddit_subreddit
                            console.log 'added new subreddit', data.name
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                            # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                        return true
                )
                        
                        
if Meteor.isClient
    Template.subreddit_picker.onCreated ->
        @autorun => @subscribe 'subreddit_search_results', Session.get('subreddit_search'), ->
        @autorun => @subscribe 'subreddit_from_doc_id', Router.current().params.doc_id, ->
    Template.subreddit_picker.helpers
        subreddit_results: ->
            Docs.find {
                model:'subreddit'
                title: {$regex:"#{Session.get('subreddit_search')}",$options:'i'}
            }
        subreddit_search_value: ->
            Session.get('subreddit_search')
        subreddit_doc: ->
            # console.log @
            Docs.findOne @subreddit_id
    Template.subreddit_picker.events
        'click .clear_search': (e,t)->
            Session.set('subreddit_search', null)
            t.$('.subreddit_search').val('')

            
        'click .remove_subreddit': (e,t)->
            if confirm "remove #{@title} subreddit?"
                Docs.update Router.current().params.doc_id,
                    $unset:
                        subreddit_id:@_id
                        subreddit_title:@title
        'click .pick_subreddit': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:
                    subreddit_id:@_id
                    subreddit_title:@title
            Session.set('subreddit_search',null)
            t.$('.subreddit_search').val('')
            location.reload() 
        'keyup .subreddit_search': (e,t)->
            # if e.which is '13'
            val = t.$('.subreddit_search').val()
            if val.length > 1
                # console.log val
                Session.set('subreddit_search', val)

        'click .create_subreddit': ->
            new_id = 
                Docs.insert 
                    model:'subreddit'
                    title:Session.get('subreddit_search')
            Router.go "/doc/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'subreddit_search_results', (subreddit_title_queary)->
        Docs.find {
            model:'subreddit'
            title: {$regex:"#{subreddit_title_queary}",$options:'i'}
        }, limit:10

if Meteor.isClient
    Template.subreddit_layout.onCreated ->
        @autorun => Meteor.subscribe 'subreddit_logs', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'subreddit_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'subreddit_leaders', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'subreddit_events', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'subreddit_posts', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'subreddit_products', Router.current().params.doc_id, ->
    
    Template.subreddit_posts.onCreated ->
        @autorun => Meteor.subscribe 'subreddit_reddit_docs', Router.current().params.doc_id, ->
    Template.subreddit_posts.helpers
        subreddit_reddit_docs: ->
            subreddit = 
                Docs.findOne _id:Router.current().params.doc_id
            if subreddit
                Docs.find 
                    model:'reddit'
                    subreddit:subreddit.slug
    Template.subreddit_layout.helpers
        subreddit_log_docs: ->
            Docs.find {
                model:'log'
                subreddit_id:Router.current().params.doc_id
            },
                sort:_timestamp:-1
        subreddit_post_docs: ->
            Docs.find 
                model:'post'
                subreddit_id:Router.current().params.doc_id
        _members: ->
            Meteor.users.find 
                _id:$in:@member_ids
                
    # Template.subreddits_small.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'subreddit', Sesion.get('subreddit_search'),->
    # Template.subreddits_small.helpers
    #     subreddit_docs: ->
    #         Docs.find   
    #             model:'subreddit'
                
                
                
    # Template.subreddit_products.events
    #     'click .add_product': ->
    #         new_id = 
    #             Docs.insert 
    #                 model:'product'
    #                 subreddit_id:Router.current().params.doc_id
    #         Router.go "/doc/#{new_id}/edit"
            
    Template.subreddit_layout.events
        'click .add_subreddit_member': ->
            new_username = prompt('username')
            splitted = new_username.split(' ')
            formatted = new_username.split(' ').join('_').toLowerCase()
            console.log formatted
            Meteor.call 'add_user', formatted, (err,res)->
                console.log res
                new_user = Meteor.users.findOne res
                Meteor.users.update res,
                    $set:
                        first_name:splitted[0]
                        last_name:splitted[1]
                    $addToSet:
                        subreddit_memberships:Router.current().params.doc_id



        'click .refresh_subreddit_stats': ->
            Meteor.call 'calc_subreddit_stats', Router.current().params.doc_id, ->
        'click .add_subreddit_event': ->
            new_id = 
                Docs.insert 
                    model:'event'
                    subreddit_id:Router.current().params.doc_id
            Router.go "/doc/#{new_id}/edit"
        'click .join': ->
            if Meteor.user()
                doc = Docs.findOne Router.current().params.doc_id
                Docs.update doc._id,
                    $addToSet:
                        member_ids:Meteor.userId()
                        member_usernames:Meteor.user().username
            else 
                Router.go '/login'
        'click .leave': ->
            doc = Docs.findOne Router.current().params.doc_id
            Docs.update doc._id,
                $pull:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username


if Meteor.isServer
    Meteor.publish 'subreddit_reddit_docs', (subreddit_id)->
        subreddit = 
            Docs.findOne subreddit_id
        if subreddit and subreddit.slug
            Docs.find 
                model:'reddit'
                subreddit:subreddit.slug
    
        
    Meteor.publish 'subreddit_events', (subreddit_id)->
        # subreddit = Docs.findOne
        #     model:'subreddit'
        #     _id:subreddit_id
        Docs.find
            model:'event'
            subreddit_ids:subreddit_id

    Meteor.publish 'subreddit_posts', (subreddit_id)->
        # subreddit = Docs.findOne
        #     model:'subreddit'
        #     _id:subreddit_id
        Docs.find
            model:'post'
            subreddit_id:subreddit_id


    Meteor.publish 'subreddit_leaders', (subreddit_id)->
        subreddit = Docs.findOne subreddit_id
        if subreddit.leader_ids
            Meteor.users.find
                _id: $in: subreddit.leader_ids

    Meteor.publish 'subreddit_members', (subreddit_id)->
        subreddit = Docs.findOne subreddit_id
        Meteor.users.find
            _id: $in: subreddit.member_ids



if Meteor.isClient 
    Template.subreddit_checkins.onCreated ->
        @autorun => @subscribe 'child_docs', 'checkin', Router.current().params.doc_id, ->
    Template.subreddit_checkins.events 
        'click .checkin': ->
            Meteor.call 'checkin', Router.current().params.doc_id, Meteor.userId(), ->
                $('body').toast({
                    title: "checked in"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    icon:'sign in alternate'
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
                
        'click .checkout': ->
            Meteor.call 'checkout', Router.current().params.doc_id, Meteor.userId(), ->
                $('body').toast({
                    title: "checked out"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    icon:'sign out alternates'
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
                    
            
if Meteor.isClient               
    Template.subreddit_checkins.helpers
        checkin_docs: ->
            Docs.find {
                model:'checkin'
                parent_id:Router.current().params.doc_id
            }, sort:_timestamp:-1
        checked_in: ->
            Docs.findOne 
                model:'checkin'
                _author_id:Meteor.userId()
                active:true
        
        