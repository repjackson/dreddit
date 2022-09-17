@picked_tags = new ReactiveArray []
@picked_user_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []



# Tracker.autorun ->
#     current = Router.current()
#     Tracker.afterFlush ->
#         $(window).scrollTop 0
# Meteor.startup ->
#     process.env.TZ='America/Denver'
#     moment().calendar(null, {
#         sameDay: '[today]',
#         nextDay: '[tomorrow]',
#         nextWeek: 'dddd',
#         lastDay: '[yesterday]',
#         lastWeek: '[last] dddd',
#         sameElse: 'DD/MM/YYYY'
#     });

    
Template.layout.events
    'click .fly_down': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fade down', 500)
    'click .fly_up': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fade up', 500)
    'click .fly_left': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fade left', 500)
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .card_fly_right': (e,t)->
        $(e.currentTarget).closest('.card').transition('fade right', 500)
    'click .zoom': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .flip': (e,t)->
        $(e.currentTarget).closest('.grid').transition('flip', 500)
        
    # 'click a': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)

Router.route '/', (->
    @layout 'layout'
    @render 'posts'
    ), name:'home'