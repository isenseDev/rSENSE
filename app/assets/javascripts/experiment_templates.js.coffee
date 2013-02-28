# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

  ($ '#experiment_templates .pagination a').live 'click', ->
      $.getScript this.href
      false

  $("#experiment_templates_search").submit ->
      $.ajax
        url: this.action
        data: $(this).serialize()
        success: (data, textStatus)->
          
          $('#experiment_templates').isotope('remove', $('.item'))
          
          for object in data
            do (object) ->
              newItem =   "<div class='item'>"
  
              if(object.mediaPath)
                newItem += "<img src='#{object.mediaPath}'></img>"
                
              newItem +=  "<h4 style='margin-top:0px;'><a href='#{object.experimentPath}'>#{object.title}</a>"
              
              if(object.featured)
                newItem += "<span style='color:#57C142'> (featured)</span>"
          
              newItem +=  "</h4><b>Owner: </b><a href='#{object.ownerPath}'>#{object.ownerName}</a><br />"
              newItem +=  "<b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />"
              
              ###
              if(object.filters)
                newitem += "<b>#{object.filters}</b>"
              ###
              
              newItem +=  "</div>"
              
              newItem = $(newItem)
              
              $('#experiment_templates').append(newItem).isotope('insert', newItem)
          
          $(window).resize()
          
        dataType: "json"
      return false

  ($ '.experiment_templates_filter_checkbox').click ->
    ($ '#experiment_templates_search').submit()
    
  ($ '.experiment_templates_sort_select').change ->
    ($ '#experiment_templates_search').submit()
    
  $(".experiment_templates_sort_select").change ->
    $("#experiment_templates_search").submit()

  ### Get isotope up and running ###

  numCols = 1

  while $('#experiment_templates').width()/numCols>200
    numCols++

  $('#experiment_templates').imagesLoaded ->
   
    $('.item').width(($('#experiment_templates').width()/numCols)-35)
    $('#experiment_templates').isotope
      itemSelector : '.item'
      layoutMode : 'masonry'
      masonry:
        columnWidth: $('#experiment_templates').width()/numCols

  $("#experiment_templates_search").submit()

window.reLayout = ->

  numCols = 1

  while $('#experiment_templates').width()/numCols>200
    numCols++

  $('#experiment_templates').imagesLoaded ->

    $('.item').width(($('#experiment_templates').width()/numCols)-35)

    $('#experiment_templates').isotope
      itemSelector : '.item'
      layoutMode : 'masonry'
      masonry:
        columnWidth: $('#experiment_templates').width()/numCols
  true

$(window).resize reLayout