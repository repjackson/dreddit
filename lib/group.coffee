if Meteor.isClient
    @picked_sources = new ReactiveArray []
    
    Router.route '/groups', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'
    Router.route '/group/:doc_id/', (->
        @layout 'group_layout'
        @render 'group_dashboard'
        ), name:'group_home'
    Router.route '/group/:doc_id/edit', (->
        @layout 'layout'
        @render 'group_edit'
        ), name:'group_edit'
    Router.route '/group/:doc_id/:section', (->
        @layout 'group_layout'
        @render 'group_section'
        ), name:'group_section'
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.group_layout.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.group_section.helpers
        section_template: -> "group_#{Router.current().params.section}"


    Template.group_members_small.onCreated ->
        @autorun => Meteor.subscribe 'group_memberships', Router.current().params.doc_id, ->
    Template.group_card.events
        'click .flat_group_tag_pick': -> 
            picked_tags.push @valueOf()
            Meteor.call 'search_subreddits', @valueOf(), ->
        'click .pull_subreddit': ->
            console.log @reddit_data.public_description
            if @reddit_data.public_description
                Meteor.call 'call_watson', @_id, '@reddit_data.public_description', 'subreddit', ->
    Template.group_members_small.helpers
        group_members:->
            Meteor.users.find 
                _id:$in:@member_ids
                # group_memberships:$in:[Router.current().params.doc_id]
                
if Meteor.isServer 
    Meteor.publish 'group_memberships', (group_id)->
        group = Docs.findOne group_id
        Meteor.users.find 
            # group_memberships:$in:[group_id]
            _id:$in:group.member_ids


if Meteor.isClient
    Template.group_related.onCreated ->
        @autorun => Meteor.subscribe 'related_groups', Router.current().params.doc_id, ->
    Template.group_related.helpers
        related_group_docs: ->
            Docs.find {
                model:'group'
                _id: $nin:[Router.current().params.doc_id]
            }, limit:3



if Meteor.isServer 
    Meteor.publish 'related_groups', (group_id)->
        Docs.find {
            model:'group'
            _id:$nin:[group_id]
        }, limit:5
    
    Meteor.publish 'group_log_docs', (group_id)->
        Docs.find {
            model:'log'
            group_id:group_id
        }, limit:10
    




if Meteor.isClient
    # Template.groups.onRendered ->
    #     Session.set('model',Router.current().params.model)
    Template.groups.onCreated ->
        document.title = 'gr groups'
        
        Session.setDefault('limit',20)
        Session.setDefault('sort_key','_timestamp')
        Session.setDefault('sort_icon','clock')
        Session.setDefault('sort_label','added')
        Session.setDefault('sort_direction',-1)
        # @autorun => @subscribe 'model_docs', 'post', ->
        # @autorun => @subscribe 'user_info_min', ->
        @autorun => @subscribe 'group_facets',
            picked_tags.array()
            picked_sources.array()
            Session.get('group_search')
            picked_timestamp_tags.array()
    
        @autorun => @subscribe 'group_results',
            picked_tags.array()
            picked_sources.array()
            Session.get('group_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
    Template.groups.events
        'click .pick_group_tag': -> 
            picked_tags.push @name
            Meteor.call 'search_subreddits',@name,true, ->
            
        'click .unpick_group_tag': -> picked_tags.remove @valueOf()
        'click .pick_source': -> picked_sources.push @name
        'click .unpick_source': -> picked_sources.remove @valueOf()
        'keyup .group_search': (e,t)->
            val = $('.group_search').val().trim().toLowerCase()
            if val.length > 2
                # Session.set('group_search',val)
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
                    $('.group_search').val('')
                    picked_tags.clear()
                    picked_tags.push val
    Template.groups.helpers
        picked_sources: -> picked_sources.array()
        source_results: -> Results.find model:'source_tag'
        picked_group_tags: -> picked_tags.array()
        group_tag_results: -> Results.find model:'tag'
        group_results: ->
            match = {model:'group'}
            Docs.find match,
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')        
if Meteor.isServer
    Meteor.publish 'group_facets', (
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
            match = {model:'group'}
    
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
            #     { $group: _id: '$ancestor_array', count: $sum: 1 }
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
                { $group: _id: '$tags', count: $sum: 1 }
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
            # #     { $group: _id: '$watson_keywords', count: $sum: 1 }
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
                { $group: _id: '$source', count: $sum: 1 }
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
            #     { $group: _id: '$_timestamp_tags', count: $sum: 1 }
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
            #     { $group: _id: '$building_tags', count: $sum: 1 }
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
            #     { $group: _id: '$location_tags', count: $sum: 1 }
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
            #     { $group: _id: '$_author_id', count: $sum: 1 }
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
    
    Meteor.publish 'user_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'group'
            _author_id: user._id
        }, sort:_timestamp:-1
    Meteor.publish 'user_groups_small', (username)->
        user = Meteor.users.findOne username:username
        if user.group_membership_ids
            Docs.find {
                model:'group'
                _id:$in:user.group_membership_ids
            }, 
                sort:_timestamp:-1
                fields:
                    title:1
                    image_id:1
                    model:1
                    
                    
    Meteor.publish 'group_results', (
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
        match = {model:'group'}
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
        console.log 'group results match', match
        
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
            #     group_id:1
            #     emotion:1
            #     watson:1
            #     upvoter_ids:1
            #     downvoter_ids:1
            #     views:1
            #     youtube_id:1
            #     points:1
            # # sort:_timestamp:-1                    
    Meteor.publish 'user_group_memberships', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'group'
            member_ids: $in:[user._id]
        }, sort:_timestamp:-1
    Meteor.publish 'related_group', (doc_id)->
        doc = Docs.findOne doc_id
        if doc
            Docs.find {
                model:'group'
                _id:doc.group_id
            }
            


    Meteor.publish 'group_by_slug', (group_slug)->
        Docs.find
            model:'group'
            slug:group_slug
    Meteor.methods
        calc_group_stats: (group_id)->
            group = Docs.findOne
                model:'group'
                _id:group_id

            member_count =
                group.member_ids.length

            group_members =
                Meteor.users.find
                    _id: $in: group.member_ids
            group_posts =
                Docs.users.find
                    group_id:group_id
            # dish_count = 0
            # for member in group_members.fetch()
            #     member_dishes =
            #         Docs.find(
            #             model:'dish'
            #             _author_id:member._id
            #         ).fetch()

            post_ids = []
            group_posts =
                Docs.find
                    model:'post'
                    group_id:group_id
            post_count = 0
            
            for post in group_posts.fetch()
                console.log 'group post', post.title
                post_ids.push post._id
                post_count++
                
                
                
            group_count =
                Docs.find(
                    model:'group'
                    group_id:group._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    group_id:group._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            group_groups =
                Docs.find(
                    model:'group'
                    group_id:group._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update group._id,
                $set:
                    member_count:member_count
                    group_count:group_count
                    event_count:event_count
                    total_credit_exchanged:total_credit_exchanged
                    post_count:post_count
                    post_ids:post_ids
        # calc_group_stats: ->
        #     group_stat_doc = Docs.findOne(model:'group_stats')
        #     unless group_stat_doc
        #         new_id = Docs.insert
        #             model:'group_stats'
        #         group_stat_doc = Docs.findOne(model:'group_stats')
        #     console.log group_stat_doc
        #     total_count = Docs.find(model:'group').count()
        #     complete_count = Docs.find(model:'group', complete:true).count()
        #     incomplete_count = Docs.find(model:'group', complete:$ne:true).count()
        #     Docs.update group_stat_doc._id,
        #         $set:
        #             total_count:total_count
        #             complete_count:complete_count
        #             incomplete_count:incomplete_count
    Meteor.methods
                        
if Meteor.isClient
    Template.group_picker.onCreated ->
        @autorun => @subscribe 'group_search_results', Session.get('group_search'), ->
        @autorun => @subscribe 'group_from_doc_id', Router.current().params.doc_id, ->
    Template.group_picker.helpers
        group_results: ->
            Docs.find {
                model:'group'
                title: {$regex:"#{Session.get('group_search')}",$options:'i'}
            }
        group_search_value: ->
            Session.get('group_search')
        group_doc: ->
            # console.log @
            Docs.findOne @group_id
    Template.group_picker.events
        'click .clear_search': (e,t)->
            Session.set('group_search', null)
            t.$('.group_search').val('')

            
        'click .remove_group': (e,t)->
            if confirm "remove #{@title} group?"
                Docs.update Router.current().params.doc_id,
                    $unset:
                        group_id:@_id
                        group_title:@title
        'click .pick_group': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:
                    group_id:@_id
                    group_title:@title
            Session.set('group_search',null)
            t.$('.group_search').val('')
            location.reload() 
        'keyup .group_search': (e,t)->
            # if e.which is '13'
            val = t.$('.group_search').val()
            if val.length > 1
                # console.log val
                Session.set('group_search', val)

        'click .create_group': ->
            new_id = 
                Docs.insert 
                    model:'group'
                    title:Session.get('group_search')
            Router.go "/doc/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'group_search_results', (group_title_queary)->
        Docs.find {
            model:'group'
            title: {$regex:"#{group_title_queary}",$options:'i'}
        }, limit:10

if Meteor.isClient
    Template.group_layout.onCreated ->
        @autorun => Meteor.subscribe 'group_logs', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_leaders', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_events', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_posts', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_products', Router.current().params.doc_id, ->
    
    Template.group_posts.onCreated ->
        @autorun => Meteor.subscribe 'group_reddit_docs', Router.current().params.doc_id, ->
    Template.group_posts.helpers
        group_reddit_docs: ->
            group = 
                Docs.findOne _id:Router.current().params.doc_id
            if group
                Docs.find 
                    model:'reddit'
                    subreddit:group.slug
    Template.group_layout.helpers
        group_log_docs: ->
            Docs.find {
                model:'log'
                group_id:Router.current().params.doc_id
            },
                sort:_timestamp:-1
        group_post_docs: ->
            Docs.find 
                model:'post'
                group_id:Router.current().params.doc_id
        _members: ->
            Meteor.users.find 
                _id:$in:@member_ids
                
    # Template.groups_small.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'group', Sesion.get('group_search'),->
    # Template.groups_small.helpers
    #     group_docs: ->
    #         Docs.find   
    #             model:'group'
                
                
                
    # Template.group_products.events
    #     'click .add_product': ->
    #         new_id = 
    #             Docs.insert 
    #                 model:'product'
    #                 group_id:Router.current().params.doc_id
    #         Router.go "/doc/#{new_id}/edit"
            
    Template.group_layout.events
        'click .add_group_member': ->
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
                        group_memberships:Router.current().params.doc_id



        'click .refresh_group_stats': ->
            Meteor.call 'calc_group_stats', Router.current().params.doc_id, ->
        'click .add_group_event': ->
            new_id = 
                Docs.insert 
                    model:'event'
                    group_id:Router.current().params.doc_id
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
    Meteor.publish 'group_reddit_docs', (group_id)->
        group = 
            Docs.findOne group_id
        if group and group.slug
            Docs.find 
                model:'reddit'
                subreddit:group.slug
    
        
    Meteor.publish 'group_events', (group_id)->
        # group = Docs.findOne
        #     model:'group'
        #     _id:group_id
        Docs.find
            model:'event'
            group_ids:group_id

    Meteor.publish 'group_posts', (group_id)->
        # group = Docs.findOne
        #     model:'group'
        #     _id:group_id
        Docs.find
            model:'post'
            group_id:group_id


    Meteor.publish 'group_leaders', (group_id)->
        group = Docs.findOne group_id
        if group.leader_ids
            Meteor.users.find
                _id: $in: group.leader_ids

    Meteor.publish 'group_members', (group_id)->
        group = Docs.findOne group_id
        Meteor.users.find
            _id: $in: group.member_ids



if Meteor.isClient 
    Template.group_checkins.onCreated ->
        @autorun => @subscribe 'child_docs', 'checkin', Router.current().params.doc_id, ->
    Template.group_checkins.events 
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
                    
            
if Meteor.isServer
    Meteor.methods 
        checkin: (parent_id)->
            Docs.insert 
                model:'checkin'
                active:true
                group_id:parent_id
                parent_id:parent_id
            active_checkin = 
                Docs.findOne 
                    model:'checkin'
                    status:active
                    _author_id:Meteor.userId()
            if active_checkin
                Docs.update active_checkin._id,
                    $set:
                        active:false
                        checkout_timestamp:Date.now()
            
        checkout: (parent_id)->
            active_doc =
                Docs.findOne 
                    model:'checkin'
                    active:true
                    parent_id:parent_id
            if active_doc
                Docs.update active_doc._id, 
                    $set:
                        active:false
                        checkout_timestamp:Date.now()
            
     
if Meteor.isClient               
    Template.group_checkins.helpers
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
        
        