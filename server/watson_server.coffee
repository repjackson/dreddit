NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
ToneAnalyzerV3 = require('ibm-watson/tone-analyzer/v3')
# VisualRecognitionV3 = require('ibm-watson/visual-recognition/v3')
# PersonalityInsightsV3 = require('ibm-watson/personality-insights/v3')
# TextToSpeechV1 = require('ibm-watson/text-to-speech/v1')

{ IamAuthenticator } = require('ibm-watson/auth')

natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2019-07-12'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.language.apikey
    })
    url: Meteor.settings.private.language.url)
# lang
# mkdgRJwYEJnuJUhCv0Ny7REL4scA27el5mdPKrnGMEMg
# textToSpeech = new TextToSpeechV1({
#   authenticator: new IamAuthenticator({
#     apikey: Meteor.settings.private.tts.apikey,
#   }),
#   url: Meteor.settings.private.tts.url,
# });


# kevin lang
# bsbqj-_iQaA-ZwGUBK7NbGqZTaLvPHJgZW2OEXoN5C6P
# https://api.us-south.natural-language-understanding.watson.cloud.ibm.com/instances/5556901d-0bb1-4283-a2e3-d4cd8c42d15c


# tone
# QEDjdS8Btn2Qq1IFKWu1wirCfdCziCEJhaWt_Tn5MY87
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/6755dca9-6933-4529-81df-a985e6447170

# wDsUCpvjNiwBjDs5C1GvHwb970BDHBOcah_KXs-boFgG
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/6755dca9-6933-4529-81df-a985e6447170

# tone
# pIDLJyNdM8r4AB0lLmMNdGZtPSWUD3wXQfmXFBWxJ_l
# https://api.us-south.tone-analyzer.watson.cloud.ibm.com/instances/37f08ca3-6c5b-439e-8270-78d96b54d635
# nlu
# WfilOI8O3M5n3cbU8byEczW_hctUm4viZDVaBSV-Gju3
# https://api.us-south.natural-language-understanding.watson.cloud.ibm.com/instances/b5195ac7-a729-46ea-b099-deb37d1dc65b

Meteor.methods
    call_tone: (doc_id, key)->
        # @unblock()
        self = @
        doc = Docs.findOne doc_id
        console.log key, 'key'
        # if doc.html or doc.body
        #     # stringed = JSON.stringify(doc.html, null, 2)
        # if mode is 'html'
        #     params =
        #         toneInput:doc.description
        #         content_type:'text/html'
        # if mode is 'text'
        params =
            # toneInput: { 'text': doc.watson.analyzed_text }
            # contentType: 'application/json'
            {
              "language": "en",
              "text": doc.watson.analyzed_text,
              "features": {
                "classifications": {
                  "model": "tone-classifications-en-v1"
                }
              }
            }
            
        # console.log 'params', params
        natural_language_understanding.analyze params, Meteor.bindEnvironment((err, response)=>
            if err
                console.log 'watson error for', params.content
                # console.log err
                if err.code is 400
                    console.log 'crawl rejected by server'
                unless err.code is 403
                    # Docs.update doc_id,
                    #     $set:skip_watson:false
                    console.log 'not html, flaggged doc for future skip', params.url, err
                else
                    console.log '403 error api key'
            else
                console.log 'analy text', response.analyzed_text
                console.log response.result
                Docs.update doc_id, 
                    $set:
                        tone:response.result
                # console.log(JSON.stringify(response, null, 2));
                # console.log 'adding watson info', doc.title
                # response = response.result
        # else return
        )


    call_watson: (doc_id, key, mode) ->
        console.log 'calling watson', doc_id, key, mode
        # @unblock()
        self = @
        # console.log doc_id
        # console.log key
        # console.log mode
        doc = Docs.findOne doc_id
        # unless doc 
        #     doc = Meteor.users.findOne doc_id
        # console.log 'calling watson on', doc.title
        # if doc.skip_watson is false
        #     console.log 'skipping flagged doc', doc.title
        # else
        # console.log 'analyzing', doc.title, 'tags', doc.tags
        if doc
            parameters =
                concepts:
                    limit:20
                features:
                    entities:
                        emotion: true
                        sentiment: true
                        mentions: true
                        limit: 20
                    keywords:
                        emotion: true
                        sentiment: true
                        limit: 20
                    concepts: {}
                    categories:
                        explanation:true
                    emotion: {}
                    metadata: {}
                    relations: {}
                    # semantic_roles: {}
                    sentiment: {}
            # parameters.url = doc.url
        # if doc.domain and doc.domain in ['i.redd.it','i.imgur.com','imgur.com','gyfycat.com','m.youtube.com','v.redd.it','giphy.com','youtube.com','youtu.be']
        #     parameters.url = "https://www.reddit.com#{doc.permalink}"
        #     parameters.returnAnalyzedText = false
        #     parameters.clean = false
        #     console.log 'calling image'
        # else 
        # else
        #     parameters.html = doc["#{key}"]
        #     parameters.content = doc["#{key}"]
        # parameters.returnAnalyzedText = true
        switch mode
            when 'html'
                # parameters.html = doc["#{key}"]
                if doc.title
                    parameters.html = doc.title + " " + doc[key]
                else 
                    parameters.html = doc[key]
                parameters.returnAnalyzedText = true
            when 'text'
                parameters.text = doc["#{key}"]
            when 'url'
                # parameters.url = doc["#{key}"]
                parameters.url = "https://www.reddit.com#{doc.permalink}"
                parameters.returnAnalyzedText = true
                parameters.clean = true

                # parameters.metadata = {}
            when 'video'
                parameters.url = "https://www.reddit.com#{doc.permalink}"
                parameters.returnAnalyzedText = false
                parameters.clean = true
                # console.log 'calling video'
            when 'image'
                parameters.returnAnalyzedText = false
                parameters.clean = true
                console.log 'calling image'
            when 'subreddit'
                parameters.html = doc.reddit_data.public_description
            when 'redditor'
                parameters.html = doc.reddit_data.subreddit.public_description
            when 'comment'
                parameters.html = doc.reddit_data.body
                

        # console.log 'parameters', parameters


        natural_language_understanding.analyze parameters, Meteor.bindEnvironment((err, response)=>
            if err
                # console.log 'watson error for', parameters
                console.log err
                if err.code is 400
                    console.log 'crawl rejected by server'
                # unless err.code is 403
                #     Docs.update doc_id,
                #         $set:skip_watson:false
                #     console.log 'not html, flaggged doc for future skip', parameters.url
                # else
                #     console.log '403 error api key'
            else
                # console.log 'analy text', response.analyzed_text
                # console.log(JSON.stringify(response, null, 2));
                # console.log 'adding watson info', doc.title
                response = response.result
                # console.log response
                # console.log 'lowered keywords', lowered_keywords
                # if Meteor.isDevelopment
                #     console.log 'categories',response.categories
                unless response.emotion
                    console.log 'no emotion'
                # console.log response.emotion
                
                emotions = response.emotion.document.emotion

                emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
                # main_emotions = []
                max_emotion_percent = 0
                max_emotion_name = ''

                for emotion in emotion_list
                    if emotions["#{emotion}"] > max_emotion_percent
                        if emotions["#{emotion}"] > .5
                            max_emotion_percent = emotions["#{emotion}"]
                            max_emotion_name = emotion
                            # console.log emotion_doc["#{emotion}_percent"]
                            # main_emotions.push emotion

                # console.log 'emotions', emotions
                sadness_percent = emotions.sadness
                joy_percent = emotions.joy
                fear_percent = emotions.fear
                anger_percent = emotions.anger
                disgust_percent = emotions.disgust
                # console.log 'main_emotion', max_emotion_name
                # console.log 'max_emotion_percent', max_emotion_percent
                # if mode is 'url'
                if Docs.findOne doc_id
                    Docs.update { _id: doc_id },
                        $set:
                            # analyzed_text:response.analyzed_text
                            watson: response
                            max_emotion_name:max_emotion_name
                            max_emotion_percent:max_emotion_percent
                            sadness_percent: sadness_percent
                            joy_percent: joy_percent
                            fear_percent: fear_percent
                            anger_percent: anger_percent
                            disgust_percent: disgust_percent
                            watson_concepts: concept_array
                            watson_keywords: keyword_array
                            doc_sentiment_score: response.sentiment.document.score
                            doc_sentiment_label: response.sentiment.document.label
                else 
                    Meteor.users.update doc_id,
                        $set:
                            # analyzed_text:response.analyzed_text
                            watson: response
                            max_emotion_name:max_emotion_name
                            max_emotion_percent:max_emotion_percent
                            sadness_percent: sadness_percent
                            joy_percent: joy_percent
                            fear_percent: fear_percent
                            anger_percent: anger_percent
                            disgust_percent: disgust_percent
                            watson_concepts: concept_array
                            watson_keywords: keyword_array
                            doc_sentiment_score: response.sentiment.document.score
                            doc_sentiment_label: response.sentiment.document.label



                adding_tags = []
                if response.categories
                    for category in response.categories
                        # console.log category.label.split('/')[1..]
                        # console.log category.label.split('/')
                        for category in category.label.split('/')
                            if category.length > 0
                                # adding_tags.push category
                                Docs.update doc_id,
                                    $addToSet: categories: category
                if Docs.findOne doc_id
                    Docs.update { _id: doc_id },
                        $addToSet:
                            tags:$each:adding_tags
                else 
                    Meteor.users.update doc_id,
                        $addToSet:
                            tags:$each:adding_tags
                        
                if response.entities and response.entities.length > 0
                    for entity in response.entities
                        # console.log entity.type, entity.text
                        unless entity.type is 'Quantity'
                            # if Meteor.isDevelopment
                            #     console.log('quantity', entity.text)
                            # else
                            if entity.type is 'Location'
                                Docs.update { _id: doc_id }, 
                                    $addToSet: location_tags:entity.text
                            Docs.update { _id: doc_id },
                                $addToSet:
                                    # "#{entity.type}":entity.text
                                    tags:entity.text.toLowerCase()
                concept_array = _.pluck(response.concepts, 'text')
                lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                keyword_array = _.pluck(response.keywords, 'text')
                lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()

                keywords_concepts = lowered_keywords.concat lowered_keywords
                if Docs.findOne doc_id
                    Docs.update { _id: doc_id },{$addToSet:tags:$each:lowered_concepts}
                    Docs.update { _id: doc_id },{$addToSet:tags:$each:lowered_keywords}
                else if Meteor.users.findOne doc_id
                    Meteor.users.update { _id: doc_id },{$addToSet:tags:$each:lowered_concepts}
                    Meteor.users.update { _id: doc_id },{$addToSet:tags:$each:lowered_keywords}
                    
                # final_doc = Docs.findOne doc_id
                # console.log 'FINAL DOC tags',final_doc.tags

                # if mode is 'url'
                #     # if doc.model is 'wikipedia'
                #     Meteor.call 'call_tone', doc_id, 'body', 'text', ->
                Meteor.call 'clear_blocklist_doc', doc_id, ->
                
                # Meteor.call 'log_doc_terms', doc_id, ->
                # if Meteor.isDevelopment
                #     console.log 'all tags', final_doc.tags
                    # console.log 'final doc tag', final_doc.title, final_doc.tags.length, 'length'
        )
        
        