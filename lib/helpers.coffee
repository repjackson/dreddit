if Meteor.isClient   
    Template.registerHelper 'term', () ->
    Template.registerHelper 'emotion_color', () ->
        if @sentiment
            if @sentiment is 'positive' then 'green' else 'red'
        
        # if @max_emotion_name
        #     switch @max_emotion_name
        #         when 'sadness' then 'blue'
        #         when 'joy' then 'green'
        #         when 'confident' then 'teal'
        #         when 'analytical' then 'orange'
        #         when 'tentative' then 'yellow'
        # else if @doc_sentiment_label
        #     if @doc_sentiment_label is 'positive' then 'green'
        #     else if @doc_sentiment_label is 'negative' then 'red'
    # Template.registerHelper 'user_group_memberships', () -> 
    #     user = Meteor.users.findOne username:@username
    #     Docs.find
    #         model:'group'
    #         member_ids: $in:[user._id]
    
    
    Template.registerHelper 'cal_time', (input) -> moment(input).calendar()

    
    Template.registerHelper 'active_term_class', () ->
        found_emotion_avg = 
            Results.findOne 
                model:'emotion_avg'
        if found_emotion_avg
            
            if found_emotion_avg.avg_sent_score < 0
                'red'
            else 
                'green'
    Template.registerHelper 'above_50', (input) ->
        input > .5
    Template.registerHelper 'has_thumbnail', () ->
        @thumbnail and @thumbnail not in ['self','default']
    
    Template.registerHelper 'hostname', () -> 
        window.location.hostname
    
    Template.registerHelper 'points_to_coins', (input) -> input/100
    
    Template.registerHelper 'all_docs', () -> Docs.find()
    
    Template.registerHelper 'parent', () -> Template.parentData()
    Template.registerHelper '_parent_doc', () ->
        Docs.findOne @parent_id
        # Template.parentData()
    Template.registerHelper 'current_time', () -> moment().format("h:mm a")
    Template.registerHelper 'subs_ready', () -> 
        Template.instance().subscriptionsReady()
    
    Template.registerHelper 'is_connected', () -> Meteor.status().connected
    
    Template.registerHelper 'sorting_up', () ->
        parseInt(Session.get('sort_direction')) is 1
    
    Template.registerHelper 'skv_is', (key,value)->
        Session.equals(key,value)
    
    Template.registerHelper 'is_loading', () -> Session.get 'loading'
    Template.registerHelper 'dev', () -> Meteor.isDevelopment
    # Template.registerHelper 'is_author', ()-> @_author_id is Meteor.userId()
    # Template.registerHelper 'is_grandparent_author', () ->
    #     grandparent = Template.parentData(2)
    #     grandparent._author_id is Meteor.userId()
    Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed(0)
    Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
    Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm a")
    Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
    Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
    Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
    # Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
    Template.registerHelper 'today', () -> moment(Date.now()).format("dddd, MMMM Do a")
    Template.registerHelper 'int', (input) -> input.toFixed(0)
    Template.registerHelper '_when', () -> moment(@_timestamp).fromNow()
    Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
    Template.registerHelper 'from_now_utc', (input) -> moment(input).utc().fromNow()
    Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
    # Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
    
    
    Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
    Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")
    
    
    Template.registerHelper 'current_doc', () -> Docs.findOne Router.current().params.doc_id
    
    Template.registerHelper 'total_potential_revenue', () ->
        @price_per_serving * @servings_amount
    
    # Template.registerHelper 'servings_available', () ->
    #     @price_per_serving * @servings_amount
    
    Template.registerHelper 'session_is', (key, value)-> Session.equals(key, value)
    Template.registerHelper 'session_get', (key)-> Session.get(key)
    
    Template.registerHelper 'key_value_is', (key, value)->
        @["#{key}"] is value
    
    Template.registerHelper 'is', (key, value)->
        key is value
    
    Template.registerHelper 'parent_is', (key, value)->
        Template.parentData()["#{key}"] is value
        # key is value
    
    Template.registerHelper 'parent_key_value_is', (key, value)->
        @["#{key}"] is value
    
    
    
    # Template.registerHelper 'parent_template', () -> Template.parentData()
        # Session.get 'displaying_profile'
    
    # Template.registerHelper 'checking_in_doc', () ->
    #     Docs.findOne
    #         model:'healthclub_session'
    #         current:true
    #      # Session.get('session_document')
    
    # Template.registerHelper 'current_session_doc', () ->
    #         Docs.findOne
    #             model:'healthclub_session'
    #             current:true
    
    
    
    
    Template.registerHelper 'template_parent', () ->
        Template.parentData()
    
    
    
    Template.registerHelper 'nl2br', (text)->
        nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
        new Spacebars.SafeString(nl2br)
    
    
    Template.registerHelper 'loading_class', () ->
        if Session.get 'loading' then 'disabled' else ''
    
    Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()
    
    # Template.registerHelper 'data_doc', ->
    #     if Router.current().params.doc_id
    #         doc = Docs.findOne Router.current().params.doc_id
    #         # if doc then doc
    #     # else 
    #     #     @
    # Template.registerHelper 'user_from_user_id_param', () ->
    #     found = Meteor.users.findOne _id:Router.current().params.user_id
    #     found
    
    
    Template.registerHelper 'in_dev', () -> Meteor.isDevelopment
    
    Template.registerHelper 'calculated_size', (metric) ->
        whole = parseInt(@["#{metric}"]*10)
    
        if whole is 2 then 'f2'
        else if whole is 3 then 'f3'
        else if whole is 4 then 'f4'
        else if whole is 5 then 'f5'
        else if whole is 6 then 'f6'
        else if whole is 7 then 'f7'
        else if whole is 8 then 'f8'
        else if whole is 9 then 'f9'
        else if whole is 10 then 'f10'
    
    Template.registerHelper 'unescaped', () ->
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.selftext_html
        return txt.value
    
            # html.unescape(@rd.selftext_html)
    Template.registerHelper 'unescaped_content', () ->
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.media_embed.content
        return txt.value
        
    Template.registerHelper 'session_key_value_is', (key, value) ->
        Session.equals key,value
    
    Template.registerHelper 'key_value_is', (key, value) ->
        @["#{key}"] is value
    
    
    Template.registerHelper 'template_subs_ready', () ->
        Template.instance().subscriptionsReady()
    
    Template.registerHelper 'global_subs_ready', () ->
        Session.get('global_subs_ready')
    
    
    Template.registerHelper 'sval', (input)-> Session.get(input)
    Template.registerHelper 'is_loading', -> Session.get 'is_loading'
    Template.registerHelper 'dev', -> Meteor.isDevelopment
    Template.registerHelper 'fixed', (number)->
        (number/100).toFixed()
    # Template.registerHelper 'to_percent', (number)->
    #     (number*100).toFixed()
    
    Template.registerHelper 'is_image', () ->
        # regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
        # match = @url.match(regExp)
        # if match then true
        # true
        regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
        match = @url.match(regExp)
        if match then true
        # true
    
    
    
    Template.registerHelper 'loading_class', ()->
        if Session.get 'loading' then 'disabled' else ''
    
    
    # Template.reddit_card.onRendered ->
    #     found_doc = @data
    #     if found_doc 
    #         unless found_doc.doc_sentiment_label
    #             Meteor.call 'call_watson',found_doc._id,'title','html',->
    
        # @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    

    Template.registerHelper 'comma', (input) ->
        input.toLocaleString("en-US")
    Template.registerHelper 'emotion_color', () ->
        if @sentiment
            if @sentiment is 'positive' then 'green' else 'red'
        # if @max_emotion_name
        #     switch @max_emotion_name
        #         when 'sadness' then 'blue'
        #         when 'joy' then 'green'
        #         when 'confident' then 'teal'
        #         when 'analytical' then 'orange'
        #         when 'tentative' then 'yellow'
        # else if @doc_sentiment_label
        #     if @doc_sentiment_label is 'positive' then 'green'
        #     else if @doc_sentiment_label is 'negative' then 'red'
    Template.registerHelper 'hostname', () -> 
        window.location.hostname
    
    Template.registerHelper 'following_users', () -> 
        Meteor.users.find 
            _id:$in:@following_user_ids
    
    Template.registerHelper 'all_docs', () -> Docs.find()
    Template.registerHelper 'one_result', () -> Docs.find(model:'reddit').count() is 1
    Template.registerHelper 'two_results', () -> Docs.find(model:'reddit').count() is 2
    
    
    Template.registerHelper 'parent', () -> Template.parentData()
    Template.registerHelper '_parent_doc', () ->
        Docs.findOne @parent_id
        # Template.parentData()
    Template.registerHelper 'sort_label', () -> Session.get('sort_label')
    Template.registerHelper 'sort_icon', () -> Session.get('sort_icon')
    Template.registerHelper 'current_limit', () -> parseInt(Session.get('limit'))
    
    Template.registerHelper 'current_time', () -> moment().format("h:mm a")
    Template.registerHelper 'subs_ready', () -> 
        Template.instance().subscriptionsReady()
    
    Template.registerHelper 'related_group_doc', () -> 
        Docs.findOne 
            model:'group'
            _id:@group_id
    
    Template.registerHelper 'user_groups', () ->
        if @group_membership_ids
            Docs.find 
                model:'group'
                _id:$in:@group_membership_ids
    Template.registerHelper 'user_model_docs', (model) -> 
        username = Router.current().params.username
        Meteor.users.findOne username:username
        Docs.find {
            model:model
            _author_username:username
        }, sort:_timestamp:-1
        
        
        
    Template.registerHelper 'is_connected', () -> Meteor.status().connected
    
    Template.registerHelper 'is_author', () -> 
        @_author_id is Meteor.userId()
    Template.registerHelper 'current_lat', () -> 
        Session.get('current_lat')
    Template.registerHelper 'current_long', () -> 
        Session.get('current_long')
    # Template.registerHelper 'current_username', () ->
    #     Router.current().params.username
    
    Template.registerHelper 'rental', () ->
        Docs.findOne @rental_id
        # Template.parentData()
    
    
    Template.registerHelper '_target', () ->
        if @target_id
            Meteor.users.findOne
                _id: @target_id
        # else if @recipient_id
        #     Meteor.users.findOne
        #         _id: @recipient_id
    
    Template.registerHelper 'sorting_up', () ->
        parseInt(Session.get('sort_direction')) is 1
    
    Template.registerHelper 'user_from_id', (id)->
        Meteor.users.findOne id
        
        
    Template.registerHelper 'skv_is', (key,value)->
        Session.equals(key,value)
    
    
    Template.registerHelper 'group_doc', () ->
        Docs.findOne 
            model:'group'
            _id:@group_id
    
    Template.registerHelper 'gs', () ->
        Docs.findOne
            model:'global_settings'
    Template.registerHelper 'display_mode', () -> Session.get('display_mode',true)
    Template.registerHelper 'is_loading', () -> Session.get 'loading'
    Template.registerHelper 'dev', () -> Meteor.isDevelopment
    # Template.registerHelper 'is_author', ()-> @_author_id is Meteor.userId()
    # Template.registerHelper 'is_grandparent_author', () ->
    #     grandparent = Template.parentData(2)
    #     grandparent._author_id is Meteor.userId()
    # Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed()
    Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed(0)
    Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
    Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm a")
    Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
    Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
    Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
    # Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
    Template.registerHelper 'today', () -> moment(Date.now()).format("dddd, MMMM Do a")
    Template.registerHelper 'fixed', (input) ->
        if input
            input.toFixed(2)
    Template.registerHelper 'int', (input) -> input.toFixed(0)
    Template.registerHelper '_when', () -> moment(@_timestamp).fromNow()
    Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
    Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
    # Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
    
    
    Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
    Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")
    
    
    Template.registerHelper 'current_doc', () -> Docs.findOne Router.current().params.doc_id
    
    Template.registerHelper 'total_potential_revenue', () ->
        @price_per_serving * @servings_amount
    
    # Template.registerHelper 'servings_available', () ->
    #     @price_per_serving * @servings_amount
    
    Template.registerHelper 'session_is', (key, value)-> Session.equals(key, value)
    Template.registerHelper 'session_get', (key)-> Session.get(key)
    
    Template.registerHelper 'key_value_is', (key, value)->
        @["#{key}"] is value
    
    Template.registerHelper 'is', (key, value)->
        key is value
    
    Template.registerHelper 'parent_is', (key, value)->
        Template.parentData()["#{key}"] is value
        # key is value
    
    Template.registerHelper 'parent_key_value_is', (key, value)->
        @["#{key}"] is value
    
    
    
    # Template.registerHelper 'parent_template', () -> Template.parentData()
        # Session.get 'displaying_profile'
    
    # Template.registerHelper 'checking_in_doc', () ->
    #     Docs.findOne
    #         model:'healthclub_session'
    #         current:true
    #      # Session.get('session_document')
    
    # Template.registerHelper 'current_session_doc', () ->
    #         Docs.findOne
    #             model:'healthclub_session'
    #             current:true
    
    
    
    # Template.registerHelper 'checkin_guest_docs', () ->
    #     Docs.findOne Router.current().params.doc_id
    #     session_document = Docs.findOne Router.current().params.doc_id
    #     Docs.find
    #         _id:$in:session_document.guest_ids
    
    
    Template.registerHelper '_author', () -> Meteor.users.findOne @_author_id
    Template.registerHelper 'is_text', () ->
        @field_type is 'text'
    
    Template.registerHelper 'template_parent', () ->
        Template.parentData()
    
    
    
    Template.registerHelper 'nl2br', (text)->
        nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
        new Spacebars.SafeString(nl2br)
    
    
    Template.registerHelper 'loading_class', () ->
        if Session.get 'loading' then 'disabled' else ''
    
    Template.registerHelper 'in_list', (key) ->
        if Meteor.userId()
            if @["#{key}"]
                if Meteor.userId() in @["#{key}"] then true else false
    
    
    Template.registerHelper 'current_user', () ->  
        Meteor.users.findOne username:Router.current().params.username
    Template.registerHelper 'order_rental', -> 
        Docs.findOne 
            _id:@rental_id
        
        
    Template.registerHelper 'can_edit', () ->
        # Session.equals('current_username',@_author_username)
        if Meteor.user()
            if Meteor.userId() is @_author_id 
                true
            else Meteor.user().admin_mode
    
    Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()
    
    # Template.registerHelper 'data_doc', ->
    #     if Router.current().params.doc_id
    #         doc = Docs.findOne Router.current().params.doc_id
    #         # if doc then doc
    #     # else 
    #     #     @
    
    Template.registerHelper 'user_from_username_param', () ->
        found = Meteor.users.findOne username:Router.current().params.username
        found
    # Template.registerHelper 'user_from_user_id_param', () ->
    #     found = Meteor.users.findOne _id:Router.current().params.user_id
    #     found
    Template.registerHelper 'field_value', () ->
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)
    
    
        if @direct
            parent = Template.parentData()
        else if parent5
            if parent5._id
                parent = Template.parentData(5)
        else if parent6
            if parent6._id
                parent = Template.parentData(6)
        if parent
            parent["#{@key}"]
    
    
    Template.registerHelper 'sorted_field_values', () ->
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)
    
    
        if @direct
            parent = Template.parentData()
        else if parent5._id
            parent = Template.parentData(5)
        else if parent6._id
            parent = Template.parentData(6)
        if parent
            _.sortBy parent["#{@key}"], 'number'
    
    
    Template.registerHelper 'in_dev', () -> Meteor.isDevelopment
    
    Template.registerHelper 'calculated_size', (metric) ->
        whole = parseInt(@["#{metric}"]*10)
    
        if whole is 2 then 'f2'
        else if whole is 3 then 'f3'
        else if whole is 4 then 'f4'
        else if whole is 5 then 'f5'
        else if whole is 6 then 'f6'
        else if whole is 7 then 'f7'
        else if whole is 8 then 'f8'
        else if whole is 9 then 'f9'
        else if whole is 10 then 'f10'
    
    
    
    Template.registerHelper 'in_dev', () -> Meteor.isDevelopment
    
    
    
    
if Meteor.isClient   
    Template.registerHelper 'emotion_color', () ->
        if @sentiment
            if @sentiment is 'positive' then 'green' else 'red'
        
        # if @max_emotion_name
        #     switch @max_emotion_name
        #         when 'sadness' then 'blue'
        #         when 'joy' then 'green'
        #         when 'confident' then 'teal'
        #         when 'analytical' then 'orange'
        #         when 'tentative' then 'yellow'
        # else if @doc_sentiment_label
        #     if @doc_sentiment_label is 'positive' then 'green'
        #     else if @doc_sentiment_label is 'negative' then 'red'
    # Template.registerHelper 'user_group_memberships', () -> 
    #     user = Meteor.users.findOne username:@username
    #     Docs.find
    #         model:'group'
    #         member_ids: $in:[user._id]
    
    globalHotkeys = new Hotkeys();
    
    globalHotkeys.add({
    	combo : "ctrl+4",
    	eventType: "keydown",
    	callback : ()->
    		alert("You pressed ctrl+4");
    })
    
    globalHotkeys.add({
    	combo : "r a",
    	callback : ()->
    	    if Meteor.userId()
    	        Meteor.users.update Meteor.userId(),
    	            $set:
    	                admin_mode:!Meteor.user().admin_mode
    # 		alert("admin mode toggle")
    })
    globalHotkeys.add({
    	combo : "g g",
    	callback : ()-> Router.go "/groups"
    })
    globalHotkeys.add({
    	combo : "g u",
    	callback : ()-> Router.go "/users"
    })
    globalHotkeys.add({
    	combo : "g s",
    	callback : ()-> Router.go "/search"
    })
    globalHotkeys.add({
    	combo : "g p",
    	callback : ()-> 
    	    if Meteor.user()
        	    Router.go "/user/#{Meteor.user().username}"
        	else 
        	    Router.go "/login"
    })
    globalHotkeys.add({
    	combo : "m p",
    	callback : ()-> Router.go "/posts"
    })
    globalHotkeys.add({
    	combo : "m e",
    	callback : ()-> Router.go "/events"
    })
    
    Template.registerHelper 'lowered', (string) -> string.toLowerCase() 
    Template.registerHelper 'upper', (string) -> 
        string.charAt(0).toUpperCase() + string.slice(1)
        # input.toUpperCase()
    Template.registerHelper 'building_doc', (input) -> 
        Docs.findOne 
            model:'building'
            building_number:@building_number
    Template.registerHelper 'unit_doc', (input) -> 
        Docs.findOne 
            model:'unit'
            unit_number:@unit_number
    Template.registerHelper 'stats_doc', (input) -> 
        Docs.findOne 
            model:'stats'
    Template.registerHelper '_rental', (input) -> 
        Docs.findOne 
            _id:@rental_id
    Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
    Template.registerHelper 'first_initial', (input) -> 
        if @first_name
            @first_name[..0].toUpperCase()+@first_name[1]+'.'
    Template.registerHelper 'last_initial', (input) -> 
        if @last_name
            @last_name[..0].toUpperCase()+@last_name[1]+'.'
    Template.registerHelper 'global_stats_doc', () -> 
        Docs.findOne 
            model:'stats'
    Template.registerHelper 'current_checkin', () -> 
        kiosk = Docs.findOne model:'kiosk'
        # current = Docs.findOne kiosk.currrent_checkin_id
        Docs.findOne kiosk.current_checkin_id

    
    Template.registerHelper 'active_term_class', () ->
        found_emotion_avg = 
            Results.findOne 
                model:'emotion_avg'
        if found_emotion_avg
            
            if found_emotion_avg.avg_sent_score < 0
                'red'
            else 
                'green'
    Template.registerHelper 'above_50', (input) ->
        input > .5
    Template.registerHelper 'has_thumbnail', () ->
        @thumbnail and @thumbnail not in ['self','default']
    
    Template.registerHelper 'hostname', () -> 
        window.location.hostname
    
    # Template.registerHelper '_resident', () -> 
    #     Meteor.users.findOne @resident_user_id
        
        
    Template.registerHelper 'string', () -> 
        JSON.stringify(@) 
    Template.registerHelper 'is_checked_in', () -> 
        Meteor.user().checked_in
    Template.registerHelper 'points_to_coins', (input) -> input/100
    
    Template.registerHelper 'all_docs', () -> Docs.find()
    
    Template.registerHelper 'parent', () -> Template.parentData()
    Template.registerHelper '_parent_doc', () ->
        Docs.findOne @parent_id
        # Template.parentData()
    
    Template.registerHelper 'model_docs_helper', (model)->
        Docs.find 
            model:model
    Template.registerHelper 'current_kiosk_doc', () ->
        kiosk = Docs.findOne model:'kiosk'
        Docs.findOne 
            _id:kiosk.current_doc_id
    Template.registerHelper 'kiosk_doc', () ->
        Docs.findOne model:'kiosk'
    Template.registerHelper '_recipient', () -> 
        Meteor.users.findOne 
            _id:@recipient_id

    Template.registerHelper 'id_from_building_number', () -> 
        found = 
            Docs.findOne 
                model:'building'
                building_number:@building_number
        if found 
            found._id
    Template.registerHelper 'is_connected', () -> Meteor.status().connected
    
    Template.registerHelper 'in_role', (role) -> 
        if Meteor.user()
            Meteor.user().roles and role in Meteor.user().roles
            
    Template.registerHelper 'sorting_up', () ->
        parseInt(Session.get('sort_direction')) is 1
    
    Template.registerHelper 'skv_is', (key,value)->
        Session.equals(key,value)
    
    Template.registerHelper 'is_loading', () -> Session.get 'loading'
    # Template.registerHelper 'is_author', ()-> @_author_id is Meteor.userId()
    # Template.registerHelper 'is_grandparent_author', () ->
    #     grandparent = Template.parentData(2)
    #     grandparent._author_id is Meteor.userId()
    Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed(0)
    # Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
    Template.registerHelper 'today', () -> moment(Date.now()).format("dddd, MMMM Do a")
    Template.registerHelper 'int', (input) -> input.toFixed(0)
    Template.registerHelper '_when', () -> moment(@_timestamp).fromNow()
    Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
    Template.registerHelper 'from_now_utc', (input) -> moment(input).utc().fromNow()
    Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
    # Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
    
    
    Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
    Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")
    
    
    Template.registerHelper 'total_potential_revenue', () ->
        @price_per_serving * @servings_amount
    
    # Template.registerHelper 'servings_available', () ->
    #     @price_per_serving * @servings_amount
    
    Template.registerHelper 'session_get', (key)-> Session.get(key)
    
    Template.registerHelper 'key_value_is', (key, value)->
        @["#{key}"] is value
    
    Template.registerHelper 'is', (key, value)->
        key is value
    
    Template.registerHelper 'parent_is', (key, value)->
        Template.parentData()["#{key}"] is value
        # key is value
    
    Template.registerHelper 'parent_key_value_is', (key, value)->
        @["#{key}"] is value
    
    
    
    # Template.registerHelper 'parent_template', () -> Template.parentData()
        # Session.get 'displaying_profile'
    
    # Template.registerHelper 'checking_in_doc', () ->
    #     Docs.findOne
    #         model:'healthclub_session'
    #         current:true
    #      # Session.get('session_document')
    
    # Template.registerHelper 'current_session_doc', () ->
    #         Docs.findOne
    #             model:'healthclub_session'
    #             current:true
    
    
    
    
    Template.registerHelper 'template_parent', () ->
        Template.parentData()
    
    
    
    Template.registerHelper 'nl2br', (text)->
        nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
        new Spacebars.SafeString(nl2br)
    
    
    Template.registerHelper 'loading_class', () ->
        if Session.get 'loading' then 'disabled' else ''
    
    Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()
    
    # Template.registerHelper 'data_doc', ->
    #     if Router.current().params.doc_id
    #         doc = Docs.findOne Router.current().params.doc_id
    #         # if doc then doc
    #     # else 
    #     #     @
    # Template.registerHelper 'user_from_user_id_param', () ->
    #     found = Meteor.users.findOne _id:Router.current().params.user_id
    #     found
    
    
    
    Template.registerHelper 'calculated_size', (metric) ->
        whole = parseInt(@["#{metric}"]*10)
    
        if whole is 2 then 'f2'
        else if whole is 3 then 'f3'
        else if whole is 4 then 'f4'
        else if whole is 5 then 'f5'
        else if whole is 6 then 'f6'
        else if whole is 7 then 'f7'
        else if whole is 8 then 'f8'
        else if whole is 9 then 'f9'
        else if whole is 10 then 'f10'
    
    Template.registerHelper 'unescaped', () ->
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.selftext_html
        return txt.value
    
            # html.unescape(@rd.selftext_html)
    Template.registerHelper 'unescaped_content', () ->
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.media_embed.content
        return txt.value
        
    Template.registerHelper 'session_key_value_is', (key, value) ->
        Session.equals key,value
    
    Template.registerHelper 'key_value_is', (key, value) ->
        @["#{key}"] is value
    
    
    Template.registerHelper 'template_subs_ready', () ->
        Template.instance().subscriptionsReady()
    
    Template.registerHelper 'global_subs_ready', () ->
        Session.get('global_subs_ready')
    
    
    Template.registerHelper 'sval', (input)-> Session.get(input)
    Template.registerHelper 'is_loading', -> Session.get 'is_loading'
    Template.registerHelper 'fixed', (number)->
        (number/100).toFixed()
    # Template.registerHelper 'to_percent', (number)->
    #     (number*100).toFixed()
    
    Template.registerHelper 'is_image', () ->
        # regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
        # match = @url.match(regExp)
        # if match then true
        # true
        regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
        match = @url.match(regExp)
        if match then true
        # true
    
    
    
    Template.registerHelper 'loading_class', ()->
        if Session.get 'loading' then 'disabled' else ''
    
    
    Template.registerHelper 'comma', (input) ->
        input.toLocaleString("en-US")
    Template.registerHelper 'emotion_color', () ->
        if @sentiment
            if @sentiment is 'positive' then 'green' else 'red'
        # if @max_emotion_name
        #     switch @max_emotion_name
        #         when 'sadness' then 'blue'
        #         when 'joy' then 'green'
        #         when 'confident' then 'teal'
        #         when 'analytical' then 'orange'
        #         when 'tentative' then 'yellow'
        # else if @doc_sentiment_label
        #     if @doc_sentiment_label is 'positive' then 'green'
        #     else if @doc_sentiment_label is 'negative' then 'red'
    Template.registerHelper 'current_viewer_users', () -> 
        Meteor.users.find 
            current_viewing_doc_id:Router.current().params.doc_id
if Meteor.isServer 
    Meteor.publish 'current_viewers', (doc_id)->
        Meteor.users.find 
            current_viewing_doc_id:doc_id
        
if Meteor.isClient
    # Template.registerHelper 'user_group_memberships', () -> 
    #     user = Meteor.users.findOne username:@username
    #     Docs.find
    #         model:'group'
    #         member_ids: $in:[user._id]

    
    Template.registerHelper 'unread_log_docs', () -> 
        Docs.find {
            model:'log'
            read_user_ids:$nin:[Meteor.userId()]
        },
            sort:_timestamp:-1
        
    Template.registerHelper 'user_friended', (user) ->
        if user
            Meteor.users.find 
                _id:$in:user.friended_user_ids
    Template.registerHelper '_viewers', () ->
        if @read_user_ids
            Meteor.users.find 
                _id:$in:@read_user_ids
    Template.registerHelper 'user_friended_by', (user) ->
        if user
            Meteor.users.find 
                _id:$in:user.friended_by_user_ids
    Template.registerHelper 'darkmode_class', () -> 
        if Meteor.user()
            if Meteor.user().darkmode then 'invert' else ''
        else 
            if Session.get('darkmode') then 'invert' else ''
            
            
    Template.registerHelper 'is_darkmode', () -> 
        if Meteor.user()
            if Meteor.user().darkmode then true else false
        else 
            if Session.get('darkmode') then true else false
    
    Template.registerHelper 'hostname', () -> 
        window.location.hostname
    
    Template.registerHelper 'following_users', () -> 
        Meteor.users.find 
            _id:$in:@following_user_ids
    
    Template.registerHelper 'all_docs', () -> Docs.find()
    Template.registerHelper 'one_result', () -> Docs.find(model:Session.get('model')).count() is 1
    Template.registerHelper 'two_results', () -> Docs.find(model:Session.get('model')).count() is 2
    
    
    Template.registerHelper 'parent', () -> Template.parentData()
    Template.registerHelper '_parent_doc', () ->
        Docs.findOne @parent_id
        # Template.parentData()
    Template.registerHelper 'sort_label', () -> Session.get('sort_label')
    Template.registerHelper 'sort_icon', () -> Session.get('sort_icon')
    Template.registerHelper 'current_limit', () -> parseInt(Session.get('limit'))
    
    Template.registerHelper 'current_time', () -> moment().format("h:mm a")
    Template.registerHelper 'current_date', () -> moment().format("MMM Do")
    Template.registerHelper 'subs_ready', () -> 
        Template.instance().subscriptionsReady()
    
    Template.registerHelper 'related_group_doc', () -> 
        Docs.findOne 
            model:'group'
            _id:@group_id
    Template.registerHelper 'is_editing', () -> Session.equals 'editing_id', @_id

    Template.registerHelper 'user_groups', () ->
        if @group_membership_ids
            Docs.find 
                model:'group'
                _id:$in:@group_membership_ids
    Template.registerHelper 'user_model_docs', (model) -> 
        username = Router.current().params.username
        Meteor.users.findOne username:username
        Docs.find {
            model:model
            _author_username:username
        }, sort:_timestamp:-1
        
    Template.registerHelper 'model_docs', (model) -> 
        Docs.find 
            model:model
        
    Template.registerHelper 'is_connected', () -> Meteor.status().connected
    
    Template.registerHelper 'is_author', () -> 
        @_author_id is Meteor.userId()
    Template.registerHelper 'current_lat', () -> 
        Session.get('current_lat')
    Template.registerHelper 'current_long', () -> 
        Session.get('current_long')
    # Template.registerHelper 'current_username', () ->
    #     Router.current().params.username
    
    Template.registerHelper 'rental', () ->
        Docs.findOne @rental_id
        # Template.parentData()
    
    
    Template.registerHelper '_target', () ->
        if @target_id
            Meteor.users.findOne
                _id: @target_id
        # else if @recipient_id
        #     Meteor.users.findOne
        #         _id: @recipient_id
    
    Template.registerHelper 'sorting_up', () ->
        parseInt(Session.get('sort_direction')) is 1
    
    Template.registerHelper 'user_from_id', (id)->
        Meteor.users.findOne id
        
        
    Template.registerHelper 'skv_is', (key,value)->
        Session.equals(key,value)
    
    
    Template.registerHelper 'group_doc', () ->
        Docs.findOne 
            model:'group'
            _id:@group_id
    
    Template.registerHelper 'gs', () ->
        Docs.findOne
            model:'global_settings'
    Template.registerHelper 'display_mode', () -> Session.get('display_mode',true)
    Template.registerHelper 'is_loading', () -> Session.get 'loading'
    # Template.registerHelper 'is_author', ()-> @_author_id is Meteor.userId()
    # Template.registerHelper 'is_grandparent_author', () ->
    #     grandparent = Template.parentData(2)
    #     grandparent._author_id is Meteor.userId()
    # Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed()
    Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed(0)
    Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
    Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm a")
    Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
    Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
    Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
    # Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
    Template.registerHelper 'today', () -> moment(Date.now()).format("dddd, MMMM Do a")
    Template.registerHelper 'fixed', (input) ->
        if input
            input.toFixed(2)
    Template.registerHelper 'int', (input) -> input.toFixed(0)
    Template.registerHelper '_when', () -> moment(@_timestamp).fromNow()
    Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
    Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
    # Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
    Template.registerHelper 'upvote_class', () ->
        if Meteor.userId()
            if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else 'outline'
        else ''
    Template.registerHelper 'downvote_class', () ->
        if Meteor.userId()
            if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else 'outline'
        else ''
    
    Template.registerHelper '_upvoters', () ->
        Meteor.users.find 
            _id:$in:@upvoter_ids
    Template.registerHelper '_downvoters', () ->
        Meteor.users.find 
            _id:$in:@downvoter_ids
    
    
    Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
    Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")
    
    
    Template.registerHelper 'current_doc', () -> Docs.findOne Router.current().params.doc_id
    
    Template.registerHelper 'total_potential_revenue', () ->
        @price_per_serving * @servings_amount
    
    # Template.registerHelper 'servings_available', () ->
    #     @price_per_serving * @servings_amount
    
    Template.registerHelper 'session_is', (key, value)-> Session.equals(key, value)
    
    Template.registerHelper 'key_value_is', (key, value)->
        @["#{key}"] is value
    
    Template.registerHelper 'is', (key, value)->
        key is value
    
    Template.registerHelper 'parent_is', (key, value)->
        Template.parentData()["#{key}"] is value
        # key is value
    
    Template.registerHelper 'parent_key_value_is', (key, value)->
        @["#{key}"] is value
    
    
    
    # Template.registerHelper 'parent_template', () -> Template.parentData()
        # Session.get 'displaying_profile'
    
    # Template.registerHelper 'checking_in_doc', () ->
    #     Docs.findOne
    #         model:'healthclub_session'
    #         current:true
    #      # Session.get('session_document')
    
    # Template.registerHelper 'current_session_doc', () ->
    #         Docs.findOne
    #             model:'healthclub_session'
    #             current:true
    
    
    
    # Template.registerHelper 'checkin_guest_docs', () ->
    #     Docs.findOne Router.current().params.doc_id
    #     session_document = Docs.findOne Router.current().params.doc_id
    #     Docs.find
    #         _id:$in:session_document.guest_ids
    
    
    Template.registerHelper '_author', () -> Meteor.users.findOne @_author_id
    Template.registerHelper 'is_text', () ->
        @field_type is 'text'
    
    Template.registerHelper 'template_parent', () ->
        Template.parentData()
    
    
    
    Template.registerHelper 'nl2br', (text)->
        nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
        new Spacebars.SafeString(nl2br)
    
    
    Template.registerHelper 'loading_class', () ->
        if Session.get 'loading' then 'disabled' else ''
    
    Template.registerHelper 'in_list', (key) ->
        if Meteor.userId()
            if @["#{key}"]
                if Meteor.userId() in @["#{key}"] then true else false
    
    
    Template.registerHelper 'current_user', () ->  
        Meteor.users.findOne username:Router.current().params.username
    Template.registerHelper 'order_rental', -> 
        Docs.findOne 
            _id:@rental_id
        
        
    Template.registerHelper 'can_edit', () ->
        # Session.equals('current_username',@_author_username)
        if Meteor.user()
            if Meteor.userId() is @_author_id 
                true
            else Meteor.user().admin_mode
    
    Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()
    
    # Template.registerHelper 'data_doc', ->
    #     if Router.current().params.doc_id
    #         doc = Docs.findOne Router.current().params.doc_id
    #         # if doc then doc
    #     # else 
    #     #     @
    
    Template.registerHelper 'user_from_username_param', () ->
        found = Meteor.users.findOne username:Router.current().params.username
        found
    # Template.registerHelper 'user_from_user_id_param', () ->
    #     found = Meteor.users.findOne _id:Router.current().params.user_id
    #     found
    Template.registerHelper 'field_value', () ->
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)
    
    
        if @direct
            parent = Template.parentData()
        else if parent5
            if parent5._id
                parent = Template.parentData(5)
        else if parent6
            if parent6._id
                parent = Template.parentData(6)
        if parent
            parent["#{@key}"]
    
    
    Template.registerHelper 'sorted_field_values', () ->
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)
    
    
        if @direct
            parent = Template.parentData()
        else if parent5._id
            parent = Template.parentData(5)
        else if parent6._id
            parent = Template.parentData(6)
        if parent
            _.sortBy parent["#{@key}"], 'number'
    
    
    
    Template.registerHelper 'calculated_size', (metric) ->
        whole = parseInt(@["#{metric}"]*10)
    
        if whole is 2 then 'f2'
        else if whole is 3 then 'f3'
        else if whole is 4 then 'f4'
        else if whole is 5 then 'f5'
        else if whole is 6 then 'f6'
        else if whole is 7 then 'f7'
        else if whole is 8 then 'f8'
        else if whole is 9 then 'f9'
        else if whole is 10 then 'f10'
    
    
    
    Template.registerHelper 'in_dev', () -> Meteor.isDevelopment
    
    Template.registerHelper 'is_current_user', (key, value)->
        if Meteor.user()
            Meteor.user().username is Router.current().params.username    