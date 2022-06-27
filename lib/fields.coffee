if Meteor.isClient
    Template.youtube_edit.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
    
    Template.youtube_view.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
    
    Template.i.helpers
        is_active: -> 
            # console.log @
    
    
    
    Template.range_edit.onRendered ->
        # rental = Template.currentData()
        $('#rangestart').calendar({
            type: 'datetime'
            today: true
            # type:'time'
            inline: true
            endCalendar: $('#rangeend')
            formatter: {
                date: (date, settings)->
                    if !date then return ''
                    mst_date = moment(date)
                    mst_date.format("YYYY-MM-DD[T]hh:mm")
            }
        });
        $('#rangeend').calendar({
            type: 'datetime'
            today: true
            # type:'time'
            inline: true
            startCalendar: $('#rangestart')
            formatter: {
                date: (date, settings)->
                    if !date then return ''
                    mst_date = moment(date)
                    mst_date.format("YYYY-MM-DD[T]hh:mm")
    
            }
        })
    
    Template.range_edit.events
        'click .get_start': ->
            doc_id = Router.current().params.doc_id
            result = $('.ui.calendar').calendar('get startDate')[1]
            formatted = moment(result).format("YYYY-MM-DD[T]HH:mm")
            # moment_ob = moment(result)
            Docs.update doc_id,
                $set:start_datetime:formatted
    
    
        'click .get_end': ->
            doc_id = Router.current().params.doc_id
            result = $('.ui.calendar').calendar('get endDate')[0]
            console.log result
            formatted = moment(result).format("YYYY-MM-DD[T]HH:mm")
            Docs.update doc_id,
                $set:end_datetime:formatted
    
    
    Template.youtube_edit.events
        'blur .youtube_id': (e,t)->
            parent = Template.parentData()
            val = t.$('.youtube_id').val()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
    
    
    Template.datetime_edit.events
        'blur .edit_datetime': (e,t)->
            parent = Template.parentData()
            val = $(e.currentTarget).closest('.edit_datetime').val()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else if Meteor.users.findOne parent._id
                Meteor.users.update parent._id,
                    $set:"#{@key}":val
    
    Template.date_edit.events
        'blur .edit_date': (e,t)->
            parent = Template.parentData()
            val = $(e.currentTarget).closest('.edit_date').val()
            doc = Docs.findOne parent._id
            console.log val
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else if Meteor.users.findOne parent._id
                Meteor.users.update parent._id,
                    $set:"#{@key}":val
                
    
        'click .today': ->
            val = moment().format("YYYY-MM-DD")
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
    
        'click .tomorrow': ->
            val = moment().add(1, 'days').format("YYYY-MM-DD")
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
    
    
    
    Template.color_edit.events
        'blur .edit_color': (e,t)->
            val = t.$('.edit_color').val()
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else 
                Meteor.users.update parent._id,
                    $set:"#{@key}":val
                    
    
    
    Template.html_edit.onRendered ->
        @editor = SUNEDITOR.create((document.getElementById('sample') || 'sample'),{
            # 	"tabDisable": false
            # "minHeight": "500px"
            charCounter:true;
            colorList: [ ['#ff0000', '#ff5e00', '#ffe400', '#abf200'], ['#00d8ff', '#0055ff', '#6600ff', '#ff00dd'] ];
            width: "100%"
            buttonList: [
                # // default
                ['undo', 'redo'],
                [':p-More Paragraph-default.more_paragraph', 'font', 'fontSize', 'formatBlock', 'paragraphStyle', 'blockquote'],
                ['bold', 'underline', 'italic', 'strike', 'subscript', 'superscript'],
                ['fontColor', 'hiliteColor', 'textStyle'],
                ['removeFormat'],
                ['outdent', 'indent'],
                ['align', 'horizontalRule', 'list', 'lineHeight'],
                ['-right', ':i-More Misc-default.more_vertical', 'fullScreen', 'showBlocks', 'codeView', 'preview', 'print', 'save', 'template'],
                ['-right', ':r-More Rich-default.more_plus', 'table', 'imageGallery'],
                ['-right', 'image', 'video', 'audio', 'link'],
                # // (min-width: 992)
                ['%992', [
                    ['undo', 'redo'],
                    [':p-More Paragraph-default.more_paragraph', 'font', 'fontSize', 'formatBlock', 'paragraphStyle', 'blockquote'],
                    ['bold', 'underline', 'italic', 'strike'],
                    [':t-More Text-default.more_text', 'subscript', 'superscript', 'fontColor', 'hiliteColor', 'textStyle'],
                    ['removeFormat'],
                    ['outdent', 'indent'],
                    ['align', 'horizontalRule', 'list', 'lineHeight'],
                    ['-right', ':i-More Misc-default.more_vertical', 'fullScreen', 'showBlocks', 'codeView', 'preview', 'print', 'save', 'template'],
                    ['-right', ':r-More Rich-default.more_plus', 'table', 'link', 'image', 'video', 'audio', 'imageGallery']
                ]],
                # // (min-width: 767)
                ['%767', [
                    ['undo', 'redo'],
                    [':p-More Paragraph-default.more_paragraph', 'font', 'fontSize', 'formatBlock', 'paragraphStyle', 'blockquote'],
                    [':t-More Text-default.more_text', 'bold', 'underline', 'italic', 'strike', 'subscript', 'superscript', 'fontColor', 'hiliteColor', 'textStyle'],
                    ['removeFormat'],
                    ['outdent', 'indent'],
                    [':e-More Line-default.more_horizontal', 'align', 'horizontalRule', 'list', 'lineHeight'],
                    [':r-More Rich-default.more_plus', 'table', 'link', 'image', 'video', 'audio', 'imageGallery'],
                    ['-right', ':i-More Misc-default.more_vertical', 'fullScreen', 'showBlocks', 'codeView', 'preview', 'print', 'save', 'template']
                ]],
                # // (min-width: 480)
                ['%480', [
                    ['undo', 'redo'],
                    [':p-More Paragraph-default.more_paragraph', 'font', 'fontSize', 'formatBlock', 'paragraphStyle', 'blockquote'],
                    [':t-More Text-default.more_text', 'bold', 'underline', 'italic', 'strike', 'subscript', 'superscript', 'fontColor', 'hiliteColor', 'textStyle', 'removeFormat'],
                    [':e-More Line-default.more_horizontal', 'outdent', 'indent', 'align', 'horizontalRule', 'list', 'lineHeight'],
                    [':r-More Rich-default.more_plus', 'table', 'link', 'image', 'video', 'audio', 'imageGallery'],
                    ['-right', ':i-More Misc-default.more_vertical', 'fullScreen', 'showBlocks', 'codeView', 'preview', 'print', 'save', 'template']
                ]]
            ]
            lang: SUNEDITOR_LANG['en']
            # codeMirror: CodeMirror
        });
    
    Template.html_edit.events
        'blur .testsun': (e,t)->
            html = t.editor.getContents(onlyContents: Boolean);
    
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":html
            else 
                Meteor.users.update parent._id, 
                    $set:"#{@key}":html
    
    Template.html_edit.helpers
            
    
    
    Template.color_icon_edit.events
        'blur .color_icon': (e,t)->
            val = t.$('.color_icon').val()
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
    
    
    
    
    Template.clear_value.events
        'click .clear_value': ->
            Swal.fire({
                title: "Clear #{@title} field?"
                # text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'clear'
                confirmButtonColor: 'yellow'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    parent = Template.parentData()
                    doc = Docs.findOne parent._id
                    if doc
                        Docs.update parent._id,
                            $unset:"#{@key}":1
            )
    
            # if confirm "Clear #{@title} field?"
            #     if @direct
            #         parent = Template.parentData()
            #     else
            #         parent = Template.parentData(5)
            #     doc = Docs.findOne parent._id
            #     if doc
            #         Docs.update parent._id,
            #             $unset:"#{@key}":1
    
    
    Template.link_edit.events
        'blur .edit_url': (e,t)->
            val = t.$('.edit_url').val()
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else if user
                Meteor.users.update parent._id,
                    $set:"#{@key}":val
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key}=#{val} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    
    Template.icon_edit.events
        'blur .icon_val': (e,t)->
            val = t.$('.icon_val').val()
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else if user
                Meteor.users.update parent._id,
                    $set:"#{@key}":val
                
    Template.image_link_edit.events
        'blur .image_link_val': (e,t)->
            val = t.$('.image_link_val').val()
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else if user
                Meteor.users.update parent._id,
                    $set:"#{@key}":val
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    
    Template.image_edit.events
        "change input[name='upload_image']": (e) ->
            files = e.currentTarget.files
            parent = Template.parentData()
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) => #optional callback, you can catch with the Cloudinary collection as well
                    if err
                        console.error 'Error uploading', err
                    else
                        doc = Docs.findOne parent._id
                        
                        if doc
                            Docs.update parent._id,
                                $set:"#{@key}":res.public_id
                        else 
                            Meteor.users.update parent._id,
                                $set:"#{@key}":res.public_id
                            
        'click .call_cloud_visual': (e,t)->
            Meteor.call 'call_visual', Router.current().params.doc_id, 'cloud', ->
                $('body').toast(
                    showIcon: 'dna'
                    message: 'image autotagged'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                    position: "bottom center"
                )
    
    
        'blur .cloudinary_id': (e,t)->
            cloudinary_id = t.$('.cloudinary_id').val()
            parent = Template.parentData()
            Docs.update parent._id,
                $set:"#{@key}":cloudinary_id
    
    
        'click #remove_photo': ->
            parent = Template.parentData()
    
            if confirm 'Remove Photo?'
                # Docs.update parent._id,
                #     $unset:"#{@key}":1
                doc = Docs.findOne parent._id
                if doc
                    Docs.update parent._id,
                        $unset:"#{@key}":1
                else 
                    Meteor.users.update parent._id,
                        $unset:"#{@key}":1
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    
    
    Template.multi_user_view.helpers
        user_docs: ->
            console.log @
    
    Template.array_edit.events
        # 'click .touch_element': (e,t)->
        #     $(e.currentTarget).closest('.touch_element').transition('slide left')
            
        'click .pick_tag': (e,t)->
            # console.log @
            picked_tags.clear()
            picked_tags.push @valueOf()
            Router.go "/#{Router.current().params.group}"
            Router.call 'search_reddit', @valueOf(), ->
        'keyup .new_element': (e,t)->
            if e.which is 13
                element_val = t.$('.new_element').val().trim().toLowerCase()
                if element_val.length>0
                    parent = Template.parentData()
                    doc = Docs.findOne parent._id
    
                    if doc
                        Docs.update parent._id,
                            $addToSet:"#{@key}":element_val
                    else 
                        Meteor.users.update parent._id,
                            $addToSet:"#{@key}":element_val
                        
                    # window.speechSynthesis.speak new SpeechSynthesisUtterance element_val
                    t.$('.new_element').val('')
        'click .add_element': (e,t)->
            element_val = t.$('.new_element').val().trim().toLowerCase()
            if element_val.length>0
                parent = Template.parentData()
                doc = Docs.findOne parent._id

                if doc
                    Docs.update parent._id,
                        $addToSet:"#{@key}":element_val
                else 
                    Meteor.users.update parent._id,
                        $addToSet:"#{@key}":element_val
                    
                # window.speechSynthesis.speak new SpeechSynthesisUtterance element_val
                t.$('.new_element').val('')
    
        'click .remove_element': (e,t)->
            $(e.currentTarget).closest('.touch_element').transition('slide left', 1000)
    
            element = @valueOf()
            field = Template.currentData()
            # if field.direct
            parent = Template.parentData()
            # else
            #     parent = Template.parentData(5)
    
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:"#{field.key}":element
            else 
                Meteor.users.update parent._id, 
                    $pull:"#{field.key}":element
                    
            t.$('.new_element').focus()
            t.$('.new_element').val(element)
    
    # Template.textarea.onCreated ->
    #     @editing = new ReactiveVar false
    
    # Template.textarea.helpers
    #     is_editing: -> Template.instance().editing.get()
    
    
    Template.textarea_edit.events
        # 'click .toggle_edit': (e,t)->
        #     t.editing.set !t.editing.get()
    
        'blur .edit_textarea': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            parent = Template.parentData()
    
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":textarea_val
            else 
                Meteor.users.update parent._id, 
                    $set:"#{@key}":textarea_val
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    
    Template.raw_edit.events
        # 'click .toggle_edit': (e,t)->
        #     t.editing.set !t.editing.get()
    
        'blur .edit_textarea': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            parent = Template.parentData()
    
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":textarea_val
            else 
                Meteor.users.update parent._id, 
                    $set:"#{@key}":textarea_val
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    
    
    Template.text_edit.events
        'focus .edit_text': (e)->
            $(e.currentTarget).closest('.input').transition('bounce', 500)

        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            parent = Template.parentData()
    
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else 
                Meteor.users.update parent._id, 
                    $set:"#{@key}":val
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )
    

    Template.location_edit.events
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            parent = Template.parentData()
    
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else 
                Meteor.users.update parent._id, 
                    $set:"#{@key}":val
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    
    
    
    Template.textarea_view.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    
    
    
    Template.number_edit.events
        'blur .edit_number': (e,t)->
            # console.log @
            parent = Template.parentData()
            val = parseInt t.$('.edit_number').val()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else 
                Meteor.users.update parent._id,
                    $set:"#{@key}":val
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    Template.float_edit.events
        'blur .edit_float': (e,t)->
            parent = Template.parentData()
            val = parseFloat t.$('.edit_float').val()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
            else 
                Meteor.users.update parent._id,
                    $set:"#{@key}":val
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )
  
    
    Template.slug_edit.events
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            parent = Template.parentData()
    
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":val
    
    
        'click .slugify_title': (e,t)->
            page_doc = Docs.findOne Router.current().params.doc_id
            # val = t.$('.edit_text').val()
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            Meteor.call 'slugify', page_doc._id, (err,res)=>
                Docs.update page_doc._id,
                    $set:slug:res
    
    
    Template.boolean_edit.helpers
        boolean_toggle_class: ->
            parent = Template.parentData()
            console.log parent["#{@key}"] 
            if parent["#{@key}"] then 'active big blue' else 'compact'
    
    
    Template.boolean_edit.events
        'click .toggle_boolean': (e,t)->
            parent = Template.parentData()
            # $(e.currentTarget).closest('.button').transition('pulse', 100)
    
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":!parent["#{@key}"]
            else 
                Meteor.users.update parent._id,
                    $set:"#{@key}":!parent["#{@key}"]
            $(e.currentTarget).closest('.button').transition('pulse', 500)
            Meteor.call 'calc_user_points', ->
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    Template.boolean_edit_icon.helpers
        boolean_toggle_class: ->
            parent = Template.parentData()
            if parent["#{@key}"] then 'large active' else 'grey small compact'
    Template.boolean_edit_icon.events
        'click .toggle_boolean': (e,t)->
            parent = Template.parentData()
            # $(e.currentTarget).closest('.button').transition('pulse', 100)
    
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":!parent["#{@key}"]
            else 
                Meteor.users.update parent._id,
                    $set:"#{@key}":!parent["#{@key}"]
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )
            $(e.currentTarget).closest('.button').transition('bounce', 500)
            Meteor.call 'calc_user_points', ->

    
    
    Template.single_doc_view.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', @data.ref_model
    
    Template.single_doc_view.helpers
        choices: ->
            Docs.find
                model:@ref_model
    
    
    
    
    Template.single_doc_edit.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', @data.ref_model
    
    Template.single_doc_edit.helpers
        choices: ->
            if @ref_model
                Docs.find {
                    model:@ref_model
                }, sort:slug:1
        calculated_label: ->
            ref_doc = Template.currentData()
            key = Template.parentData().button_label
            ref_doc["#{key}"]
    
        choice_class: ->
            selection = @
            current = Template.currentData()
            ref_field = Template.parentData(1)
            if ref_field.direct
                parent = Template.parentData(2)
            else
                parent = Template.parentData(5)
            target = Template.parentData(2)
            if @direct
                if target["#{ref_field.key}"]
                    if @ref_field is target["#{ref_field.key}"] then 'active' else ''
                else ''
            else
                if parent["#{ref_field.key}"]
                    if @slug is parent["#{ref_field.key}"] then 'active' else ''
                else ''
    
    
    Template.single_doc_edit.events
        'click .select_choice': ->
            selection = @
            ref_field = Template.currentData()
            if ref_field.direct
                parent = Template.parentData()
            else
                parent = Template.parentData(5)
            # parent = Template.parentData(1)
    
            # key = ref_field.button_key
            key = ref_field.key
    
    
            # if parent["#{key}"] and @["#{ref_field.button_key}"] in parent["#{key}"]
            if parent["#{key}"] and @slug in parent["#{key}"]
                doc = Docs.findOne parent._id
                if doc
                    Docs.update parent._id,
                        $unset:"#{ref_field.key}":1
                else 
                        Meteor.users.update parent._id,
                            $set: "#{ref_field.key}": @slug
            else
                doc = Docs.findOne parent._id
    
                if doc
                    Docs.update parent._id,
                        $set: "#{ref_field.key}": @slug
                else 
                    Meteor.users.update parent._id,
                        $set: "#{ref_field.key}": @slug
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    
    Template.multi_doc_view.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', @data.ref_model
    
    Template.multi_doc_view.helpers
        choices: ->
            Docs.find {
                model:@ref_model
            }, sort:number:-1
    
    # Template.multi_doc_edit.onRendered ->
    #     $('.ui.dropdown').dropdown(
    #         clearable:true
    #         action: 'activate'
    #         onChange: (text,value,$selectedItem)->
    #         )
    
    
    
    Template.multi_doc_edit.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', @data.ref_model
    Template.multi_doc_edit.helpers
        choices: ->
            Docs.find model:@ref_model
    
        choice_class: ->
            selection = @
            current = Template.currentData()
            parent = Template.parentData()
            ref_field = Template.parentData(1)
            target = Template.parentData(2)
    
            if target["#{ref_field.key}"]
                if @slug in target["#{ref_field.key}"] then 'active' else ''
            else
                ''
    
    
    Template.multi_doc_edit.events
        'click .select_choice': ->
            selection = @
            ref_field = Template.currentData()
            if ref_field.direct
                parent = Template.parentData(2)
            else
                parent = Template.parentData(6)
            parent = Template.parentData(1)
            parent2 = Template.parentData(2)
            parent3 = Template.parentData(3)
            parent4 = Template.parentData(4)
            parent5 = Template.parentData(5)
            parent6 = Template.parentData(6)
            parent7 = Template.parentData(7)
    
            #
    
            if parent["#{ref_field.key}"] and @slug in parent["#{ref_field.key}"]
                doc = Docs.findOne parent._id
                if doc
                    Docs.update parent._id,
                        $pull:"#{ref_field.key}":@slug
            else
                doc = Docs.findOne parent._id
                if doc
                    Docs.update parent._id,
                        $addToSet: "#{ref_field.key}": @slug
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key} saved"
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    
    Template.single_user_edit.onCreated ->
        @user_results = new ReactiveVar
        # console.log @data.key
        # @autorun => Meteor.subscribe 'user_info_min', ->
        @autorun => Meteor.subscribe 'user_by_ref', @data.key, Template.parentData(),->
            
if Meteor.isServer
    Meteor.publish 'user_by_ref', (key, parent)->
        # console.log key
        # console.log parent
        Meteor.users.find 
            _id: parent["#{key}_id"]
    
if Meteor.isClient
    Template.single_user_edit.helpers
        picked_user: ->
            # console.log @
            # console.log "#{@key}_id"
            if Router.current().params.doc_id
                parent_doc_value = Docs.findOne(Router.current().params.doc_id)["#{@key}_id"]
            if parent_doc_value 
                found = Meteor.users.findOne _id:parent_doc_value
            else 
                parent_user_value = Meteor.users.findOne(username:Router.current().params.username)["#{@key}_id"]
                found = Meteor.users.findOne _id:parent_user_value
        user_results: ->Template.instance().user_results.get()
        current_user_search: -> Session.get('current_user_search')
    Template.single_user_edit.events
        'click .clear_results': (e,t)->
            t.user_results.set null
    
        'keyup .single_user_select_input': (e,t)->
            search_value = $(e.currentTarget).closest('.single_user_select_input').val().trim()
            Session.set('current_user_search',search_value)
            if search_value.length > 1
                # console.log 'searching', search_value
                Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
                    if err then console.error err
                    else
                        # console.log res
                        t.user_results.set res
    
        'click .select_user': (e,t) ->
            page_doc = Docs.findOne Router.current().params.doc_id
            field = Template.currentData()
    
            # console.log @
            # console.log Template.currentData()
            # console.log Template.parentData()
            # console.log Template.parentData(1)
            # console.log Template.parentData(2)
            # console.log Template.parentData(3)
            # console.log Template.parentData(4)
    
            
            val = t.$('.edit_text').val()
            # if field.direct
            parent = Template.parentData()
            # else
            #     parent = Template.parentData(5)
            
            doc = Docs.findOne Router.current().params.doc_id
            user = Meteor.users.findOne username:Router.current().params.username
            if doc
                Docs.update doc._id,
                    $set:
                        "#{field.key}_id":@_id
                        "#{field.key}_username":@username
            else if user
                Meteor.users.update parent._id,
                    $set:
                        "#{field.key}_id":@_id
                        "#{field.key}_username":@username
                
            $('.single_user_select_input').val ''
            location.reload()
            # Docs.update page_doc._id,
            #     $set: assignment_timestamp:Date.now()
    
        'click .pull_user': ->
            console.log @
            if confirm "remove #{@key}?"
                parent = Template.parentData(1)
                # field = Template.currentData()
                doc = Docs.findOne parent._id
                if doc
                    Docs.update parent._id,
                        $unset:
                            "#{@key}_id":1
                            "#{@key}_username":1
                else 
                    Meteor.users.update parent._id, 
                        $unset:
                            "#{@key}_id":1
                            "#{@key}_username":1
    
            # #     page_doc = Docs.findOne Router.current().params.doc_id
            #     # Meteor.call 'unassign_user', page_doc._id, @
    
        'click .add_user':->
            new_username = prompt('username')
            splitted = new_username.split(' ')
            formatted = new_username.split(' ').join('_').toLowerCase()
            console.log formatted
            Meteor.call 'add_user', formatted, (err,res)->
                console.log res
                # new_user = Meteor.users.findOne res
                Meteor.users.update res,
                    $set:
                        first_name:splitted[0]
                        last_name:splitted[1]
                # Router.go "/user/#{formatted}"
                $('body').toast({
                    title: "user created"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    icon:'user'
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
            
    
    
    Template.multi_user_edit.onCreated ->
        @user_results = new ReactiveVar
        @autorun = Meteor.subscribe 'user_info_min', ->
    Template.multi_user_edit.helpers
        user_results: -> Template.instance().user_results.get()
        picked_users: ->
            # console.log Template.parentData()
            Meteor.users.find 
                _id:$in:Template.parentData()["#{@key}_ids"]
    Template.multi_user_edit.events
        'click .clear_results': (e,t)->
            t.user_results.set null
    
        'keyup .multi_user_select_input': (e,t)->
            search_value = $(e.currentTarget).closest('.multi_user_select_input').val().trim()
            if search_value.length > 1
                console.log 'searching', search_value
                Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
                    if err then console.error err
                    else
                        t.user_results.set res
    
        'click .select_user': (e,t) ->
            page_doc = Docs.findOne Router.current().params.doc_id
            field = Template.currentData()
    
            # console.log @
            # console.log Template.currentData()
            # console.log Template.parentData()
            # console.log Template.parentData(1)
            # console.log Template.parentData(2)
            # console.log Template.parentData(3)
            # console.log Template.parentData(4)
    
    
            val = t.$('.edit_text').val()
            # if field.direct
            parent = Template.parentData()
            # else
            #     parent = Template.parentData(5)
    
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $addToSet:
                        "#{field.key}_ids":@_id
                        "#{field.key}_usernames":@username
            else if user 
                Meteor.users.update parent._id,
                    $addToSet:
                        "#{field.key}_ids":@_id
                        "#{field.key}_usernames":@username
                    
            t.user_results.set null
            $('.single_user_select_input').val ''
            # Docs.update page_doc._id,
            #     $set: assignment_timestamp:Date.now()
    
        'click .pull_user': ->
            if confirm "remove #{@username}?"
                parent = Template.parentData(1)
                field = Template.currentData()
                doc = Docs.findOne parent._id
                if doc
                    Docs.update parent._id,
                        $pull:
                            "#{field.key}_ids":@_id
                            "#{field.key}_usernames":@username
                user = Meteor.users.findOne parent._id
                if user 
                    Meteor.users.update parent._id,
                        $pull:
                            "#{field.key}_ids":@_id
                            "#{field.key}_usernames":@username
    
            #     page_doc = Docs.findOne Router.current().params.doc_id
                # Meteor.call 'unassign_user', page_doc._id, @
    
    
    