if Meteor.isClient
    Router.route '/doc/:doc_id/edit', (->
        @layout 'layout'
        @render 'doc_edit'
        ), name:'doc_edit'
    Template.doc_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_from_doc_id', Router.current().params.doc_id, ->
    Template.doc_edit.onRendered ->
        current_doc = Docs.findOne(Router.current().params.doc_id)
        document.title = "edit #{current_doc.title}";

        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000

    Template.doc_edit.events
        'click .publish': ->
            Docs.update @_id, 
                $set:
                    published:true
                    publish_timestamp:Date.now()
    Template.doc_edit.helpers
        model_template: -> "#{@model}_edit"
        doc_data: -> 
            # console.log 'hi'
            Docs.findOne Router.current().params.doc_id
    
    Router.route '/doc/:doc_id/', (->
        @layout 'layout'
        @render 'doc_view'
        ), name:'doc_view'
        
        
    Template.doc_view.onRendered ->
        current_doc = Docs.findOne(Router.current().params.doc_id)
        if current_doc
            document.title = "#{current_doc.title}";
        
        Meteor.call 'log_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $().popup(
                inline: true
            )
        , 2000
            
    Template.doc_view.onCreated ->
        @autorun => Meteor.subscribe 'current_viewers', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_by_id', Router.current().params.doc_id, ->
    Template.doc_view.helpers
        model_template: -> "#{@model}_view"
        # current_doc: -> Docs.findOne Router.current().params.doc_id
        doc_data: -> 
            # console.log 'hi'
            Docs.findOne Router.current().params.doc_id
    Template.doc_view.events 
        'click .pick_flat_tag':(e)->
            doc = Docs.findOne Router.current().params.doc_id
            picked_tags.clear()
            picked_tags.push @valueOf()
            $('.flat_tags .pick_flat_tag')
              .transition({
                animation : 'scale'
                reverse   : 'auto'
                interval  : 30
              })
            # Meteor.call 'search_reddit', @valueOf(), ->
            Session.set('model',doc.model)
            Meteor.setTimeout ->
                $(e.currentTarget).closest('.grid').transition('fly right', 1000)
            , 500
            Meteor.setTimeout ->
                Router.go "/m/#{doc.model}"
            , 500
        
    # Template.doc_card.helpers
    #     card_template: -> "#{@model}_card"
    Template.doc_card.helpers
        card_template: -> "#{@model}_card"
    Template.doc_card.onCreated ->
        @autorun => @subscribe 'author_by_doc_id', @data._id,->
    Template.docs.onRendered ->
        Session.set('model',Router.current().params.model)
        # current_doc = Docs.findOne(Router.current().params.doc_id)
        document.title = "#{Router.current().params.model}s";
        
    Template.docs.onCreated ->
        Session.set('model',Router.current().params.model)
        Session.setDefault('limit',42)
        Session.setDefault('sort_key','_timestamp')
        Session.setDefault('sort_icon','clock')
        Session.setDefault('sort_label','added')
        Session.setDefault('sort_direction',-1)
        # @autorun => @subscribe 'model_docs', 'post', ->
        # @autorun => @subscribe 'user_info_min', ->
        @autorun => @subscribe 'facet_sub',
            Session.get('model')
            picked_tags.array()
            Session.get('current_search')
            picked_timestamp_tags.array()
    
        @autorun => @subscribe 'doc_results',
            Session.get('model')
            picked_tags.array()
            Session.get('current_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
    Template.docs.events
        'click .add_new_doc': ->
            new_id = 
                Docs.insert 
                    model:Session.get('model')
            Router.go "/m/#{new_id}/edit"
    Template.docs.helpers
        no_results: ->
            Docs.find(model:Session.get('model')).count() is 0
        current_model_icon: ->
            switch Session.get('model')
                when 'post'  then 'news'
                when 'event' then 'calendar'
                when 'product' then 'shopping-cart'
                when 'group' then 'campfire'
                when 'service' then 'service'
                when 'log' then 'event-log'
                when 'task' then 'tasks'
                when 'checkin' then 'checkmark'
                when 'transfer' then 'exchange'
            
    
    Template.sort_key_toggle.helpers
        sort_title:-> 'click to toggle sort'
        sort_icon:-> Session.get('sort_icon')
    Template.sort_key_toggle.events
        'click .toggle_sort': ->
            console.log 'hi'
            if Session.equals('sort_key','views')
                Session.set('sort_key','_timestamp')
                Session.set('sort_label','added')
                Session.set('sort_icon','clock')
            else if Session.equals('sort_key','_timestamp')
                Session.set('sort_key','points')
                Session.set('sort_label','points')
                Session.set('sort_icon','hashtag')
            else if Session.equals('sort_key','points')
                Session.set('sort_key','views')
                Session.set('sort_label','views')
                Session.set('sort_icon','eye')
            $('body').toast({
                title: "sorting by #{Session.get('sort_label')}"
                class : 'info'
                position:'bottom center'
                })

    
    Template.docs.helpers
        current_model: -> Session.get('model')
        result_docs: ->
            match = {}
            if Session.get('model') is 'post'
                match.model=$in:['post','reddit']
            else 
                match.model = Session.get('model')
            Docs.find match, 
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')        
                
if Meteor.isServer
    Meteor.publish 'group_from_doc_id', (doc_id)->
        doc = Docs.findOne doc_id 
        if doc and doc.group_id
            Docs.find 
                model:'group'
                _id:doc.group_id