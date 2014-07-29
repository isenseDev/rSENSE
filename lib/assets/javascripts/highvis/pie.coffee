###
  * Copyright (c) 2011, iSENSE Project. All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
  *
  * Redistributions of source code must retain the above copyright notice, this
  * list of conditions and the following disclaimer. Redistributions in binary
  * form must reproduce the above copyright notice, this list of conditions and
  * the following disclaimer in the documentation and/or other materials
  * provided with the distribution. Neither the name of the University of
  * Massachusetts Lowell nor the names of its contributors may be used to
  * endorse or promote products derived from this software without specific
  * prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
  * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
###
$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis", "embedVis", "show"]

    class window.Pie extends BaseHighVis
      constructor: (@canvas) ->
        if data.normalFields.length > 1
          @displayField = data.normalFields[1]
        else @displayField = data.normalFields[0]

        @selected_field = 3

      start: () ->
        super()
        @update()
        
      update: () ->
        @rel_data = []
        @selected_field = @displayField
        @getGroupedData()

        ###for dp in data.dataPoints
          do =>
            @rel_data.push dp[@selected_field]

        sum = @rel_data.reduce (x, y) -> x + y

        #if (sum > 95 and sum <= 100) or (sum > .95 and sum <= 1)
        #  @use_value = true
        #else
        #  @use_value = false
        
        @use_value = true###
        
        while @chart.series.length > 0
          @chart.series[@chart.series.length - 1].remove false

        if !@select_name?
          
          if data.textFields.length > 2
            @select_name = data.textFields[2]
          else
            @select_name = 'Percent'

        ###if @use_value is true
          @display_data = []

          if data.groupingFieldIndex is 1 or data.groupingFieldIndex is 2
            row_index = 0

            for dp in @rel_data
              do =>
                @display_data.push [data.dataPoints[row_index][@select_name], dp]
                row_index++
          else
            

        else
          @display_data = []
          #select name could be group by
          @display_data.push ["#{data.dataPoints[0][@selected_field]}", 1]
          
          for dp in data.dataPoints[1..]
            do =>
              exist = []
              for existence in @display_data
                do =>
                  exist.push existence[0]
              if "#{dp[@selected_field]}" in exist
                for find_name in @display_data
                  do =>
                    if find_name[0] == "#{dp[@selected_field]}"
                      find_name[1] += 1
              else
                @display_data.push ["#{dp[@selected_field]}", 1]

          @normalize()###

        options =
          showInLegend: false
          data: @display_data
          
        @chart.setTitle { text: "#{data.fields[@select_name].fieldName} by #{data.fields[@selected_field].fieldName}" }

        @chart.addSeries options, false
        @chart.redraw()

      normalize: ->
        sum = 0

        for dp in @display_data
          do =>
            sum += dp[1]

        for dp in @display_data
          do =>
            dp[1] = ( dp[1] / sum ) *100

      getGroupedData: ->
        tmp = {}
        for group in data.groups
          do =>
            tmp[group.toLowerCase()] = 0
            
        for dp in data.dataPoints
          do =>
            tmp[dp[data.groupingFieldIndex].toLowerCase()] += dp[@selected_field]
            
        @display_data = []
            
        for key, value of tmp
          @display_data.push [key, value]
          
        console.log @display_data
            
      buildOptions: ->
        super()

        self = this
        @chartOptions

        $.extend true, @chartOptions,
          chart:
            type: "pie"
          title:
            text: "#{data.fields[@selected_field].fieldName}"
          tooltip:
            pointFormat: '{point.name}: <b>{point.percentage:.1f}%</b>'
          plotOptions:
            pie:
              allowPointSelect: true
              cursor: 'pointer'
              dataLabels:
                enabled: true
                format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                style:
                  color: 'black'
          series: [{
            type: 'pie'
            data: 
              [['Firefox', 50], ['Other', 50]]
            }]

      drawLabelControls: ->
        controls = '<div id="labelControl" class="vis_controls">'
        controls += "<h3 class='clean_shrink'><a href='#'>Label:</a></h3>"
        controls += "<div class='outer_control_div'>"
        for fields, f_index in data.textFields[2..]
          do =>
            controls += "<div class='inner_control_div'><div class='radio'><label>#{data.fields[fields].fieldName}"
            controls += "<input class='label_input' type='radio' name='labels' value='#{fields}'"
            if f_index == 0
              controls += "checked"
            controls += "></label></div></div>"

        controls += '</div></div>'
        ($ '#controldiv').append controls
        
        ($ '.label_input').click (e) =>
          @select_name = Number e.target.value
          @delayedUpdate()
        
        globals.labelOpen ?= 0
        ($ '#labelControl').accordion
          collapsible: true
          active: globals.labelOpen
          
        ($ '#labelControl > h3').click ->
          globals.labelOpen = (globals.labelOpen + 1) % 2
          
      ###drawYAxisControls: (radio = false) ->

        controls = '<div id="yAxisControl" class="vis_controls">'

        if radio
          controls += "<h3 class='clean_shrink'><a href='#'>Field:</a></h3>"
        else
          controls += "<h3 class='clean_shrink'><a href='#'>Y Axis:</a></h3>"

        controls += "<div class='outer_control_div'>"

        # Populate choices
        for fIndex in data.normalFields[1..]
          controls += "<div class='inner_control_div' >"

          if radio
            controls += """<div class='radio'><label><input class='y_axis_input' name='y_axis_group'
              type='radio' value='#{fIndex}'
              #{if (Number fIndex) is @displayField then "checked" else ""}>
              #{data.fields[fIndex].fieldName}</label></div>"""
          else
            controls += """<div class='checkbox'><label><input class='y_axis_input' type='checkbox'
              value='#{fIndex}' #{if (Number fIndex) in globals.fieldSelection then "checked" else ""}
              />#{data.fields[fIndex].fieldName}</label></div>"""
          controls += "</div>"

        controls += '</div></div>'

        # Write HTML
        ($ '#controldiv').append controls

        # Make y axis checkbox/radio handler
        if radio
          ($ '.y_axis_input').click (e) =>
            @displayField = Number e.target.value
            @delayedUpdate()
        else
          ($ '.y_axis_input').click (e) =>
            index = Number e.target.value

            if index in globals.fieldSelection
              arrayRemove(globals.fieldSelection, index)
            else
              globals.fieldSelection.push(index)
            @delayedUpdate()

        # Set up accordion
        globals.yAxisOpen ?= 0

        ($ '#yAxisControl').accordion
          collapsible:true
          active:globals.yAxisOpen

        ($ '#yAxisControl > h3').click ->
          globals.yAxisOpen = (globals.yAxisOpen + 1) % 2###


      drawControls: ->
        super()
        @drawGroupControls()
        @drawYAxisControls true #horrible name for what im doing here
        #@drawLabelControls()
        @drawSaveControls()


    if "Pie" in data.relVis
      globals.pie = new Pie 'pie_canvas'
      #globals.percentage = new Bar 'percentage_canvas'
    else
      globals.pie = new DisabledVis 'pie_canvas'
