if Meteor.isClient
    Router.route '/food/', (->
        @layout 'layout'
        @render 'food'
        ), name:'food'
    Router.route '/food/:doc_id', (->
        @layout 'layout'
        @render 'food_page'
        ), name:'food_page'
        
    @picked_food_tags = new ReactiveArray()
    
    
    Template.food.onCreated ->
        @autorun => Meteor.subscribe 'food_counter', ->
    Template.food.helpers
        food_count: -> Counts.get('food_counter') 
    
if Meteor.isServer
    Meteor.publish 'food_counter', (model)->
        # if model 
        Counts.publish this, 'food_counter', 
            Docs.find({
                model:'recipe'
            })
        return undefined    # otherwise coffeescript returns a Counts.publish

if Meteor.isClient    
    Template.agg_food_tag.onCreated ->
        # console.log @
        @autorun => @subscribe 'food_tag_image', @data.name,->
    Template.agg_food_tag.helpers
        term_image: ->
            # console.log Template.currentData().name
            found = Docs.findOne {
                model:'recipe'
                tags:$in:[Template.currentData().name]
                # "watson.metadata.image":$exists:true
            }, sort:ups:-1
            # console.log 'found image', found
            found
    Template.unpick_food_tag.onCreated ->
        # console.log @
        @autorun => @subscribe 'food_tag_image', @data.name,->
    Template.unpick_food_tag.helpers
        flat_term_image: ->
            # console.log Template.currentData()
            found = Docs.findOne {
                model:'recipe'
                tags:$in:[Template.currentData()]
                # "watson.metadata.image":$exists:true
            }, sort:ups:-1
            # console.log 'found flat image', found.watson.metadata.image
            found.image

    Template.unpick_food_tag.events
        'click .unpick_tag': ->
            picked_food_tags.remove @valueOf()
            window.speechSynthesis.speak new SpeechSynthesisUtterance "removing #{@valueOf()}"
        
    Template.agg_food_tag.events
        'click .result': (e,t)->
            # Meteor.call 'log_term', @title, ->
            picked_food_tags.push @name
            $('#search').val('')
            # Session.set('full_doc_id', null)
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
            Session.set('current_search', null)
            Session.set('searching', true)
            Session.set('is_loading', true)
            # Meteor.call 'call_wiki', @name, ->
    
            # Meteor.call 'call_food', picked_tags.array(), ->
            Meteor.call 'call_food', @name, ->
                Session.set('is_loading', false)
                Session.set('searching', false)
    
    Template.food_page.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.food.onCreated ->
        document.title = 'gr food'
        
        # @autorun => @subscribe 'model_docs','artist', ->
        @autorun => @subscribe 'food_facets',
            picked_food_tags.array()
            Session.get('title')
        @autorun => @subscribe 'food_results',
            picked_food_tags.array()
            Session.get('title')




    Template.food_page.onRendered ->
        # console.log @
        found_doc = Docs.findOne Router.current().params.doc_id
        if found_doc 
            unless found_doc.watson
                Meteor.call 'call_watson',Router.current().params.doc_id,'content','html', ->
                    console.log 'autoran watson'
            unless found_doc.details 
                Meteor.call 'recipe_details', Router.current().params.doc_id, ->
                    console.log 'pulled recipe details'
    # Template.recipe_card.onRendered ->
    # Template.recipe_card. ->
    #     console.log @
    #     # found_doc = Docs.findOne Template.currentData()
    #     unless @data.watson
    #         Meteor.call 'call_watson',@data._id,'content','html', ->
    #             console.log 'autoran watson'
    #     unless @data.details 
    #         Meteor.call 'recipe_details', @data._id, ->
    #             console.log 'pulled recipe details'
                
    
    Template.food_page.helpers
        instruction_steps: ->
            console.log @
            console.log @details.analyzedInstructions[0]
            @details.analyzedInstructions[0].steps
            
    Template.recipe_card.events
        'click .call_watson': ->
            unless @details 
                Meteor.call 'recipe_details', @_id, ->
                    console.log 'pulled recipe details'
            unless @watson
                Meteor.call 'call_watson',@_id,'content','html', ->
                    console.log 'autoran watson'
            
        'click .pick_food_tag': ->
            picked_food_tags.clear()
            picked_food_tags.push @valueOf()
            Meteor.call 'call_food', @valueOf(), ->
            
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
    Template.food_page.events
        'click .pick_food_tag': ->
            Router.go "/food"
            picked_food_tags.clear()
            picked_food_tags.push @valueOf()
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

            Meteor.call 'call_food', @valueOf(), ->
        'click .get_details': ->
            Meteor.call 'recipe_details', @_id, ->
    Template.recipe_card_big.events
        'click .pick_food_tag': ->
            picked_food_tags.clear()
            picked_food_tags.push @valueOf()
            Meteor.call 'call_food', @valueOf(), ->
    Template.food.events
        'keyup .food_search': (e,t)->
            # console.log 'hi'
            query = t.$('.food_search').val()
            Session.set('food_search',query)
            if e.which is 13
                $('body').toast({
                    title: "browsing #{query}"
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
                Meteor.call 'call_food', Session.get('food_search'), ->
                    $('body').toast({
                        title: "searched #{query}"
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
                t.$('.food_search').val('')
                picked_food_tags.push query
            
    Template.food.helpers
        one_recipe: -> 
            # console.log 'hi', Docs.find({model:'recipe'}).count() 
            Docs.find({
                model:'recipe', 
                tags:$in:picked_food_tags.array()
            }).count() is 1
        two_recipes: -> 
            # console.log 'hi', Docs.find({model:'recipe'}).count() 
            Docs.find({
                model:'recipe', 
                tags:$in:picked_food_tags.array()
            }).count() is 2
        one_doc: ->
            Docs.findOne(model:'recipe')
        food_docs: ->
            Docs.find 
                model:'food'
        recipe_docs: ->
            Docs.find {
                model:'recipe'
            }, sort:_timestamp:-1
            
        picked_food_tags: -> picked_food_tags.array()
        tag_results: ->
            Results.find()
        
            
            
            
            
if Meteor.isServer
    Meteor.methods 
        recipe_details: (doc_id)->
            doc = Docs.findOne doc_id
            HTTP.get "https://api.spoonacular.com/recipes/#{doc.id}/information/?includeNutrition=false&apiKey=e52f2f2ca01a448e944d94194e904775&",(err,res)=>
                # console.log res.data
                Docs.update doc_id, 
                    $set:
                        details:res.data
                        
                
        call_food: (search)->
            console.log 'calling', search
            # HTTP.get "https://api.spoonacular.com/mealplanner/generate?apiKey=e52f2f2ca01a448e944d94194e904775&timeFrame=day&targetCalories=#{calories}",(err,res)=>
            HTTP.get "https://api.spoonacular.com/food/search?apiKey=e52f2f2ca01a448e944d94194e904775&query=#{search}",(err,res)=>
                # console.log res.data
                for result in res.data.searchResults
                    # console.log result.name
                    # if result.name is 'Recipes'
                    recipes = _.where(res.data.searchResults, {name:'Recipes'})
                    for recipe in recipes[0].results
                        # console.log recipe
                        found_recipe = 
                            Docs.findOne 
                                model:'recipe'
                                id:recipe.id
                        if found_recipe
                            Docs.update found_recipe._id, 
                                $inc:hits:1
                                $addToSet:
                                    tags:search
                        unless found_recipe
                            new_id = Docs.insert 
                                model:'recipe'
                                id:recipe.id
                                name:recipe.name
                                image:recipe.image
                                link:recipe.link
                                tags:[search]
                                type:recipe.type
                                relevance:recipe.relevance
                                content:recipe.content
                            Meteor.call 'recipe_details', new_id, ->

                    # recipes = res.data.searchResults
                    
                    # console.log response.data.searchResults.results
            
            
if Meteor.isServer
    Meteor.publish 'food_facets', (
        picked_food_tags=[]
        name_search=''
        )->
    
            self = @
            match = {}
    
            # match.tags = $all: picked_food_tags
            match.model = $in:['recipe']
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
            if name_search.length > 1
                match.name = {$regex:"#{name_search}", $options: 'i'}

            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_food_tags.length > 0 then match.tags = $all: picked_food_tags
            # if picked_styles.length > 0 then match.strStyle = $all: picked_styles
            # if picked_moods.length > 0 then match.strMood = $all: picked_moods
            # if picked_genres.length > 0 then match.strGenre = $all: picked_genres

            total_count = Docs.find(match).count()
            # console.log 'total count', total_count
            # console.log 'facet match', match
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: '$tags', count: $sum: 1 }
                { $match: _id: $nin: picked_food_tags }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 15}
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
                    
            self.ready()

    Meteor.publish 'food_tag_image', (
        term=null
        # porn=false
        )->
        # added_tags = []
        # console.log 'match term', term
        # console.log 'match picked tags', picked_tags
        # if picked_tags.length > 0
        #     added_tags = picked_tags.push(term)
        match = {
            model:'recipe'
            tags: $in: [term]
            # "watson.metadata.image": $exists:true
            # $where: "this.watson.metadata.image.length > 1"
        }
        # if porn
        # match.over_18 = porn
        # else 
        # added_tags = [term]
        # match = {model:'reddit'}
        # match.thumbnail = $nin:['default','self']
        # match.url = { $regex: /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/, $options: 'i' }
        # console.log "added tags", added_tags
        # console.log 'looking up added tags', added_tags
        # found = Docs.findOne match
        # console.log "TERM", term, found.
        # if found
        #     # console.log "FOUND THUMBNAIL",found.thumbnail
        Docs.find match,{
            limit:1
            sort:
                points:-1
                ups:-1
            fields:
                model:1
                image:1
                tags:1
                url:1
        }


    Meteor.publish 'food_results', (
        picked_food_tags=[]
        name_search=''
        )->
        self = @
        match = {}
        match.model = $in:['recipe']
        
        if picked_food_tags.length > 0 then match.tags = $all: picked_food_tags
        if name_search.length > 1
            match.name = {$regex:"#{name_search}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        # unless Meteor.userId()
        #     match.private = $ne:true
            
        # console.log 'results match', match
        # console.log 'sort_key', sort_key
        # console.log 'sort_direction', sort_direction
        # console.log 'limit', limit
        
        Docs.find match,
            sort:_timestamp:-1
            limit:10
            # fields: 
            #     strArtistFanart:1
            #     strArtistThumb:1
            #     strArtistLogo:1
            #     strArtist:1
            #     strGenre:1
            #     strStyle:1
            #     strMood:1
            #     _timestamp:1
            #     model:1
            #     tags:1
