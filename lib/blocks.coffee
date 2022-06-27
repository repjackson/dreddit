if Meteor.isClient
    Template.tip_button.helpers
        can_tip: ->
            @amount < Meteor.user().points
    Template.tip_button.helpers 
        post_tip_docs: ->
            Docs.find 
                model:'transfer'

    Template.delete_button.events 
        'click .delete_this': -> Docs.remove @
    
    Template.model_label.helpers
        is_model: (input)->
            console.log input
            if @model then @model else Session.get('model')
    Template.model_label.events 
        'click .pick_model': ->
            Session.set('model',@model)
            Router.go "/m/#{@model}"
        
        
    Template.add_doc_button.events 
        'click .add_doc': ->
            new_id = 
                Docs.insert 
                    model:@model
                    published:false
            Router.go "/doc/#{new_id}/edit"
            
            
    Template.publish_button.events 
        'click .publish': ->
            Swal.fire({
                title: "publish service?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_service', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'service published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish service?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_service', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'service unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

            
    Template.favorite_icon_toggle.helpers
        icon_class: ->
            if Meteor.user().favorite_ids and @_id in Meteor.user().favorite_ids
                'red'
            else
                'outline'
            # if @favorite_ids and Meteor.userId() in @favorite_ids
    Template.favorite_icon_toggle.events
        'click .toggle_fav': (e)->
            if Meteor.user()
                
                if Meteor.user().favorite_ids and @_id in Meteor.user().favorite_ids
                    Meteor.users.update Meteor.userId(),
                        $pull:
                            favorite_ids:@_id
                    Docs.update @_id, 
                        $pull:
                            favorited_user_ids:Meteor.userId()
                            favorited_usernames:Meteor.user().username
                            
                else
                    Meteor.users.update Meteor.userId(),
                        $addToSet:
                            favorite_ids:@_id
                    Docs.update @_id, 
                        $addToSet:
                            favorited_user_ids:Meteor.userId()
                            favorited_usernames:Meteor.user().username
                    $('body').toast(
                        showIcon: 'heart'
                        message: "marked favorite"
                        showProgress: 'bottom'
                        class: 'success'
                        # displayTime: 'auto',
                        position: "bottom right"
                    )
                $(e.currentTarget).closest('.toggle_fav').transition('bounce',500)
    
            else 
                Router.go "/login"

    #             Docs.update @_id, 
    #                 $addToSet:favorite_ids:Meteor.userId()
    

    Template.facet.onCreated ->
        console.log @
            
    Template.facet.helpers
        facet_results: ->
            Results.find {
                model:@key
            }, limit:20
        picked_tags: -> picked_tags.array()
    Template.facet.events 
        'click .pick_tag': -> 
            picked_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
            Meteor.call 'search_reddit', @name, ->
        # 'click .pick_flat_tag': -> picked_tags.push @valueOf()
        'click .unpick_tag': -> picked_tags.remove @valueOf()
    
    
        
if Meteor.isClient
    Template.search_input.helpers
        current_search: -> Session.get('current_search')
    Template.search_input.events
        'click .clear_search': (e,t)->
            Session.set('current_search', null)
            t.$('.current_search').val('')
            $('body').toast({
                title: "search cleared"
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
    
    
        # 'keyup .search': (e,t)->
        'keyup .search': _.throttle((e,t)->
            search = $('.query').val().trim().toLowerCase()
            if search.length > 1
                Session.set('current_search', search)
            if e.which is 13
                Meteor.call 'search_reddit', search, ->            
            # console.log Session.get('current_search')
            #     
            #         picked_tags.push search
            #         console.log 'search', search
            #         # Meteor.call 'log_term', search, ->
            #         $('.search').val('')
            #         Session.set('current_search', null)
            #         # # $( "p" ).blur();
            #         # Meteor.setTimeout ->
            #         #     Session.set('dummy', !Session.get('dummy'))
            #         # , 10000
        , 500)
    
        


    Template.sort_direction_toggle.events 
        'click .toggle': ->
            if Session.equals 'sort_direction', -1
                Session.set 'sort_direction', 1
                $('body').toast({
                    title: "sort direction set up"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    icon:'sort direction up'
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
            else
                Session.set 'sort_direction', -1
                $('body').toast({
                    title: "sort direction set down"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    icon:'sort direction down'
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
    
    Template.footer.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.comments.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.group_info.onCreated ->
        # console.log @data
        @autorun => Meteor.subscribe 'group_by_doc_id', @data.group_id, ->
    Template.comments.onCreated ->
        # if Router.current().params.doc_id
        #     parent = Docs.findOne Router.current().params.doc_id
        @autorun => Meteor.subscribe 'children', 'comment', Router.current().params.doc_id, ->
        # else
        #     parent = Docs.findOne Template.parentData()._id
        # if parent
    Template.comments.helpers
        can_add: -> 
            true
            # Meteor.user() and Meteor.user().points > 2
        doc_comments: ->
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.parentData()._id
            Docs.find
                parent_id:parent._id
                model:'comment'
    Template.print_this.events
        'click .print': -> 
            alert(JSON.stringify(@, null, 4));

            console.log @
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                if Router.current().params.doc_id
                    parent = Docs.findOne Router.current().params.doc_id
                else
                    parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne Router.current().params.doc_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    parent_model:parent.model
                    body:comment
                t.$('.add_comment').val('')
                Meteor.call 'calc_user_points', ->
                $(e.currentTarget).closest('.add_comment').transition('bounce',250)

        'click .remove_comment': ->
            if confirm 'Confirm remove comment'
                Docs.remove @_id








   

    Template.voting.events
        'click .upvote': (e,t)->
            if Meteor.user()
                $(e.currentTarget).closest('.icon').transition('bounce',500)
                Meteor.call 'upvote', @, ->
                $('body').toast(
                    showIcon: 'thumbs up'
                    message: "upvoted"
                    showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
                    
            else 
                Router.go "/login"
        'click .downvote': (e,t)->
            if Meteor.user()
                $(e.currentTarget).closest('.icon').transition('bounce',200)
                Meteor.call 'downvote', @, ->
                $('body').toast(
                    showIcon: 'thumbs down'
                    message: "downvoted"
                    showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
            else 
                Router.go "/login"


    Template.voting_small.events
        'click .upvote': (e,t)->
            if Meteor.user()
                $(e.currentTarget).closest('.button').transition('pulse',200)
                Meteor.call 'upvote', @, ->
                $('body').toast(
                    showIcon: 'thumbs up'
                    message: "upvoted"
                    showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
                    
            else 
                Router.go "/login"
        'click .downvote': (e,t)->
            if Meteor.user()
                $(e.currentTarget).closest('.button').transition('pulse',200)
                Meteor.call 'downvote', @, ->
            else 
                Router.go "/login"

    Template.voting_full.events
        'click .upvote': (e,t)->
            if Meteor.user()
                $(e.currentTarget).closest('.button').transition('pulse',200)
                Meteor.call 'upvote', @, ->
                $('body').toast(
                    showIcon: 'thumbs up'
                    message: "upvoted"
                    showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
                console.log @
                Meteor.call 'calc_user_points', ->
                Meteor.call 'calc_user_points', @_author_id, ->
                    
            else
                $(e.currentTarget).closest('.grid').transition('fade down', 500)
                Router.go "/login"
        'click .downvote': (e,t)->
            if Meteor.user()
                $(e.currentTarget).closest('.button').transition('pulse',200)
                Meteor.call 'downvote', @, ->
                $('body').toast(
                    showIcon: 'thumbs down'
                    message: "downvoted"
                    showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
                    
            else 
                $(e.currentTarget).closest('.grid').transition('fade down', 500)
                Router.go "/login"
                Meteor.call 'calc_user_points', ->
                Meteor.call 'calc_user_points', @_author_id, ->
                


    # Template.doc_card.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Template.currentData().doc_id
    # Template.doc_card.helpers
    #     doc: ->
    #         Docs.findOne
    #             _id:Template.currentData().doc_id





    Template.user_social.onCreated ->
        @autorun => Meteor.subscribe 'user_friended', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_friended_by', Router.current().params.username, ->
if Meteor.isServer
    Meteor.publish 'user_friended', (username)->
        user = Meteor.users.findOne username:username
        Meteor.users.find 
            _id:$in:user.friended_user_ids
    Meteor.publish 'user_friended_by', (username)->
        user = Meteor.users.findOne username:username
        Meteor.users.find 
            _id:$in:user.friended_by_user_ids

if Meteor.isClient
    Template.friend_button.helpers
        is_friend: ->
            @friended_by_user_ids and Meteor.userId() in @friended_by_user_ids

    Template.friend_button.events 
        'click .add_friend': ->
            Meteor.users.update @_id, 
                $addToSet:
                    friended_by_user_ids:Meteor.userId()
            Meteor.users.update Meteor.userId(), 
                $addToSet:
                    friended_user_ids:Meteor.userId()
        'click .remove_friend': ->
            Meteor.users.update @_id, 
                $pull:
                    friended_by_user_ids:Meteor.userId()
            Meteor.users.update Meteor.userId(), 
                $pull:
                    friended_user_ids:Meteor.userId()
    
    
    Template.follow_button.helpers
        is_following: ->
            doc = Docs.findOne @_id
            if doc 
                if @follower_user_ids
                    Meteor.userId() in @follower_user_ids
            else 
                if @followed_by_user_ids
                    Meteor.userId() in @followed_by_user_ids
    Template.follow_button.events 
        'click .follow': ->
            doc = Docs.findOne @_id
            if doc
                Docs.update @_id, 
                    $addToSet:
                        follower_user_ids:Meteor.userId()
                Meteor.users.update Meteor.userId(),
                    $addToSet:
                        following_doc_ids:@_id
            unless doc
                Meteor.users.update @_id, 
                    $addToSet:
                        followed_by_user_ids:Meteor.userId()
                Meteor.users.update Meteor.userId(),
                    $addToSet:
                        following_user_ids:Meteor.userId()
            $('body').toast({
                title: "following"
                # message: 'Please see desk staff for key.'
                class: 'success'
                icon: 'checkmark' 
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
                    
        'click .unfollow': ->
            doc = Docs.findOne @_id
            
            if doc
                Docs.update @_id, 
                    $pull:
                        follower_user_ids:Meteor.userId()
                Meteor.users.update Meteor.userId(),
                    $pull:
                        following_doc_ids:@_id
            else 
                Meteor.users.update @_id, 
                    $pull:
                        followed_by_user_ids:Meteor.userId()
                Meteor.users.update Meteor.userId(),
                    $pull:
                        following_user_ids:Meteor.userId()

            $('body').toast({
                title: "unfollowing"
                # message: 'Please see desk staff for key.'
                class: 'info'
                icon: 'checkmark' 
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
               
               
                    
    Template.subscribe_button.helpers
        is_subscribeing: ->
            if @subscriber_user_ids
                Meteor.userId() in @subscriber_user_ids
    Template.subscribe_button.events 
        'click .subscribe': ->
            Meteor.users.update @_id, 
                $addToSet:
                    subscriber_user_ids:Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    subscribeing_user_ids:Meteor.userId()
            $('body').toast({
                title: "subscribing"
                # message: 'Please see desk staff for key.'
                class: 'success'
                icon: 'checkmark' 
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
                    
        'click .unsubscribe': ->
            Meteor.users.update @_id, 
                $pull:
                    subscriber_user_ids:Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $pull:
                    subscribing_user_ids:Meteor.userId()

            $('body').toast({
                title: "unsubscribing"
                # message: 'Please see desk staff for key.'
                class: 'info'
                icon: 'checkmark' 
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
                    
    
    Template.join_button.helpers
        is_member: ->
            @member_ids and Meteor.userId() in @member_ids

if Meteor.isServer
    Meteor.methods 
        create_log: (log_item)->
            log_item.model = 'log'
            log_item.read_user_ids = [Meteor.userId()]
            Docs.insert log_item
            
                


if Meteor.isClient
    Template.join_button.events 
        'click .join': ->
            if Meteor.user()
                Docs.update @_id, 
                    $addToSet:
                        member_ids:Meteor.userId()
                        member_usernames:Meteor.user().username
                Meteor.users.update Meteor.userId(),
                    $addToSet:
                        group_member_ids:@_id
                    log_item = {
                        body:"#{Meteor.user().username} joined #{@title}"
                        parent_id:@_id
                        parent_model:'group'
                        group_id:@_id
                        published:true
                    }
                Meteor.call 'create_log', log_item, ->
                $('body').toast({
                    title: "joined group"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
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
                    
            else 
                Router.go "/login"
        'click .leave': ->
            Docs.update @_id, 
                $pull:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username
            Meteor.users.update Meteor.userId(),
                $pull:
                    group_member_ids:@_id
            log_item = {    
                body:"#{Meteor.user().username} left #{@title}"
                parent_id:@_id
                parent_model:'group'
                group_id:@_id
                published:true
            }
            Meteor.call 'create_log', log_item, ->
            $('body').toast({
                title: "left group"
                # message: 'Please see desk staff for key.'
                class : 'info'
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

    Template.big_user_card.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.big_user_card.helpers
        user: -> Docs.findOne username:@valueOf()



    # Template.set_sort_direction.events
    #     'click .set_sort_direction': ->
    #         if Session.get('sort_direction') is -1
    #             Session.set('sort_direction', 1)
    #         else
    #             Session.set('sort_direction', -1)




    Template.username_info.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.username_info.events
        'click .goto_profile': ->
            user = Docs.findOne username:@valueOf()
            if user.is_current_member
                Router.go "/member/#{user.username}/"
            else
                Router.go "/user/#{user.username}/"
    Template.username_info.helpers
        user: -> Docs.findOne username:@valueOf()




    Template.user_info.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_info.helpers
        user_doc: -> Meteor.users.findOne @valueOf()

    Template.user_avatar.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data
    Template.user_avatar.helpers
        user_doc: -> Meteor.users.findOne @valueOf()


    Template.toggle_edit.events
        'click .toggle_edit': ->
            console.log @
            console.log Template.currentData()
            console.log Template.parentData()
            console.log Template.parentData(1)
            console.log Template.parentData(2)
            console.log Template.parentData(3)
            console.log Template.parentData(4)




    Template.user_list_info.onCreated ->
        @autorun => Meteor.subscribe 'user', @data

    Template.user_list_info.helpers
        user: ->
            console.log @
            Docs.findOne @valueOf()



    # Template.user_field.helpers
    #     key_value: ->
    #         user = Docs.findOne Router.current().params.doc_id
    #         user["#{@key}"]

    # Template.user_field.events
    #     'blur .user_field': (e,t)->
    #         value = t.$('.user_field').val()
    #         Docs.update Router.current().params.doc_id,
    #             $set:"#{@key}":value


    Template.user_list_toggle.onCreated ->
        @autorun => Meteor.subscribe 'user_list', Template.parentData(),@key
    Template.user_list_toggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            $(e.currentTarget).closest('.button').transition('pulse',200)
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"]
                Docs.update parent._id,
                    $pull:"#{@key}":Meteor.userId()
            else
                Docs.update parent._id,
                    $addToSet:"#{@key}":Meteor.userId()
    Template.user_list_toggle.helpers
        user_list_toggle_class: ->
            if Session.get('current_user')
                parent = Template.parentData()
                if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then '' else 'basic'
            else
                'disabled'
        in_list: ->
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then true else false
        list_users: ->
            parent = Template.parentData()
            Docs.find _id:$in:parent["#{@key}"]


    Template.doc_array_toggle.helpers
        user_list_toggle_class: ->
            if Session.get('current_user')
                parent = Template.parentData()
                if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then '' else 'basic'
            else
                'disabled'
        in_list: ->
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then true else false
        list_users: ->
            parent = Template.parentData()
            Docs.find _id:$in:parent["#{@key}"]



    Template.read_button.events
        'click .mark_read': (e,t)->
            unless @read_user_ids and Meteor.userId() in @read_user_ids
                Meteor.call 'mark_read', @_id, ->
                    # $(e.currentTarget).closest('.comment').transition('pulse')
                    $('.unread_icon').transition('pulse')
        'click .mark_unread': (e,t)->
            Docs.update @_id,
                $inc:views:-1
            Meteor.call 'mark_unread', @_id, ->
                # $(e.currentTarget).closest('.comment').transition('pulse')
                $('.unread_icon').transition('pulse')
    Template.viewing.helpers
        viewed_by: -> 
            if @read_user_ids 
                Meteor.userId() in @read_user_ids
        readers: ->
            readers = []
            if @read_user_ids
                for reader_id in @read_user_ids
                    unless reader_id is @_author_id
                        readers.push Docs.findOne reader_id
            readers



    Template.set_sort_key.helpers
        sort_key_class: -> if Session.equals('sort_key',@key) then 'blue' else ''
    Template.set_sort_key.events
        'click .set_key': (e,t)->
            # console.log @
            Session.set('sort_key', @key)
            Session.set('sort_label', @label)
            Session.set('sort_icon', @icon)


    Template.remove_button.events
        'click .remove_doc': (e,t)->
            console.log 'remove'
            if confirm "remove #{@model}?"
                # if $(e.currentTarget).closest('.card')
                # else
                $(e.currentTarget).closest('.grid').transition('fly right', 1000)
                $(e.currentTarget).closest('.card').transition('fly right', 1000)
                $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                $(e.currentTarget).closest('.item').transition('fly right', 1000)
                $(e.currentTarget).closest('.content').transition('fly right', 1000)
                $(e.currentTarget).closest('tr').transition('fly right', 1000)
                $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000
                # if @doc.redirect
                Router.go "/docs/"

    Template.remove_icon.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

    Template.view_user_button.events
        'click .view_user': ->
            Router.go "/user/#{username}"


    Template.session_set.events
        'click .set_session_value': ->
            # console.log @key
            # console.log @value
            if Meteor.user() 
                Meteor.users.update Meteor.userId(),
                    $set:
                        "#{@key}":@value
            Session.set(@key, @value)
            $('body').toast({
                title: "session set #{@key} #{@value}"
                # message: 'Please see desk staff for key.'
                class : 'success'
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

    Template.session_set.helpers
        set_button_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.equals(@key,@value)
                res += ' active big '
            else 
                res += ' '
            # console.log res
            res

        is_active: -> Session.equals(@key,@value)
            


    Template.session_boolean_toggle.events
        'click .toggle_session_key': ->
            console.log @key
            Session.set(@key, !Session.get(@key))
            $('body').toast({
                title: "session toggled #{@key}"
                # message: 'Please see desk staff for key.'
                class : 'success'
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

    Template.session_boolean_toggle.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.get(@key)
                res += ' blue'
            else
                res += ' '

            # console.log res
            res
            
            
    Template.session_boolean_toggle.events
        'click .toggle_session_key': ->
            console.log @key
            Session.set(@key, !Session.get(@key))
            $('body').toast({
                title: "session toggled #{@key}"
                # message: 'Please see desk staff for key.'
                class : 'success'
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
    Template.session_boolean_toggle.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.get(@key)
                res += ' blue'
            else
                res += ' '

            # console.log res
            res

if Meteor.isServer
    Meteor.publish 'children', (model, parent_id, limit)->
        # console.log model
        # console.log parent_id
        limit = if limit then limit else 10
        Docs.find {
            model:model
            parent_id:parent_id
        }, limit:limit
        
        
if Meteor.isClient
    Template.doc_array_toggle.helpers
        doc_array_toggle_class: ->
            parent = Template.parentData()
            # user = Docs.findOne Router.current().params.username
            if parent["#{@key}"] and @value in parent["#{@key}"] then 'active' else 'basic'
    Template.doc_array_toggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            console.log 'key', @key, @value
            console.log 'parent', parent
            if parent["#{@key}"]
                if @value in parent["#{@key}"]
                    Docs.update parent._id,
                        $pull: "#{@key}":@value
                else
                    Docs.update parent._id,
                        $addToSet: "#{@key}":@value
            else
                Docs.update parent._id,
                    $addToSet: "#{@key}":@value




Meteor.methods
    mark_read: (doc_id)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $addToSet:
                read_user_ids: Meteor.userId()
            $set:
                last_viewed: Date.now() 
            $inc:views:1
            
    mark_unread: (doc_id)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $pull:
                read_user_ids: Meteor.userId()
            $inc:views:-1





if Meteor.isClient
    Template.session_key_value_edit.events
        'click .set_key_value': ->
            console.log 'hi'
            # parent = Template.parentData()
            # Docs.update parent._id,
            #     $set: "#{@key}": @value
            if Session.equals('sort_direction',-1)
                Session.set('sort_direction',1)
            else 
                Session.set('sort_direction',-1)
            Session.set("#{@key}",@value)
            
            
    Template.session_key_value_edit.helpers
        set_key_value_class: ->
            parent = Template.parentData()
            # console.log parent
            # if parent["#{@key}"] is @value then 'active' else ''
            if Session.equals("#{@key}",@value) then 'active large' else 'basic'
    
    
    
            
    Template.key_value_edit.helpers
        calculated_class: ->
            parent = Template.parentData()
            # parent = Template.parentData()
            # console.log parent
            # if parent["#{@key}"] is @value then 'active' else ''
            if parent["#{@key}"] is @value then "big blue" else ""
        
        is_selected: ->
            console.log @key, @value
            parent = Template.parentData()
            parent["#{@key}"] is @value
            
    
    Template.key_value_edit.events
        'click .set_key_value': (e)->
            # console.log 'hi'
            parent = Template.parentData()
            console.log parent, @key, @value
            user = Meteor.users.findOne username:Router.current().params.username
            if Docs.findOne Router.current().params.doc_id
                Docs.update parent._id,
                    $set: "#{@key}": @value
            else
                Meteor.users.update parent._id,
                    $set: "#{@key}": @value
            $(e.currentTarget).closest('.button').transition('pulse',500)

            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} set to #{@value}"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

if Meteor.isClient
    Template.flat_tag_selector.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
    Template.flat_tag_selector.helpers
        selector_class: ()->
            term = 
                Docs.findOne 
                    title:@valueOf().toLowerCase()
            if term
                if term.max_emotion_name
                    switch term.max_emotion_name
                        when 'joy' then " basic green"
                        when "anger" then " basic red"
                        when "sadness" then " basic blue"
                        when "disgust" then " basic orange"
                        when "fear" then " basic grey"
                        else "basic grey"
        term: ->
            Docs.findOne 
                title:@valueOf().toLowerCase()
    Template.flat_tag_selector.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            selected_tags.push @valueOf()
            $('.search_group').val('')