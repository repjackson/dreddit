if Meteor.isClient
    Template.tasks.onCreated ->
        document.title = 'gr tasks'
        
        Session.setDefault('current_search', null)
        Session.setDefault('is_loading', false)
        @autorun => @subscribe 'doc_by_id', Session.get('full_doc_id'), ->
            
    Template.tasks.onCreated ->
        # @autorun => @subscribe 'model_docs', 'task', ->
        @autorun => @subscribe 'tasks',
            picked_tags.array()
            # Session.get('dummy')
    
    
    
    Router.route '/task/:doc_id', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'
    Router.route '/task/:doc_id/edit', (->
        @layout 'layout'
        @render 'task_edit'
        ), name:'task_edit'
    Router.route '/tasks', (->
        @layout 'layout'
        @render 'tasks'
        ), name:'tasks'
    Template.tasks.onCreated ->
        @autorun => Meteor.subscribe 'model_counter',('task'), ->
        @autorun => Meteor.subscribe 'model_docs','task', ->
            
    Template.task_edit.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.task_edit.events
        'click .remove_task': ->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/tasks"
        'click .submit_task': ->
            Docs.update @_id,
                submitted:true
                published:true
                published_timestamp:Date.now()
                published_user_id:Meteor.userId()
                published_username:Meteor.user().username
                
            Router.go "/kiosk"
            Swal.fire({
                title: "thanks for your submission"
                # title: "checked in"
                # text: "point bounty will be held "
                icon: 'success'
                timer:2000
                # background: 'green'
                timerProgressBar:true
                showClass: {popup: 'animate__animated animate__fadeInDown'}
                hideClass: {popup: 'animate__animated animate__fadeOutUp'}
                showConfirmButton:false
                # confirmButtonText: 'publish'
                # confirmButtonColor: 'green'
                # showCancelButton: true
                # cancelButtonText: 'cancel'
                # reverseButtons: true
            })

    Template.save_and_publish_button.events
        'click .save_and_publish': ->
            Docs.update @_id, 
                $set:
                    published:true
                    published_timestamp:Date.now()
                    published_user_id:Meteor.userId()
                    published_username:Meteor.user().username
            $('body').toast({
                title: "published"
                # message: 'Please see desk staff for key.'
                class : 'green'
                showIcon: 'eye'
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

    Template.task_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => @subscribe 'child_docs', Router.current().params.doc_id, ->
            
            
    Template.tasks.helpers
        total_task_count: -> Counts.get('model_counter') 
        task_docs: ->
            Docs.find {
                model:'task'
            }, sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
    Template.tasks.events 
        'click .new_task': ->
            new_id = 
                Docs.insert 
                    model:'task'
                    complete:false
            Router.go "/task/#{new_id}/edit"

    Template.task_item.events
        'click .mark_viewed': ->
            unless @viewer_ids and Meteor.userId() in @viewer_ids
                Docs.update @_id, 
                    $addToSet:
                        viewer_ids:Meteor.userId()
                        viewer_usernames:Meteor.user().username
                    $set:
                        last_viewed:Date.now()
                    $inc:
                        views:1
                $('body').toast({
                    title: "mark viewed"
                    # message: 'Please see desk staff for key.'
                    class : 'black'
                    showIcon: 'eye'
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
            
    Template.user_tasks.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'task', ->
    Template.user_tasks.helpers
        user_authored_tasks: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'task'
                _author_id:user._id
        user_assigned_tasks: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'task'
                assigned_user_id:user._id
                complete:$ne:true
        user_completed_tasks: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'task'
                assigned_user_id:user._id
                complete:true
            
    Template.user_tasks.events 
        'click .assign_task': ->
            user = Meteor.users.findOne username:Router.current().params.username
            if user 
                new_id = 
                    Docs.insert 
                        model:'task'
                        complete:false
                        target_id:user._id
                Router.go "/task/#{new_id}/edit"



    Template.task_view.helpers 
        activity_docs: ->
            Docs.find 
                model:'log'
                parent_id:Router.current().params.doc_id
    Template.task_view.events 
        'click .clone_task': ->
            new_id = 
                Docs.insert 
                    model:'task'
                    title:@title
                    image_id:@image_id
                    tags:@tags
                    parent_id:@_id
                    group_id:@group_id
            Router.go "/task/#{new_id}/edit"
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    complete:true 
                    complete_timestamp: Date.now()
            Docs.insert 
                model:'log'
                parent_id:Router.current().params.doc_id 
                body:'marked complete'
                
        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    complete:false 
                $unset:
                    complete_timestamp:1
            Docs.insert 
                model:'log'
                parent_id:Router.current().params.doc_id 
                body:'marked incomplete'
                