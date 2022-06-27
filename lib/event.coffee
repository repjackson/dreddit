if Meteor.isClient
    Router.route '/events/', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'

    Template.events.events
        'click .auth_eventbrite': ->
            Meteor.call 'auth_eventbrite', ->


if Meteor.isServer 
    Meteor.methods
        auth_eventbrite: ->
            link = "https://www.eventbriteapi.com/v3/users/me/?token=QLL5EULOADTSJDS74HH7"
            HTTP.get link,(err,response)=>
                console.log response
