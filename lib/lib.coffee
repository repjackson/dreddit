@Docs = new Meteor.Collection 'docs'
@Results = new Meteor.Collection 'results'
# @Markers = new Meteor.Collection 'markers'
@Tags = new Meteor.Collection 'tags'



Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false

Router.route '/reddit', -> @render 'posts'
Router.route '*', -> @render 'food'
# Router.route '/', -> @render 'reddit'

# Router.route "/food/:food_id", -> @render 'food_doc'


Docs.before.insert (userId, doc)->
    # doc._author_id = Meteor.userId()
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array
    doc.app = 'goldrun'
    doc.points = 0
    doc.downvoters = []
    doc.upvoters = []
    return

Docs.after.insert (userId, doc)->
    console.log doc.tags
    return

Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tag_count = doc.tags?.length
    # Meteor.call 'generate_authored_cloud'
), fetchPrevious: true


Docs.helpers
    _when: -> moment(@_timestamp).fromNow()
    three_tags: -> if @tags then @tags[..2]
    five_tags: -> if @tags then @tags[..4]
    seven_tags: -> if @tags then @tags[..7]
    ten_tags: -> if @tags then @tags[..10]
    is_visible: -> @published in [0,1]
    is_published: -> @published is 1
    is_anonymous: -> @published is 0
    is_private: -> @published is -1
    # from_user: ->
    #     if @from_user_id
    #         Docs.findOne @from_user_id
    # to_user: ->
    #     if @to_user_id
    #         Docs.findOne @to_user_id