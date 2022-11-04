Docs.allow
    insert: (userId, doc) -> 
        true    
            # doc._author_id is userId
    update: (userId, doc) ->
        true
    remove: (userId, doc) ->
        true

Meteor.publish 'count', ->
  Counts.publish this, 'product_counter', Docs.find({model:'product'})
  return undefined    # otherwise coffeescript returns a Counts.publish
                      # handle when Meteor expects a Mongo.Cursor object.


Meteor.publish 'public_posts', (child_id)->
    Docs.find {
        model:'post'
        private:$ne:true
    }, limit:20


Meteor.publish 'model_docs', (
    model
    limit=20
    )->
    Docs.find {
        model: model
        # app:'goldrun'
    }, limit:limit

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug

Meteor.publish 'child_docs', (model,parent_id)->
    Docs.find 
        model:model
        parent_id:parent_id


Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

    
Meteor.methods
    log_view: (doc_id)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $inc:
                views:1
            $set:
                last_viewed_timestamp:Date.now()

    lookup_doc: (guest_name, model_filter)->
        Docs.find({
            model:model_filter
            guest_name: {$regex:"#{guest_name}", $options: 'i'}
            },{limit:10}).fetch()


    # lookup_first_name: (first_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             first_name: {$regex:"#{first_name}", $options: 'i'}
    #             }).fetch()
    #     found_people
    #
    # lookup_last_name: (last_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             last_name: {$regex:"#{last_name}", $options: 'i'}
    #             }).fetch()
    #     found_people



    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()

Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id


Meteor.methods    
    global_remove: (keyname)->
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})



    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id


        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        # )
        
    get_reddit_post: (doc_id, reddit_id, root)->
        doc = Docs.findOne doc_id
        if doc.reddit_id
        else
            
        HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json", (err,res)->
            if err 
                console.log err
            else
                rd = res.data.data.children[0].data
                result =
                    Docs.update doc_id,
                        $set:
                            rd: rd
                # if rd.is_video
                #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                # else if rd.is_image
                #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                # else
                #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                #     # Meteor.call 'call_visual', doc_id, ->
                # if rd.selftext
                #     unless rd.is_video
                #         # if Meteor.isDevelopment
                #         Docs.update doc_id, {
                #             $set:
                #                 body: rd.selftext
                #         }, ->
                #         #     Meteor.call 'pull_site', doc_id, url
                # if rd.selftext_html
                #     unless rd.is_video
                #         Docs.update doc_id, {
                #             $set:
                #                 html: rd.selftext_html
                #         }, ->
                #             # Meteor.call 'pull_site', doc_id, url
                # if rd.url
                #     unless rd.is_video
                #         url = rd.url
                #         # if Meteor.isDevelopment
                #         Docs.update doc_id, {
                #             $set:
                #                 reddit_url: url
                #                 url: url
                #         }, ->
                #             # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                # # update_ob = {}

                Docs.update doc_id,
                    $set:
                        rd: rd
                        url: rd.url
                        thumbnail: rd.thumbnail
                        subreddit: rd.subreddit
                        author: rd.author
                        is_video: rd.is_video
                        ups: rd.ups
                        # downs: rd.downs
                        over_18: rd.over_18
                    # $addToSet:
                    #     tags: $each: [rd.subreddit.toLowerCase()]

            
Meteor.publish 'agg_emotions', (
    # group
    picked_tags
    dummy
    # picked_time_tags
    # selected_location_tags
    # selected_people_tags
    # picked_max_emotion
    # picked_timestamp_tags
    )->
    # @unblock()
    self = @
    match = {
        model:'reddit'
        # group:group
        joy_percent:$exists:true
    }
        
    doc_count = Docs.find(match).count()
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    # if picked_max_emotion.length > 0 then match.max_emotion_name = $all:picked_max_emotion
    # if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    # if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    # if selected_people_tags.length > 0 then match.people_tags = $all:selected_people_tags
    # if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags
    
    emotion_avgs = Docs.aggregate [
        { $match: match }
        #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
        { $group: 
            _id:null
            avg_sent_score: { $avg: "$doc_sentiment_score" }
            avg_joy_score: { $avg: "$joy_percent" }
            avg_anger_score: { $avg: "$anger_percent" }
            avg_sadness_score: { $avg: "$sadness_percent" }
            avg_disgust_score: { $avg: "$disgust_percent" }
            avg_fear_score: { $avg: "$fear_percent" }
        }
    ]
    emotion_avgs.forEach (res, i) ->
        self.added 'results', Random.id(),
            model:'emotion_avg'
            avg_sent_score: res.avg_sent_score
            avg_joy_score: res.avg_joy_score
            avg_anger_score: res.avg_anger_score
            avg_sadness_score: res.avg_sadness_score
            avg_disgust_score: res.avg_disgust_score
            avg_fear_score: res.avg_fear_score
    self.ready()    



Meteor.methods 
    get_reddit_comments: (post_id)->
        post =
            Docs.findOne post_id
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
        link = "http://reddit.com/comments/#{post.reddit_id}?depth=1"
        HTTP.get link,(err,response)=>
            # if response.data.data.dist > 1
            #     _.each(response.data.data.children, (item)=>
                    # unless item.domain is "OneWordBan"
                    #     data = item.data

    
Meteor.publish 'post_tag_results', (
    picked_tags=null
    picked_subreddit=null
    picked_author=null
    # query
    porn=false
    # searching
    dummy
    )->

    self = @
    match = {}

    # match.model = $in: ['reddit','wikipedia']
    match.model = 'reddit'
    # if query
    # if view_nsfw
    match.over_18 = porn
    if picked_tags and picked_tags.length > 0
        match.tags = $all: picked_tags
        if picked_subreddit
            match.subreddit = picked_subreddit
        limit = 20
        # else
        #     limit = 10
        #     match._timestamp = $gt:moment().subtract(1, 'days')
        # else /
            # match.tags = $all: picked_tags
        agg_doc_count = Docs.find(match).count()
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $match: count: $lt: agg_doc_count }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 11 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
    
        tag_cloud.forEach (tag, i) =>
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
                # index: i
        subreddit_cloud = Docs.aggregate [
            { $match: match }
            { $project: "subreddit": 1 }
            # { $unwind: "$tags" }
            { $group: _id: "$subreddit", count: $sum: 1 }
            { $match: _id: $ne: picked_subreddit }
            { $match: count: $lt: agg_doc_count }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 11 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
    
        subreddit_cloud.forEach (sub, i) =>
            self.added 'results', Random.id(),
                name: sub.name
                count: sub.count
                model:'subreddit'
                # index: i
        
        self.ready()
        # else []

Meteor.publish 'tag_image', (
    term=null
    porn=false
    )->
    # added_tags = []
    # if picked_tags.length > 0
    #     added_tags = picked_tags.push(term)
    match = {
        model:'reddit'
        tags: $in: [term]
        # "watson.metadata.image": $exists:true
        # $where: "this.watson.metadata.image.length > 1"
    }
    # if porn
    match.over_18 = porn
    # else 
    # added_tags = [term]
    # match = {model:'reddit'}
    # match.thumbnail = $nin:['default','self']
    # match.url = { $regex: /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/, $options: 'i' }
    # found = Docs.findOne match
    # if found
    Docs.find match,{
        limit:1
        sort:
            points:-1
            ups:-1
        # fields:
        #     "watson.metadata.image":1
        #     model:1
        #     thumbnail:1
        #     tags:1
        #     ups:1
        #     over_18:1
        #     url:1
    }
    # else
    #     backup = 
    #         Docs.findOne 
    #             model:'reddit'
    #             thumbnail:$exists:true
    #             tags:$in:[term]
    #     if backup
    #         Docs.find { 
    #             model:'reddit'
    #             thumbnail:$exists:true
    #             tags:$in:[term]
    #         }, 
    #             limit:1
    #             sort:ups:1
Meteor.publish 'reddit_doc_results', (
    picked_tags=null
    picked_subreddit=null
    porn=false
    sort_key='_timestamp'
    sort_direction=-1
    # dummy
    # current_query
    # date_setting
    )->
    # else
    self = @
    # match = {model:$in:['reddit','wikipedia']}
    match = {model:'reddit'}
    # match.over_18 = $ne:true
    #         yesterday = now-day
    #         match._timestamp = $gt:yesterday
    # if picked_subreddit
    #     match.subreddit = picked_subreddit
    # if porn
    match.over_18 = porn
    # if picked_tags.length > 0
    #     # if picked_tags.length is 1
    #     #     found_doc = Docs.findOne(title:picked_tags[0])
    #     #
    #     #     match.title = picked_tags[0]
    #     # else
    if picked_tags and picked_tags.length > 0
        match.tags = $all: picked_tags
    else 
        match._timestamp = $gt:moment().subtract(1, 'days')
    Docs.find match,
        sort:
            "#{sort_key}":sort_direction
            points:-1
            ups:-1
        limit:42
        fields:
            # youtube_id:1
            "rd.media_embed":1
            "rd.url":1
            "rd.thumbnail":1
            "rd.analyzed_text":1
            subreddit:1
            thumbnail:1
            doc_sentiment_label:1
            doc_sentiment_score:1
            joy_percent:1
            sadness_percent:1
            fear_percent:1
            disgust_percent:1
            anger_percent:1
            happy_votes:1
            sad_votes:1
            angry_votes:1
            fearful_votes:1
            disgust_votes:1
            funny_votes:1
            over_18:1
            points:1
            upvoter_ids:1
            downvoter_ids:1
            url:1
            ups:1
            "watson.metadata":1
            "watson.analyzed_text":1
            title:1
            model:1
            num_comments:1
            tags:1
            _timestamp:1
            domain:1
    # else 
    #     Docs.find match,
    #         sort:_timestamp:-1
    #         limit:10



Meteor.methods
    search_reddit: (query,porn=false)->
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
        if porn 
            link = "http://reddit.com/search.json?q=#{query}&nsfw=1&include_over_18=on"
        else
            link = "http://reddit.com/search.json?q=#{query}&nsfw=0&include_over_18=off"
        HTTP.get link,(err,response)=>
            if response.data.data.dist > 1
                _.each(response.data.data.children, (item)=>
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        # added_tags = _.flatten(added_tags)
                        reddit_post =
                            reddit_id: data.id
                            url: data.url
                            domain: data.domain
                            comment_count: data.num_comments
                            permalink: data.permalink
                            title: data.title
                            # root: query
                            ups:data.ups
                            num_comments:data.num_comments
                            # selftext: false
                            points:0
                            over_18:data.over_18
                            thumbnail: data.thumbnail
                            tags: query
                            model:'reddit'
                        existing_doc = Docs.findOne url:data.url
                        if existing_doc
                            # if Meteor.isDevelopment
                            if typeof(existing_doc.tags) is 'string'
                                Docs.update existing_doc._id,
                                    $unset: tags: 1
                            Docs.update existing_doc._id,
                                $addToSet: tags: $each: query
                                $set:
                                    title:data.title
                                    ups:data.ups
                                    num_comments:data.num_comments
                                    over_18:data.over_18
                                    thumbnail:data.thumbnail
                                    permalink:data.permalink
                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                            # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                        unless existing_doc
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                            # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                        return true
                )
