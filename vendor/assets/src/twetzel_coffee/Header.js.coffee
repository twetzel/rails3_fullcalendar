((window) ->
  # compiled with:  http://js2coffee.org/
  Header = (calendar, options) ->
  
    # exports
  
    # locals
    t = @
    element = $([])
    tm = undefined
    
    render = ->
      tm = (if options.theme then "ui" else "fc")
      sections = options.header
      if sections
        element = $("<table class='fc-header' style='width:100%'/>").append($("<tr/>").append(renderSection("left")).append(renderSection("center")).append(renderSection("right")))
        element
    destroy = ->
      element.remove()
    renderSection = (position) ->
      e = $("<td class='fc-header-" + position + "'/>")
      buttonStr = options.header[position]
      if buttonStr
        $.each buttonStr.split(" "), (i) ->
          e.append "<span class='fc-header-space'/>"  if i > 0
          prevButton = undefined
          $.each @split(","), (j, buttonName) ->
            if buttonName is "title"
              e.append "<span class='fc-header-title'><h2>&nbsp;</h2></span>"
              prevButton.addClass tm + "-corner-right"  if prevButton
              prevButton = null
            else
              buttonClick = undefined
              if calendar[buttonName]
                buttonClick = calendar[buttonName] # calendar method
              else if fcViews[buttonName]
                buttonClick = ->
                  button.removeClass tm + "-state-hover" # forget why
                  calendar.changeView buttonName
              if buttonClick
                icon = (if options.theme then smartProperty(options.buttonIcons, buttonName) else null) # why are we using smartProperty here?
                text = smartProperty(options.buttonText, buttonName) # why are we using smartProperty here?
                button = $("<span class='fc-button fc-button-" + buttonName + " " + tm + "-state-default'>" + "<span class='fc-button-inner'>" + "<span class='fc-button-content'>" + ((if icon then "<span class='fc-icon-wrap'>" + "<span class='ui-icon ui-icon-" + icon + "'/>" + "</span>" else text)) + "</span>" + "<span class='fc-button-effect'><span></span></span>" + "</span>" + "</span>")
                if button
                  button.click(->
                    buttonClick()  unless button.hasClass(tm + "-state-disabled")
                  ).mousedown(->
                    button.not("." + tm + "-state-active").not("." + tm + "-state-disabled").addClass tm + "-state-down"
                  ).mouseup(->
                    button.removeClass tm + "-state-down"
                  ).hover(->
                    button.not("." + tm + "-state-active").not("." + tm + "-state-disabled").addClass tm + "-state-hover"
                  , ->
                    button.removeClass(tm + "-state-hover").removeClass tm + "-state-down"
                  ).appendTo e
                  button.addClass tm + "-corner-left"  unless prevButton
                  prevButton = button

          prevButton.addClass tm + "-corner-right"  if prevButton

      e
    updateTitle = (html) ->
      element.find("h2").html html
    activateButton = (buttonName) ->
      element.find("span.fc-button-" + buttonName).addClass tm + "-state-active"
    deactivateButton = (buttonName) ->
      element.find("span.fc-button-" + buttonName).removeClass tm + "-state-active"
    disableButton = (buttonName) ->
      element.find("span.fc-button-" + buttonName).addClass tm + "-state-disabled"
    enableButton = (buttonName) ->
      element.find("span.fc-button-" + buttonName).removeClass tm + "-state-disabled"

    @render = render
    @destroy = destroy
    @updateTitle = updateTitle
    @activateButton = activateButton
    @deactivateButton = deactivateButton
    @disableButton = disableButton
    @enableButton = enableButton
    
)(window)