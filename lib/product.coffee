if Meteor.isClient
    Router.route '/products/', (->
        @layout 'layout'
        @render 'products'
        ), name:'products'
    Router.route '/product/:doc_id', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'
    
    Template.products.onCreated ->
        @autorun => Meteor.subscribe 'product_counter', ->
    Template.products.helpers
        product_count: -> Counts.get('product_counter') 

    
if Meteor.isServer
    Meteor.publish 'model_counter', (model)->
        if model 
            Counts.publish this, 'model_counter', 
                Docs.find({
                    model:model
                })
            return undefined    # otherwise coffeescript returns a Counts.publish

if Meteor.isClient 
    Template.product_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.products.onCreated ->
        document.title = 'gr shop'
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'gr shop'
        
        # @autorun => @subscribe 'model_docs','artist', ->
        @autorun => @subscribe 'product_facets',
            picked_tags.array()
            Session.get('product_search')
        @autorun => @subscribe 'product_results',
            picked_tags.array()
            Session.get('product_search')

    Template.product_view.onRendered ->
        # console.log @
        found_doc = Docs.findOne Router.current().params.doc_id
        if found_doc 
            unless found_doc.watson
                Meteor.call 'call_watson',Router.current().params.doc_id,'content','html', ->
                    console.log 'autoran watson'
            unless found_doc.details 
                Meteor.call 'product_details', Router.current().params.doc_id, ->
                    console.log 'pulled product details'
                
    Template.product_view.helpers
        split_ingredient_list: ->
            @ingredientList.split ','
        instruction_steps: ->
            console.log @
            console.log @details.analyzedInstructions[0]
            @details.analyzedInstructions[0].steps
            
    Template.product_view.events
        'click .pick_product_tag': ->
            picked_tags.push @valueOf()
            Router.go "/products"
            $('body').toast(
                message: "searching #{@valueOf()}"
                showIcon: 'search'
                # showProgress: 'bottom'
                class: 'info'
                # displayTime: 'auto',
                position: "bottom right"
            )
            
            Meteor.call 'call_product', @valueOf(), ->
                $('body').toast(
                    message: "searched #{@valueOf()}"
                    showIcon: 'search'
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
        'click .get_details': ->
            Meteor.call 'product_details', @_id, ->
            
            
if Meteor.isClient
    Template.product_item.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.product_item.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_item': ->
        #     $('.container_')

    Template.product_item.helpers
        product_item_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
        
        
        
    Template.product_item.events
        'click .add_to_cart': (e,t)->
            $(e.currentTarget).closest('.card').transition('bounce',500)
            Meteor.call 'add_to_cart', @_id, =>
                $('body').toast(
                    showIcon: 'cart plus'
                    message: "#{@title} added"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom center"
                )
            
            
            
    Template.products.helpers
        product_docs: ->
            Docs.find 
                model:'product'
        product_docs: ->
            Docs.find {
                model:'product'
            }, sort:_timestamp:-1
            
        picked_tags: -> picked_tags.array()
        tag_results: ->
            Results.find()
        
    Template.products.events 
        'click .pick_tag': ->
            picked_tags.push @name
            $('body').toast({
                title: "searching #{@name}"
                # message: 'Please see desk staff for key.'
                class : 'info'
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
            
            Meteor.call 'call_product', @name, (err,res)->
                $('body').toast({
                    title: "#{res} search complete"
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
                
            
        'click .unpick_tag': ->
            picked_tags.remove @valueOf()
        
        'keyup .product_search': (e,t)->
            console.log 'hi'
            query = t.$('.product_search').val()
            Session.set('product_search',query)
            if e.which is 13
                Meteor.call 'call_product', Session.get('product_search'), ->

            
        'keyup .menu_search': (e,t)->
            console.log 'hi'
            query = t.$('.menu_search').val()
            Session.set('menu_search',query)
            if e.which is 13
                Meteor.call 'search_menu', Session.get('menu_search'), ->

            
            
if Meteor.isServer
    Meteor.methods 
        product_details: (doc_id)->
            doc = Docs.findOne doc_id
            console.log 'getting product details', doc
            # HTTP.get "https://api.spoonacular.com/food/products/#{doc.id}/&apiKey=e52f2f2ca01a448e944d94194e904775",(err,res)=>
            HTTP.get "https://api.spoonacular.com/food/products/#{doc.id}/?apiKey=e52f2f2ca01a448e944d94194e904775",(err,res)=>
                console.log res
                Docs.update doc_id, 
                    $set:
                        details:res.data
                        
                
        search_menu: (search)->
            # console.log 'calling'
            # HTTP.get "https://api.spoonacular.com/mealplanner/generate?apiKey=e52f2f2ca01a448e944d94194e904775&timeFrame=day&targetCalories=#{calories}",(err,res)=>
            HTTP.get "https://api.spoonacular.com/food/menuItems/search?apiKey=e52f2f2ca01a448e944d94194e904775&query=#{search}",(err,res)=>
                console.log res.data
                # console.log res.data.products
        call_product: (search)->
            # console.log 'calling'
            # HTTP.get "https://api.spoonacular.com/mealplanner/generate?apiKey=e52f2f2ca01a448e944d94194e904775&timeFrame=day&targetCalories=#{calories}",(err,res)=>
            HTTP.get "https://api.spoonacular.com/food/products/search?apiKey=e52f2f2ca01a448e944d94194e904775&query=#{search}",(err,res)=>
                console.log res.data
                console.log res.data.products
                for result in res.data.products
                    console.log result.name
                    # if result.name is 'products'
                    products = res.data.products
                    # products = _.where(res.data.products, {name:'products'})
                    for product in products
                        console.log product
                        found_product = 
                            Docs.findOne 
                                model:'product'
                                source:'spoonacular'
                                id:product.id
                        if found_product
                            Docs.update found_product._id, 
                                $inc:hits:1
                                $addToSet:
                                    tags:search
                        unless found_product
                            new_id = Docs.insert 
                                model:'product'
                                id:product.id
                                source:'spoonacular'
                                title:product.title
                                tags:[search]
                                image:product.image
                                imageType:product.imageType
                                # type:product.type
                                # relevance:product.relevance
                                # content:product.content
                            Meteor.call 'product_details', new_id, ->

                    # products = res.data.searchResults
                    
                    # console.log response.data.searchResults.results
            
            
if Meteor.isServer
    Meteor.publish 'product_facets', (
        picked_tags=[]
        title_search=''
        )->
    
            self = @
            match = {}
    
            # match.tags = $all: picked_tags
            match.model = $in:['product']
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
            if title_search.length > 1
                match.title = {$regex:"#{title_search}", $options: 'i'}

            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_tags.length > 0 then match.tags = $all: picked_tags
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
                    
            self.ready()

    Meteor.publish 'product_results', (
        picked_tags=[]
        title_search=''
        )->
        self = @
        match = {}
        match.model = $in:['product']
        
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        if title_search.length > 1
            match.title = {$regex:"#{title_search}", $options: 'i'}
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
