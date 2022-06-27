                
if Meteor.isClient
    # Template.posts.helpers
    #     post_docs: ->
    #         Docs.find {
    #             model:'post'
    #         }, 
    #             sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
    #             limit:Session.get('limit')        
                
    Template.post_edit.events
        'click .delete_post': ->
            if confirm 'delete post?'
                Docs.remove @_id
                Router.go "/docs"




if Meteor.isClient
    Router.route '/product/:doc_id/orders', (->
        @layout 'product_layout'
        @render 'product_orders'
        ), name:'product_orders'
    Router.route '/product/:doc_id/subscriptions', (->
        @layout 'product_layout'
        @render 'product_subscriptions'
        ), name:'product_subscriptions'
    Router.route '/product/:doc_id/comments', (->
        @layout 'product_layout'
        @render 'product_comments'
        ), name:'product_comments'
    Router.route '/product/:doc_id/reviews', (->
        @layout 'product_layout'
        @render 'product_reviews'
        ), name:'product_reviews'
    Router.route '/product/:doc_id/inventory', (->
        @layout 'product_layout'
        @render 'product_inventory'
        ), name:'product_inventory'

    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'product_source', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'ingredients_from_product_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'orders_from_product_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'subs_from_product_id', Router.current().params.doc_id, ->
    Template.product_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ingredients_from_product_id', Router.current().params.doc_id
    Template.product_view.events
        # 'click .generate_qrcode': (e,t)->
        #     qrcode = new QRCode(document.getElementById("qrcode"), {
        #         text: @title,
        #         width: 250,
        #         height: 250,
        #         colorDark : "#000000",
        #         colorLight : "#ffffff",
        #         correctLevel : QRCode.CorrectLevel.H
        #     })

        'click .calc_stats': (e,t)->
            Meteor.call 'calc_product_data', Router.current().params.doc_id, ->
        'click .goto_source': (e,t)->
            $(e.currentTarget).closest('.pushable').transition('fade right', 240)
            product = Docs.findOne Router.current().params.doc_id
            Meteor.setTimeout =>
                Router.go "/source/#{product.source_id}"
            , 240
        

    Template.product_subscriptions.events
        'click .subscribe': ->
            if confirm 'subscribe?'
                Docs.update Router.current().params.doc_id,
                    $addToSet: 
                        subscribed_ids: Meteor.userId()
                new_sub_id = 
                    Docs.insert 
                        model:'product_subscription'
                        product_id:Router.current().params.doc_id
                Router.go "/subscription/#{new_sub_id}/edit"
                    
        'click .unsubscribe': ->
            if confirm 'unsubscribe?'
                Docs.update Router.current().params.doc_id,
                    $pull: 
                        subscribed_ids: Meteor.userId()
                                    
    
        'click .mark_ready': ->
            if confirm 'mark product ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:true
                        ready_timestamp:Date.now()

        'click .unmark_ready': ->
            if confirm 'unmark product ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:false
                        ready_timestamp:null

    # Template.product_inventory.onCreated ->
    #     @autorun => Meteor.subscribe 'inventory_from_product_id', Router.current().params.doc_id
            
    # Template.product_inventory.events
    #     'click .add_inventory': ->
    #         count = Docs.find(model:'inventory_item').count()
    #         new_id = Docs.insert 
    #             model:'inventory_item'
    #             product_id:@_id
    #             id:count++
    #         Session.set('editing_inventory_id', @_id)
    #     'click .edit_inventory_item': -> 
    #         Session.set('editing_inventory_id', @_id)
    #     'click .save_inventory_item': -> 
    #         Session.set('editing_inventory_id', null)
        
    # Template.product_inventory.helpers
    #     editing_this: -> Session.equals('editing_inventory_id', @_id)
    #     inventory_items: ->
    #         Docs.find({
    #             model:'inventory_item'
    #             product_id:@_id
    #         }, sort:'_timestamp':-1)


    Template.product_subscriptions.helpers
        product_subs: ->
            Docs.find
                model:'product_subscription'
                product_id:Router.current().params.doc_id

    Template.product_view.helpers
        product_order_total: ->
            orders = 
                Docs.find({
                    model:'order'
                    product_id:@_id
                }).fetch()
            res = 0
            for order in orders
                res += order.order_price
            res
                

        can_cancel: ->
            product = Docs.findOne Router.current().params.doc_id
            if Meteor.userId() is product._author_id
                if product.ready
                    false
                else
                    true
            else if Meteor.userId() is @_author_id
                if product.ready
                    false
                else
                    true


        can_order: ->
            if Meteor.user().roles and 'admin' in Meteor.user().roles
                true
            else
                @cook_user_id isnt Meteor.userId()

        product_order_class: ->
            if @status is 'ready'
                'green'
            else if @status is 'pending'
                'yellow'
                
                
    Template.order_button.onCreated ->

    Template.order_button.helpers

    Template.order_button.events
        # 'click .join_waitlist': ->
        #     Swal.fire({
        #         title: 'confirm wait list join',
        #         text: 'this will charge your account if orders cancel'
        #         icon: 'question'
        #         showCancelButton: true,
        #         confirmButtonText: 'confirm'
        #         cancelButtonText: 'cancel'
        #     }).then((result) =>
        #         if result.value
        #             Docs.insert
        #                 model:'order'
        #                 waitlist:true
        #                 product_id: Router.current().params.doc_id
        #             Swal.fire(
        #                 'wait list joined',
        #                 "you'll be alerted if accepted"
        #                 'success'
        #             )
        #     )

        'click .order_product': ->
            # if Meteor.user().credit >= @price_per_serving
            # Docs.insert
            #     model:'order'
            #     status:'pending'
            #     complete:false
            #     product_id: Router.current().params.doc_id
            #     if @serving_unit
            #         serving_text = @serving_unit
            #     else
            #         serving_text = 'serving'
            # Swal.fire({
            #     # title: "confirm buy #{serving_text}"
            #     title: "confirm order?"
            #     text: "this will charge you #{@price_usd}"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result) =>
            #     if result.value
            Meteor.call 'order_product', @_id, (err, res)->
                if err
                    Swal.fire(
                        'err'
                        'error'
                    )
                    console.log err
                else
                    Router.go "/order/#{res}/edit"
                    # Swal.fire(
                    #     'order and payment processed'
                    #     ''
                    #     'success'
                    # )
        # )

if Meteor.isServer
    Meteor.publish 'orders_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'order'
            product_id:product_id
            
    Meteor.publish 'subs_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'product_subscription'
            product_id:product_id
    Meteor.publish 'inventory_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'inventory_item'
            product_id:product_id





if Meteor.isClient
    Template.product_edit.onCreated ->
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'
        @autorun => Meteor.subscribe 'target_by_transfer_id', Router.current().params.doc_id, ->
        

    Template.product_edit.onRendered ->
        Meteor.setTimeout ->
            today = new Date()
            $('#availability')
                .calendar({
                    inline:true
                    # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
                    # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
                })
        , 2000

    Template.product_edit.helpers
        # all_shop: ->
        #     Docs.find
        #         model:'product'
        can_delete: ->
            product = Docs.findOne Router.current().params.doc_id
            if product.reservation_ids
                if product.reservation_ids.length > 1
                    false
                else
                    true
            else
                true

    Template.product_edit.onCreated ->
        @autorun => @subscribe 'source_search_results', Session.get('source_search'), ->
    Template.product_edit.helpers
        search_results: ->
            Docs.find 
                model:'source'
                

    Template.product_edit.events
        'click .remove_source': (e,t)->
            if confirm 'remove source?'
                Docs.update Router.current().params.doc_id,
                    $set:source_id:null
        'click .pick_source': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:source_id:@_id
        'keyup .source_search': (e,t)->
            # if e.which is '13'
            val = t.$('.source_search').val()
            console.log val
            Session.set('source_search', val)
                
            
        'click .save_product': ->
            product_id = Router.current().params.doc_id
            Meteor.call 'calc_product_data', product_id, ->
            Router.go "/product/#{product_id}"


        'click .save_availability': ->
            doc_id = Router.current().params.doc_id
            availability = $('.ui.calendar').calendar('get date')[0]
            console.log availability
            formatted = moment(availability).format("YYYY-MM-DD[T]HH:mm")
            console.log formatted
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'minutes',true)
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'hours',true)
            Docs.update doc_id,
                $set:datetime_available:formatted





        # 'click .select_product': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             product_id: @_id
        #
        #
        # 'click .clear_product': ->
        #     if confirm 'clear product?'
        #         Docs.update Router.current().params.doc_id,
        #             $set:
        #                 product_id: null



        'click .delete_product': ->
            if confirm 'refund orders and cancel product?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"

if Meteor.isServer 
    Meteor.publish 'source_search_results', (source_title_queary)->
        Docs.find 
            model:'source'
            title: {$regex:"#{source_title_queary}",$options:'i'}


        

    


    # Template.set_sort_key.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set('sort_key', @key)
    #         Session.set('product_sort_label', @label)
    #         Session.set('product_sort_icon', @icon)



if Meteor.isServer
    Meteor.publish 'target_by_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        Meteor.users.findOne transfer.target_id
    Meteor.methods
        add_to_cart: (product_id)->
            # existing_cart_item_with_product = 
            #     Docs.findOne 
            #         model:'cart_item'
            #         product_id:product_id
            # if existing_cart_item_with_product
            #     Docs.update existing_cart_item_with_product._id,
            #         $inc:amount:1
            # else 
            product = Docs.findOne product_id
            current_order = 
                Docs.findOne 
                    model:'order'
                    _author_id:Meteor.userId()
                    status:'cart'
            if current_order
                order_id = current_order._id
            else
                order_id = 
                    Docs.insert 
                        model:'order'
                        status:'cart'
            new_cart_doc_id = 
                Docs.insert 
                    model:'cart_item'
                    status:'cart'
                    product_id: product_id
                    product_price_usd:product.price_usd
                    product_price_points:product.price_points
                    product_title:product.title
                    product_image_id:product.image_id
                    order_id:order_id
            console.log new_cart_doc_id
            
                    



        
if Meteor.isClient
    Template.service_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->
    Template.service_item.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


if Meteor.isClient
    Template.task_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->
    Template.task_item.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->

    Template.task_item.events
        'click .view_task': ->
            Router.go "/doc/#{@_id}"
    Template.task_item.events
        'click .view_task': ->
            Router.go "/doc/#{@_id}"

    
    
    Template.task_edit.events
        'click .delete_task': ->
            Docs.remove @_id
            Router.go "/docs"



if Meteor.isClient
    Template.task_item.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.task_item.events
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

    Template.task_item.helpers
        task_item_class: ->
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
            
            
            


if Meteor.isClient
    Template.rental_card.onCreated ->
        @autorun => @subscribe 'rental_orders',@data._id, ->
    Template.rental_view.onCreated ->
        @autorun => @subscribe 'related_group',Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => @subscribe 'rental_orders',Router.current().params.doc_id, ->
    Template.rental_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    
    Template.rental_view.helpers
        future_order_docs: ->
            Docs.find 
                model:'order'
                rental_id:Router.current().params.doc_id
                
                
                
    Template.rental_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
        
    Template.rental_view.events
        'click .new_order': (e,t)->
            rental = Docs.findOne Router.current().params.doc_id
            new_order_id = Docs.insert
                model:'order'
                rental_id: @_id
                rental_id:rental._id
                rental_title:rental.title
                rental_image_id:rental.image_id
                rental_image_link:rental.image_link
                rental_daily_rate:rental.daily_rate
            Router.go "/order/#{new_order_id}/edit"
            
        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'
            
        'click .cancel_order': ->
            console.log 'hi'
            Swal.fire({
                title: "cancel?"
                # text: "this will charge you $5"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                )

    Template.quickbuy.helpers
        button_class: ->
            tech_form = moment().add(@day_diff, 'days').format('YYYY-MM-DD')
            found_order = 
                Docs.findOne
                    model:'order'
                    order_date:tech_form
            if found_order
                'disabled'
            else 
                'large'
                    
                    
                    
        human_form: ->
            moment().add(@day_diff, 'days').format('ddd, MMM Do')
        from_form: ->
            moment().add(@day_diff, 'days').fromNow()
            
    Template.quickbuy.events
        'click .buy': ->
            # console.log @
            context = Template.parentData()
            human_form = moment().add(@day_diff, 'days').format('dddd, MMM Do')
            tech_form = moment().add(@day_diff, 'days').format('YYYY-MM-DD')
            Swal.fire({
                title: "quickbuy #{human_form}?"
                # text: "this will charge you $5"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    rental = Docs.findOne context._id
                    new_order_id = Docs.insert
                        model:'order'
                        rental_id: rental._id
                        order_date: tech_form
                        _seller_username:rental._author_username
                        rental_id:rental._id
                        rental_title:rental.title
                        rental_image_id:rental.image_id
                        rental_image_link:rental.image_link
                        rental_daily_rate:rental.daily_rate
                    Swal.fire(
                        "reserved for #{human_form}",
                        ''
                        'success'
                    )
            )

            

if Meteor.isServer
    Meteor.publish 'user_rentals', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'rental'
            _author_id: user._id
            
    Meteor.publish 'rental_orders', (doc_id)->
        rental = Docs.findOne doc_id
        Docs.find
            model:'order'
            rental_id:rental._id
            
            
            
            
if Meteor.isClient
    Template.rental_stats.events
        'click .refresh_rental_stats': ->
            Meteor.call 'refresh_rental_stats', @_id




    Template.order_segment.events
        'click .calc_res_numbers': ->
            start_date = moment(@start_timestamp).date()
            start_month = moment(@start_timestamp).month()
            start_minute = moment(@start_timestamp).minute()
            start_hour = moment(@start_timestamp).hour()
            Docs.update @_id,
                $set:
                    start_date:start_date
                    start_month:start_month
                    start_hour:start_hour
                    start_minute:start_minute



if Meteor.isServer
    Meteor.publish 'rental_orders_by_id', (rental_id)->
        Docs.find
            model:'order'
            rental_id: rental_id


    Meteor.publish 'order_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        orders = Docs.find(model:'order',product_id:product_id).fetch()
        # for order in orders
            # console.log 'id', order._id
            # console.log order.paid_amount
        Docs.find
            model:'order'
            product_id:product_id

    Meteor.publish 'order_slot', (moment_ob)->
        rentals_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            rentals.return.push date_string
        rentals_return

        # data.long_form
        # Docs.find
        #     model:'order_slot'


    Meteor.methods
        refresh_rental_stats: (rental_id)->
            rental = Docs.findOne rental_id
            # console.log rental
            orders = Docs.find({model:'order', rental_id:rental_id})
            order_count = orders.count()
            total_earnings = 0
            total_rental_hours = 0
            average_rental_duration = 0

            # shortest_order =
            # longest_order =

            for res in orders.fetch()
                total_earnings += parseFloat(res.cost)
                total_rental_hours += parseFloat(res.hour_duration)

            average_rental_cost = total_earnings/order_count
            average_rental_duration = total_rental_hours/order_count

            Docs.update rental_id,
                $set:
                    order_count: order_count
                    total_earnings: total_earnings.toFixed(0)
                    total_rental_hours: total_rental_hours.toFixed(0)
                    average_rental_cost: average_rental_cost.toFixed(0)
                    average_rental_duration: average_rental_duration.toFixed(0)
                    
                    
                    
if Meteor.isClient
    Template.group_widget.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
        @autorun => Meteor.subscribe 'group_from_doc_id', Router.current().params.doc_id, ->

    Template.group_widget.helpers
        



if Meteor.isClient
    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.transfer_card.onCreated ->
        @autorun => Meteor.subscribe 'target_from_doc_id', (@data._id), ->
        
    Template.transfer_view.onRendered ->



if Meteor.isServer
    # Meteor.publish 'user_info_min', ->
    #     Meteor.users.find {},
    #         fields: 
    #             username:1
    #             first_name:1
    #             last_name:1
    #             image_id:1
    Meteor.publish 'product_from_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        Docs.find 
            _id:transfer.product_id
if Meteor.isClient
    Template.transfer_edit.onCreated ->
        @autorun => Meteor.subscribe 'target_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id, ->', Router.current().params.doc_id, ->

    Template.transfer_view.helpers
        _target: ->
            transfer = Docs.findOne Router.current().params.doc_id
            if transfer and transfer.target_id
                Meteor.users.findOne
                    _id: transfer.target_id

    Template.transfer_edit.helpers
        # terms: ->
        #     Terms.find()
        suggestions: ->
            Results.find(model:'tag')
        _target: ->
            transfer = Docs.findOne Router.current().params.doc_id
            if transfer and transfer.target_id
                Meteor.users.findOne
                    _id: transfer.target_id
        members: ->
            transfer = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                # levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
            }, {
                sort:points:1
                limit:10
                })
        # subtotal: ->
        #     transfer = Docs.findOne Router.current().params.doc_id
        #     transfer.amount*transfer.target_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            transfer = Docs.findOne Router.current().params.doc_id
            transfer.amount and transfer.target_id
    Template.transfer_edit.events
        'click .submit': ->
            Meteor.call 'send_transfer', @_id, =>
                $('body').toast({
                    title: "transfer sent"
                    # message: 'Please see desk staff for key.'
                    class : 'info'
                    icon:'remove'
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
                Router.go "/doc/#{@_id}"



if Meteor.isServer
    Meteor.publish 'target_from_doc_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        if transfer
            Meteor.users.find transfer.target_id
    Meteor.methods
        send_transfer: (transfer_id)->
            transfer = Docs.findOne transfer_id
            target = Meteor.users.findOne transfer.target_id
            transferer = Meteor.users.findOne transfer._author_id

            console.log 'sending transfer', transfer
            Meteor.call 'calc_user_stats', target._id, ->
            Meteor.call 'calc_user_stats', transfer._author_id, ->
    
            Docs.update transfer_id,
                $set:
                    submitted:true
                    published:true
                    submitted_timestamp:Date.now()
            return                    
            
            
if Meteor.isClient
    @picked_event_tags = new ReactiveArray []
        
    # Template.events.onCreated ->
    #     # @autorun => Meteor.subscribe 'model_docs', 'event', ->
    #     # @autorun => Meteor.subscribe 'event_tags',picked_tags.array(), ->
    #     Session.setDefault('event_search',null)
    #     Session.setDefault('view_mode','grid')
    #     Session.setDefault('sort_key','start_datetime')
    #     Session.setDefault('sort_direction',-1)

    #     @autorun => @subscribe 'facets',
    #         'event'
    #         picked_tags.array()
    #         Session.get('limit')
    #         Session.get('sort_key')
    #         Session.get('sort_direction')
    #         Session.get('view_delivery')
    #         Session.get('view_pickup')
    #         Session.get('view_open')

    #     @autorun => @subscribe 'doc_results',
    #         'event'
    #         picked_tags.array()
    #         Session.get('event_search')
    #         Session.get('limit')
    #         Session.get('sort_key')
    #         Session.get('sort_direction')
    #         Session.get('view_delivery')
    #         Session.get('view_pickup')
    #         Session.get('view_open')
        
    # # Router.route '/e/:doc_slug/', (->
    # #     @layout 'layout'
    # #     @render 'event_view'
    # #     ), name:'event_view_by_slug'
        
    Template.registerHelper 'host', () ->    
        Meteor.users.findOne @host_id
   
    Template.registerHelper 'my_ticket', () ->    
        event = Docs.findOne @_id
        Docs.findOne
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id:@_id
            _author_id:Meteor.userId()
   
    # Template.registerHelper 'event_room', () ->
    #     event = Docs.findOne @_id
    #     Docs.findOne 
    #         _id:event.room_id

    # Template.registerHelper 'going', () ->
    #     event = Docs.findOne @_id
    #     event_tickets = 
    #         Docs.find(
    #             model:'transaction'
    #             transaction_type:'ticket_purchase'
    #             event_id: @_id
    #             ).fetch()
    #     going_ids = []
    #     for ticket in event_tickets
    #         going_ids.push ticket._author_id
    #     Meteor.users.find 
    #         _id:$in:going_ids
            
    Template.registerHelper 'going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.going_ids
    Template.registerHelper 'maybe_going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.maybe_ids
    Template.registerHelper 'not_going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.not_going_ids

    Template.registerHelper 'event_tickets', () ->
        Docs.find 
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id: Router.current().params.doc_id


    Template.event_view.onCreated ->
        @autorun => @subscribe 'groups_by_event_id',Router.current().params.doc_id, ->
        @autorun => @subscribe 'group_members',Router.current().params.doc_id, ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->
        # @autorun => @subscribe 'all_users'
    Template.event_view.events
        'click .buy_ticket': ->
            Docs.insert 
                model:'order'
                ticket:true
                event_id:@_id
                ticket_price: @point_price
        
    Template.event_view.helpers
        event_ticket_docs: ->
            Docs.find
                model:'order'
                ticket:true
                event_id:@_id
                ticket_price: @point_price
        picked_tags: -> picked_tags.array()

    Template.session_icon_button.helpers
        session_icon_button_class: ->
            if Session.equals(@key,@value) then 'active' else 'basic compact'
    Template.session_icon_button.events
        'click .set_session_value': ->
            console.log 'hi'
            Session.set(@key,@value)
            
            
    # Template.events.events
    #     'click .toggle_past': ->
    #         Session.set('viewing_past', !Session.get('viewing_past'))
    #     'click .select_room': ->
    #         if Session.equals('viewing_room_id', @_id)
    #             Session.set('viewing_room_id', null)
    #         else
    #             Session.set('viewing_room_id', @_id)

            
    # Template.events.helpers
    #     one_result: ->
    #         Docs.find({model:'event'}).count() is 1
        
    #     room_button_class: -> 
    #         if Session.equals('viewing_room_id', @_id) then 'blue' else 'basic'
    #     event_docs: ->
    #         # console.log moment().format()
    #         match = {}
    #         match.model = 'event'
    #         # published:true
    #         if picked_tags.array().length > 0
    #             match.tags = $all: picked_tags
            
    #         # if Session.get('viewing_past')
    #         #     # match.date = $gt:moment().subtract(1,'days').format("YYYY-MM-DD")
    #         #     match.start_datetime = $lt:moment().subtract(1,'days').format()
    #         # else if Session.get('view_mode', 'all')
    #         #     match.start_datetime = $gt:moment().subtract(1,'days').format()
    #         # else
    #         #     match.date = $lt:moment().subtract(1,'days').format("YYYY-MM-DD")
    #         if Session.get('event_search')
    #             match.title = {$regex:"#{Session.get('event_search')}", $options: 'i'}
    #         Docs.find match,
    #             sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
    

if Meteor.isServer
    Meteor.publish 'groups_by_event_id', (event_id)->
        event = Docs.findOne event_id
        if event
            Docs.find {
                model:'group'
                _id:$in:event.group_ids
            }
            
            
            
    Meteor.publish 'future_events', ()->
        console.log moment().subtract(1,'days').format("YYYY-MM-DD")
        Docs.find {
            model:'event'
            published:true
            date:$gt:moment().subtract(1,'days').format("YYYY-MM-DD")
        }, 
            sort:date:1
    
    Meteor.publish 'events', (
        viewing_room_id
        viewing_past
        viewing_published
        )->
            
        match = {model:'event'}
        if viewing_room_id
            match.room_id = viewing_room_id
        if viewing_past
            match.date = $gt:moment().subtract(1,'days').format("YYYY-MM-DD")
            
        match.published = viewing_published    
            
        console.log moment().subtract(1,'days').format("YYYY-MM-DD")
        Docs.find match, 
            sort:date:1
            

    # Meteor.publish 'doc_by_slug', (slug)->
    #     Docs.find
    #         slug:slug
            
    Meteor.publish 'author_by_doc_id', (doc_id)->
        doc_by_id =
            Docs.findOne doc_id
        doc_by_slug =
            Docs.findOne slug:doc_id
        if doc_by_id
            Meteor.users.find {
                _id:doc_by_id._author_id
            }, 
                fields:
                    username:1
                    image_id:1
                    first_name:1
                    last_name:1
        else
            Meteor.users.find
                _id:doc_by_slug._author_id
            
            
    # Meteor.publish 'author_by_doc_slug', (slug)->
    #     doc = 
    #         Docs.findOne
    #             slug:slug
    #     Meteor.users.findOne 
    #         _id:doc._author_id


 if Meteor.isClient
    Template.registerHelper 'ticket_event', () ->
        Docs.findOne @event_id



    Template.ticket_view.onCreated ->
        @autorun => Meteor.subscribe 'event_from_ticket_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.ticket_view.onRendered ->

    Template.ticket_view.events
        'click .cancel_reservation': ->
            event = @
            # Swal.fire({
            #     title: "cancel reservation?"
            #     # text: "cannot be undone"
            #     icon: 'question'
            #     confirmButtonText: 'confirm cancelation'
            #     confirmButtonColor: 'red'
            #     showCancelButton: true
            #     cancelButtonText: 'return'
            #     reverseButtons: true
            # }).then((result)=>
            #     if result.value
            #         console.log @
            #             Meteor.call 'remove_reservation', @_id, =>
            #                 Swal.fire(
            #                     position: 'top-end',
            #                     icon: 'success',
            #                     title: 'reservation removed',
            #                     showConfirmButton: false,
            #                     timer: 1500
            #                 )
            #                 Router.go "/event/#{event}/view"
            #         )
            # )_



if Meteor.isServer
    Meteor.publish 'event_from_ticket_id', (ticket_id)->
        ticket = Docs.findOne ticket_id
        Docs.find 
            _id:ticket.event_id
            
            
    Meteor.publish 'group', (ticket_id)->
        ticket = Docs.findOne ticket_id
        Docs.find 
            _id:ticket.event_id
            
            
    Meteor.methods
        remove_reservation: (doc_id)->
            Docs.remove doc_id
            
if Meteor.isClient
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'author_by_doc_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'author_by_doc_slug', Router.current().params.doc_slug
        @autorun => Meteor.subscribe 'event_tickets', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'room'
        
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
        #     locale: 'auto'
        #     zipCode: true
        #     token: (token) =>
        #         # amount = parseInt(Session.get('topup_amount'))
        #         event = Docs.findOne Router.current().params.doc_id
        #         charge =
        #             amount: Session.get('usd_paying')*100
        #             event_id:event._id
        #             currency: 'usd'
        #             source: token.id
        #             input:'number'
        #             # description: token.description
        #             description: "one"
        #             event_title:event.title
        #             # receipt_email: token.email
        #         Meteor.call 'buy_ticket', charge, (err,res)=>
        #             if err then alert err.reason, 'danger'
        #             else
        #                 console.log 'res', res
        #                 Swal.fire(
        #                     'ticket purchased',
        #                     ''
        #                     'success'
        #                 # Meteor.users.update Meteor.userId(),
        #                 #     $inc: points:500
        #                 )
        # )
    
    Template.event_view.onRendered ->
        Docs.update Router.current().params.doc_id, 
            $inc: views: 1

    Template.event_view.helpers 
        can_buy: ->
            now = Date.now()
            

    Template.event_view.events
        'click .buy_for_points': (e,t)->
            val = parseInt $('.point_input').val()
            Session.set('point_paying',val)
            # $('.ui.modal').modal('show')
            Swal.fire({
                title: "buy ticket for #{Session.get('point_paying')}pts?"
                text: "#{@title}"
                icon: 'question'
                # input:'number'
                confirmButtonText: 'purchase'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.insert 
                        model:'transaction'
                        transaction_type:'ticket_purchase'
                        payment_type:'points'
                        is_points:true
                        point_amount:Session.get('point_paying')
                        event_id:@_id
                    Meteor.users.update Meteor.userId(),
                        $inc:points:-Session.get('point_paying')
                    Meteor.users.update @_author_id, 
                        $inc:points:Session.get('point_paying')
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'ticket purchased',
                        showConfirmButton: false,
                        timer: 1500
                    )
            )
        
        'click .return': (e,t)->
            # val = parseInt $('.point_input').val()
            # Session.set('point_paying',val)
            # $('.ui.modal').modal('show')
            Swal.fire({
                title: "return ticket?"
                # text: "#{Template.parentData().title}"
                icon: 'question'
                # input:'number'
                confirmButtonText: 'return'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'ticket returned',
                        showConfirmButton: false,
                        timer: 1500
                    )
            )
    
        'click .buy_for_usd': (e,t)->
            console.log Template.instance()
            val = parseInt t.$('.usd_input').val()
            Session.set('usd_paying',val)

            instance = Template.instance()

            Swal.fire({
                # title: "buy ticket for $#{@usd_price} or more!"
                title: "buy ticket for $#{Session.get('usd_paying')}?"
                text: "for #{@title}"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'purchase'
                # input:'number'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    # Session.set('topup_amount',5)
                    # Template.instance().checkout.open
                    instance.checkout.open
                        name: 'One Boulder One'
                        # email:Meteor.user().emails[0].address
                        description: "#{@title} ticket purchase"
                        amount: Session.get('usd_paying')*100
            
                    # Meteor.users.update @_author_id,
                    #     $inc:credit:@order_price
                    # Swal.fire(
                    #     'topup initiated',
                    #     ''
                    #     'success'
                    # )
            )




    
    Template.attendance.events
        'click .mark_maybe': ->
            event = Docs.findOne Router.current().params.doc_id
            # console.log 'hi'
            # Meteor.call 'mark_maybe', Router.current().params.doc_id, ->
            # event = Docs.findOne event_id
            if event.maybe_ids
                if Meteor.userId() in event.maybe_ids
                    Docs.update event._id,
                        $pull:
                            maybe_ids: Meteor.userId()
                else
                    Docs.update event._id,
                        $addToSet:
                            maybe_ids: Meteor.userId()
                        $pull:
                            going_ids: Meteor.userId()
                            not_going_ids: Meteor.userId()
            else
                Docs.update event._id,
                    $addToSet:
                        maybe_ids: Meteor.userId()
                    $pull:
                        going_ids: Meteor.userId()
                        not_going_ids: Meteor.userId()

        'click .mark_not': ->
            event = Docs.findOne Router.current().params.doc_id
            Meteor.call 'mark_not', Router.current().params.doc_id, ->
        'click .mark_going': -> Meteor.call 'mark_going', @_id, ->

    Template.event_card.events
        'click .mark_maybe': -> Meteor.call 'mark_maybe', @_id, ->
        'click .mark_not': -> Meteor.call 'mark_not', @_id, ->
        'click .mark_going': -> Meteor.call 'mark_going', @_id, ->
    Template.event_view.helpers
        tickets_left: ->
            ticket_count = 
                Docs.find({ 
                    model:'transaction'
                    transaction_type:'ticket_purchase'
                    event_id: Router.current().params.doc_id
                }).count()
            @max_attendees-ticket_count



if Meteor.isServer
    Meteor.publish 'event_tickets', (event_id)->
        Docs.find
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id:event_id


    Meteor.methods
        'mark_not': (event_id)->
            event = Docs.findOne event_id
            if event.not_going_ids and Meteor.userId() in event.not_going_ids
                Docs.update event_id,
                    $pull:
                        not_going_ids: Meteor.userId()
            else
                Docs.update event_id,
                    $addToSet:
                        not_going_ids: Meteor.userId()
                    $pull:
                        going_ids: Meteor.userId()
                        maybe_ids: Meteor.userId()
    
            
        'mark_maybe': (event_id)->
            event = Docs.findOne event_id
            if event.maybe_ids and Meteor.userId() in event.maybe_ids
                Docs.update event_id,
                    $pull:
                        maybe_ids: Meteor.userId()
            else
                Docs.update event_id,
                    $addToSet:
                        maybe_ids: Meteor.userId()
                    $pull:
                        going_ids: Meteor.userId()
                        not_going_ids: Meteor.userId()
        'mark_going': (event_id)->
            event = Docs.findOne event_id
            if event.going_ids and Meteor.userId() in event.going_ids
                Docs.update event_id,
                    $pull:
                        going_ids: Meteor.userId()
            else
                Docs.update event_id,
                    $addToSet:
                        going_ids: Meteor.userId()
                    $pull:
                        maybe_ids: Meteor.userId()
                        not_going_ids: Meteor.userId()
                
                
                
if Meteor.isClient
    # Template.event_edit.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'room_reservation'
    #     @autorun => Meteor.subscribe 'model_docs', 'room'
    Template.event_edit.helpers
        rooms: ->
            Docs.find   
                model:'room'


    Template.event_edit.events
        'click .delete_item': ->
            if confirm 'delete event?'
                Docs.remove @_id
            Router.go "/events"

        'click .select_room': ->
            reservation_exists = 
                Docs.findOne
                    model:'room_reservation'
                    room_id:event.room_id 
                    date:event.date
            console.log reservation_exists
            unless reservation_exists            
                Docs.update Router.current().params.doc_id,
                    $set:
                        room_id:@_id
                        room_title:@title

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_event', @_id, =>
                    Router.go "/event/#{@_id}/view"


    Template.event_edit.helpers
        reservation_exists: ->
            event = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                model:'room_reservation'
                # room_id:event.room_id 
                date:event.date
        room_button_class: ->
            event = Docs.findOne Router.current().params.doc_id
            room = Docs.findOne _id:event.room_id
            reservation_exists = 
                Docs.findOne
                    model:'room_reservation'
                    # room_id:event.room_id 
                    date:event.date
            res = ''
            if event.room_id is @_id
                res += 'blue'
            else 
                res += 'basic'
            if reservation_exists
                # console.log 'res exists'
                res += ' disabled'
            else
                console.log 'no res'
            res
    
        room_reservations: ->
            event = Docs.findOne Router.current().params.doc_id
            room = Docs.findOne _id:event.room_id
            Docs.find 
                model:'room_reservation'
                room_id:event.room_id 
                date:event.date
                
    Template.reserve_button.helpers
        event_room: ->
            event = Docs.findOne Router.current().params.doc_id
            room = Docs.findOne _id:event.room_id
        slot_res: ->
            event = Docs.findOne Router.current().params.doc_id
            room = Docs.findOne _id:event.room_id
            Docs.findOne
                model:'room_reservation'
                room_id:event.room_id
                date:event.date
                slot:@slot
    
    
    Template.reserve_button.events
        'click .cancel_res': ->
            Swal.fire({
                title: "confirm delete reservation?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
            )
        'click .reserve_slot': ->
            event = Docs.findOne Router.current().params.doc_id
            room = Docs.findOne _id:event.room_id
            Docs.insert 
                model:'room_reservation'
                room_id:event.room_id
                date:event.date
                slot:@slot
                payment:'points'
                
                
if Meteor.isClient
    Router.route '/mail/inbox', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'inbox'
    Router.route 'mail/drafts', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'drafts'
    Router.route 'mail/sent', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'sent'
    Router.route 'mail/archive', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'archive'

    Template.inbox.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'message', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'my_received_messages', ->
        @autorun => Meteor.subscribe 'my_sent_messages', ->
        # @autorun => Meteor.subscribe 'inbox', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'stat', ->

if Meteor.isServer 
    Meteor.publish 'my_received_messages', ->
        Docs.find 
            model:'message'
            target_id:Meteor.userId()
    Meteor.publish 'my_sent_messages', ->
        Docs.find 
            model:'message'
            _author_id:Meteor.userId()

if Meteor.isClient
    Template.inbox.events
        'click .add_message': ->
            new_message_id =
                Docs.insert
                    model:'message'
                    cost:10
                    sent:false
            Router.go "/message/#{new_message_id}/edit"

    Template.recent_logs.onCreated ->
        @autorun => @subscribe 'recent_logs', ->
            
            
    Template.log_item.helpers
        read_class: ->
            if @read_user_ids and Meteor.userId() in @read_user_ids then 'small' else 'large raised'
            
            
if Meteor.isServer
    Meteor.publish 'recent_logs', ->
        Docs.find 
            model:'log'
            
if Meteor.isClient            
    Template.recent_logs.helpers
        unread_log_count: ->
            Docs.find(
                model:'log'
                read_user_ids:$nin:[Meteor.userId()]
            ).count()

        logs: ->
            Docs.find {
                model:'log'
            }, sort:_timestamp:-1
    Template.inbox.helpers
        my_sent_messages: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'message'
                _author_id: Meteor.userId()
                # target: target_user._id
            },
                sort:_timestamp:-1

        my_received_messages: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'message'
                target_id: Meteor.userId()
                # target: target_user._id
            },
                sort:_timestamp:-1

    Template.toggle_view_icon.helpers
        has_read: ->
            @read_user_ids and Meteor.userId() in @read_user_ids
    Template.toggle_view_icon.events
        'click .mark_read': ->
            Meteor.call 'mark_read', @_id, ->
        'click .mark_unread': ->
            Meteor.call 'mark_unread', @_id, ->
            

if Meteor.isClient
    Router.route '/messages/', (->
        @layout 'layout'
        @render 'messages'
        ), name:'messages'
    

    Router.route '/message/:doc_id', (->
        @layout 'layout'
        @render 'message_view'
        ), name:'message_view'

    Template.message_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_message_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        
    Template.message_view.onRendered ->



            
if Meteor.isClient
    Router.route '/message/:doc_id/edit', (->
        @layout 'layout'
        @render 'message_edit'
        ), name:'message_edit'
        
        
    Template.message_edit.onCreated ->
        @autorun => Meteor.subscribe 'target_from_message_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->


    Template.message_edit.helpers
        _target: ->
            message = Docs.findOne Router.current().params.doc_id
            if message.target_id
                Meteor.users.findOne
                    _id: message.target_id
        available_targets: ->
            message = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                # levels: $in: ['member']
                _id: $ne: Meteor.userId()
        # subtotal: ->
        #     message = Docs.findOne Router.current().params.doc_id
        #     message.amount*message.target_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_send: ->
            true
            message = Docs.findOne Router.current().params.doc_id
            message.description and message.target_id
            
            
    Template.message_edit.events
        'click .add_target': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    target_id:@_id
        'click .remove_target': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    target_id:1
        'keyup .new_element': (e,t)->
            if e.which is 13
                element_val = t.$('.new_element').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                t.$('.new_element').val('')
    
        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_element').focus()
            t.$('.new_element').val(element)
    
    
        # 'click .result': (e,t)->
        #     Meteor.call 'log_term', @title, ->
        #     picked_tags.push @title
        #     $('#search').val('')
        #     Meteor.call 'call_wiki', @title, ->
        #     Meteor.call 'calc_term', @title, ->
        #     Meteor.call 'omega', @title, ->
        #     Session.set('current_query', '')
        #     Session.set('searching', false)
    
        #     Meteor.call 'search_reddit', picked_tags.array(), ->
        #     # Meteor.setTimeout ->
        #     #     Session.set('dummy', !Session.get('dummy'))
        #     # , 7000

    
        # 'blur .edit_description': (e,t)->
        #     textarea_val = t.$('.edit_textarea').val()
        #     Docs.update Router.current().params.doc_id,
        #         $set:description:textarea_val
    
    
        # 'blur .edit_text': (e,t)->
        #     val = t.$('.edit_text').val()
        #     Docs.update Router.current().params.doc_id,
        #         $set:"#{@key}":val
    
    


if Meteor.isClient
    Template.message_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'target_from_message_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    Template.message_edit.onRendered ->


    Template.message_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Swal.fire({
                title: "confirm send message?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'send_message', @_id, =>
                        Swal.fire(
                            title:"message sent"
                            icon:'success'
                            # showClass:
                            #     popup: 'swal2-noanimation',
                            #     backdrop: 'swal2-noanimation'
                            # hideClass:
                            #     popup: '',
                            #     backdrop: ''
                            showConfirmButton: false
                            timer: 1000
                        )
                        Router.go "/message/#{@_id}"
            )


    Template.message_edit.helpers
    Template.message_edit.events

if Meteor.isServer
    Meteor.methods
        send_message: (message_id)->
            message = Docs.findOne message_id
            target = Meteor.users.findOne message.target_id
            sender = Meteor.users.findOne message._author_id

            console.log 'sending message', message
            Meteor.users.update sender._id,
                $inc:
                    unread_message_count:1
            Docs.update message_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update message_id,
                $set:
                    submitted:true
                            