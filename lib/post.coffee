if Meteor.isClient
    Template.posts.onCreated ->
        Session.setDefault('current_search', null)
        Session.setDefault('picked_subreddit', null)
        Session.setDefault('porn', false)
        Session.setDefault('dummy', false)
        Session.setDefault('is_loading', false)
        @autorun => @subscribe 'doc_by_id', Session.get('full_doc_id'), ->
        @autorun => @subscribe 'agg_emotions',
            picked_tags.array()
            Session.get('dummy')
        @autorun => @subscribe 'post_tag_results',
            picked_tags.array()
            Session.get('picked_subreddit')
            Session.get('porn')
            Session.get('dummy')
            
    Template.doc_results.onCreated ->
        @autorun => @subscribe 'reddit_doc_results',
            picked_tags.array()
            Session.get('picked_subreddit')
            Session.get('porn')
            # Session.get('dummy')
    
    
    
    Template.posts.onCreated ->
        @autorun => Meteor.subscribe 'model_counter',('reddit'), ->
    Template.posts.helpers
        total_post_count: -> Counts.get('model_counter') 


    Template.post_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.post_view.onRendered ->
        found_doc = Docs.findOne Router.current().params.doc_id
        if found_doc 
            unless found_doc.watson
                Meteor.call 'call_watson',Router.current().params.doc_id,'rd.selftext', ->


    Template.agg_tag.onCreated ->
        @autorun => @subscribe 'tag_image', @data.name, Session.get('porn'),->
    Template.agg_tag.helpers
        term: ->
            found = Docs.findOne {
                model:'reddit'
                tags:$in:[Template.currentData().name]
                # "watson.metadata.image":$exists:true
            }, sort:ups:-1
            found
    Template.unpick_tag.onCreated ->
        @autorun => @subscribe 'tag_image', @data, Session.get('porn'),->
    Template.unpick_tag.helpers
        flat_term_image: ->
            found = Docs.findOne {
                model:'reddit'
                tags:$in:[Template.currentData()]
                "watson.metadata.image":$exists:true
            }, sort:ups:-1
            found.watson.metadata.image
    Template.agg_tag.events
        'click .result': (e,t)->
            # Meteor.call 'log_term', @title, ->
            picked_tags.push @name
            $('#search').val('')
            Session.set('full_doc_id', null)
            
            Session.set('current_search', null)
            Session.set('searching', true)
            Session.set('is_loading', true)
            # Meteor.call 'call_wiki', @name, ->
    
            Meteor.call 'search_reddit', picked_tags.array(),Session.get('porn'), ->
                Session.set('is_loading', false)
                Session.set('searching', false)
            Meteor.setTimeout ->
                Session.set('dummy',!Session.get('dummy'))
            , 5000
            
    
    Template.session_icon_button.helpers 
        session_set_class: ->
            if Session.equals(@key,@value)
                'active'
            else 
                'basic'
    Template.session_icon_button.events
        'click .set_session': ->
            Session.set(@key,@value)
    Template.posts.events
        'click .toggle_porn': ->
            Session.set('porn',!Session.get('porn'))
        'click .select_search': ->
            picked_tags.push @name
            Session.set('full_doc_id', null)
    
            Meteor.call 'search_reddit', picked_tags.array(),Session.get('porn'), ->
            $('#search').val('')
            Session.set('current_search', null)
    
    Template.post_card.helpers
        five_cleaned_tags: ->
            if picked_tags.array().length
                _.difference(@tags[..10],picked_tags.array())
            #     @tags[..5] not in picked_tags.array()
            else 
                @tags[..5]
    Template.flat_tag_picker.events
        'click .remove_tag': ->
            parent = Template.parentData()
            # if confirm "remove #{@valueOf()} tag?"
            Docs.update parent._id,
                $pull:
                    tags:@valueOf()
        'click .pick_flat_tag': -> 
            picked_tags.push @valueOf()
            Session.set('full_doc_id', null)
    
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(),Session.get('porn'), ->
                Session.set('loading',false)
    Template.post_card_big.events
        'click .minimize': ->
            Session.set('full_doc_id', null)
    Template.post_card.events
        'click .vote_up': (e)->
            $(e.currentTarget).closest('.card').transition('jiggle', 500)
            Docs.update @_id,
                $inc:
                    points:1
                    upvotes:1
            # Session.set('dummy', !Session.get('dummy'))

            
        'click .vote_down': (e)->
            $(e.currentTarget).closest('.card').transition('shake', 500)
            Docs.update @_id,
                $inc:
                    points:-1
                $inc:
                    downvotes:1
            # Session.set('dummy', !Session.get('dummy'))

        'click .expand': ->
            Session.set('full_doc_id', @_id)
            Session.set('dummy', !Session.get('dummy'))
    
        'click .pick_flat_tag': (e)-> 
            picked_tags.push @valueOf()
            Session.set('full_doc_id', null)
            $(e.currentTarget).closest('.pick_flat_tag').transition('fly up', 500)
    
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(), Session.get('porn'),->
                Session.set('loading',false)
        # 'click .pick_subreddit': -> Session.set('subreddit',@subreddit)
        # 'click .pick_domain': -> Session.set('domain',@domain)
        'click .autotag': (e)->
            $(e.currentTarget).closest('.button').transition('fade', 500)
            
            # if @rd and @rd.selftext_html
            #     dom = document.createElement('textarea')
            #     # dom.innerHTML = doc.body
            #     dom.innerHTML = @rd.selftext_html
            #     # return dom.value
            #     Docs.update @_id,
            #         $set:
            #             parsed_selftext_html:dom.value
            Meteor.call 'get_reddit_post', @_id, (err,res)->
    
            # doc = Template.parentData()
            # doc = Docs.findOne Template.parentData()._id
            # Meteor.call 'call_watson', Template.parentData()._id, parent.key, @mode, ->
            # if doc 
            $('body').toast({
                title: "breaking down emotions"
                # message: 'Please see desk staff for key.'
                class : 'black'
                showIcon:'chess loading'
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
            
            Meteor.call 'call_watson', @_id, 'rd.selftext', 'html', (err,res)->
                # $(e.currentTarget).closest('.button').transition('scale', 500)
                $('body').toast({
                    title: "emotions brokedown"
                    # message: 'Please see desk staff for key.'
                    class : 'black'
                    showIcon:'smile'
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
                Session.set('dummy', !Session.get('dummy'))
            # Meteor.call 'call_watson', doc._id, @key, @mode, ->
    Template.unpick_tag.events
        'click .unpick_tag': ->
            picked_tags.remove @valueOf()
            if picked_tags.array().length > 0
                Session.set('is_loading', true)
                Meteor.call 'search_reddit', picked_tags.array(),Session.get('porn'), =>
                    Session.set('is_loading', false)
                Meteor.setTimeout ->
                    Session.set('dummy', !Session.get('dummy'))
                , 5000
            
    
    
    Template.posts.events
        'click .print_me': ->
    
        # # 'keyup #search': _.throttle((e,t)->
        'click #search': (e,t)->
            if picked_tags.array().length > 0
                Session.set('dummy', !Session.get('dummy'))
        'keydown #search': (e,t)->
            # query = $('#search').val()
            search = $('#search').val().trim().toLowerCase()
            # if query.length > 0
            Session.set('current_search', search)
            if search.length > 0
                if e.which is 13
                    if search.length > 0
                        # Session.set('searching', true)
                        picked_tags.push search
                        Session.set('full_doc_id',null)
                        Session.set('is_loading', true)
                        Meteor.call 'search_reddit', picked_tags.array(),Session.get('porn'), ->
                            Session.set('is_loading', false)
                            # Session.set('searching', false)
                        # Meteor.setTimeout ->
                        #     Session.set('dummy', !Session.get('dummy'))
                        # , 5000
                        $('#search').val('')
                        $('#search').blur()
                        Session.set('current_search', null)
        # , 200)
    
        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)
    
        'click .reconnect': -> Meteor.reconnect()
    
        'click .toggle_tag': (e,t)-> picked_tags.push @valueOf()
        'click .pick_subreddit': -> Session.set('subreddit',@name)
        'click .unpick_subreddit': -> Session.set('subreddit',null)
        'click .pick_domain': -> Session.set('domain',@name)
        'click .unpick_domain': -> Session.set('domain',null)
        'click .print_me': (e,t)->
            
    Template.post_card.helpers
        unescaped: -> 
            txt = document.createElement("textarea")
            txt.innerHTML = @rd.selftext_html
            return txt.value
    
            # html.unescape(@rd.selftext_html)
        unescaped_content: -> 
            txt = document.createElement("textarea")
            txt.innerHTML = @rd.media_embed.content
            return txt.value
    
            # html.unescape(@rd.selftext_html)
    Template.post_view.events 
        'click .get_comments':->
            Meteor.call 'get_comments', Router.current().params.doc_id, ->
                
    Template.post_view.helpers
        comment_docs: ->
            Docs.find 
                model:'comment'
                parent_id:Router.current().params.doc_id
    Template.posts.helpers
        porn_class: ->
            if Session.get('porn') then 'large red' else 'compact'
        full_doc_id: ->
            Session.get('full_doc_id')
        full_doc: ->
            Docs.findOne Session.get('full_doc_id')
        current_bg:->
            found = Docs.findOne {
                model:'reddit'
                tags:$in:picked_tags.array()
                "watson.metadata.image":$exists:true
                # thumbnail:$nin:['default','self']
            },sort:ups:-1
            if found
                found.watson.metadata.image
            # else 
    
        emotion_avg_result: ->
            Results.findOne 
                model:'emotion_avg'
        # in_dev: -> Meteor.isDevelopment()
        not_searching: ->
            picked_tags.array().length is 0 and Session.equals('current_search',null)
            
        search_class: ->
            if Session.get('current_search')
                'massive active' 
            else
                if picked_tags.array().length is 0
                    'big'
                else 
                    'big' 
              
        # domain_results: ->
        #     Results.find 
        #         model:'domain'
        # picked_subreddit: -> Session.get('subreddit')
        # picked_domain: -> Session.get('domain')
        # subreddit_results: ->
        #     Results.find 
        #         model:'subreddit'
                    
        curent_date_setting: -> Session.get('date_setting')
    
        term_icon: ->
        is_loading: -> Session.get('is_loading')
    
        tag_result_class: ->
            # ec = omega.emotion_color
            total_doc_result_count = Docs.find({}).count()
            percent = @count/total_doc_result_count
            whole = parseInt(percent*10)+1
    
            # if whole is 0 then "#{ec} f5"
            if whole is 0 then "f5"
            else if whole is 1 then "f11"
            else if whole is 2 then "f12"
            else if whole is 3 then "f13"
            else if whole is 4 then "f14"
            else if whole is 5 then "f15"
            else if whole is 6 then "f16"
            else if whole is 7 then "f17"
            else if whole is 8 then "f18"
            else if whole is 9 then "f19"
            else if whole is 10 then "f20"
    
        connection: ->
            Meteor.status()
        connected: -> Meteor.status().connected
    
        unpicked_tags: ->
            # # doc_count = Docs.find().count()
            # # if doc_count < 3
            # #     Tags.find({count: $lt: doc_count})
            # # else
            # unless Session.get('searching')
            #     unless Session.get('current_search').length > 0
            Results.find({model:'tag'})
    
        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'
    
        picked_tags: -> picked_tags.array()
    
        picked_tags_plural: -> picked_tags.array().length > 1
    
        searching: ->
            Session.get('searching')
    
        one_post: -> Docs.find(model:'reddit').count() is 1
    
        two_posts: -> Docs.find(model:'reddit').count() is 2
        three_posts: -> Docs.find(model:'reddit').count() is 3
        four_posts: -> Docs.find(model:'reddit').count() is 4
        more_than_four: -> Docs.find(model:'reddit').count() > 4
        one_result: ->
            Docs.find(model:'reddit').count() is 1
    
        docs: ->
            # if picked_tags.array().length > 0
            cursor =
                Docs.find {
                    model:'reddit'
                },
                    sort:
                        "#{Session.get('sort_key')}":Session.get('sort_direction')
            cursor
    
    
        home_subs_ready: ->
            Template.instance().subscriptionsReady()
            
        #     @autorun => Meteor.subscribe 'current_doc', Router.current().params.doc_id
        # Template.array_view.events
        #     'click .toggle_post_filter': ->
        #         value = @valueOf()
        #         current = Template.currentData()
                # match = Session.get('match')
                # key_array = match["#{current.key}"]
                # if key_array
                #     if value in key_array
                #         key_array = _.without(key_array, value)
                #         match["#{current.key}"] = key_array
                #         picked_tags.remove value
                #         Session.set('match', match)
                #     else
                #         key_array.push value
                #         picked_tags.push value
                #         Session.set('match', match)
                #         Meteor.call 'search_reddit', picked_tags.array(), ->
                #         # Meteor.call 'agg_idea', value, current.key, 'entity', ->
                #         # match["#{current.key}"] = ["#{value}"]
                # else
                # if value in picked_tags.array()
                #     picked_tags.remove value
                # else
                #     # match["#{current.key}"] = ["#{value}"]
                #     picked_tags.push value
                # # Session.set('match', match)
                # if picked_tags.array().length > 0
                #     Meteor.call 'search_reddit', picked_tags.array(), ->
    
        # Template.array_view.helpers
        #     values: ->
        #         Template.parentData()["#{@key}"]
        #
        #     post_label_class: ->
        #         match = Session.get('match')
        #         key = Template.parentData().key
        #         doc = Template.parentData(2)
        #         if @valueOf() in picked_tags.array()
        #             'active'
        #         else
        #             'basic'
        #         # if match["#{key}"]
        #         #     if @valueOf() in match["#{key}"]
        #         #         'active'
        #         #     else
        #         #         'basic'
        #         # else
        #         #     'basic'
        #
        
        
    Template.doc_results.helpers
        doc_results: ->
            current_docs = Docs.find()
            # if Session.get('selected_doc_id') in current_docs.fetch()
            # Docs.findOne Session.get('selected_doc_id')
            doc_count = Docs.find().count()
            # if doc_count is 1
            Docs.find({model:'reddit'}, 
                limit:10
                sort:
                    points:-1
                    ups:-1
                    # "#{Session.get('sort_key')}":Session.get('sort_direction')
            )
    


  
if Meteor.isClient
    Template.post_view.onCreated ->
        @autorun => @subscribe 'related_group',Router.current().params.doc_id, ->
    Template.post_view.onCreated ->
        @autorun => @subscribe 'post_tips',Router.current().params.doc_id, ->
    Template.post_view.events 
        'click .pick_flat_tag': (e)-> 
            picked_tags.push @valueOf()
            # Session.set('full_doc_id', null)
            $(e.currentTarget).closest('.pick_flat_tag').transition('fly up', 500)
    
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
            Router.go "/posts"
        'click .goto_subreddit': ->
            Meteor.call 'find_tribe', @subreddit, (err,res)->
                Router.go "/group/#{res}"
        'click .get_comments': ->
            Meteor.call 'get_reddit_comments', (Router.current().params.doc_id), ->
                
                
if Meteor.isServer 
    Meteor.methods 
        find_tribe: (tribe_slug)->
            found = Docs.findOne 
                model:'tribe'
                slug:tribe_slug
            
            if found 
                return found._id
            else
                new_id = 
                    Docs.insert 
                        model:'tribe'
                        source:'reddit'
                        title:tribe_slug
                        slug:tribe_slug
                return new_id
                    
                            
                            
                            
                