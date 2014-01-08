class StatusActivityItemView extends ActivityItemChild
  constructor:(options = {}, data={})->
    options.cssClass or= "activity-item status"
    options.tooltip  or=
      title            : "Status Update"
      selector         : "span.type-icon"
      offset           :
        top            : 3
        left           : -5

    super options, data

    embedOptions  =
      hasDropdown : no
      delegate    : this

    if data.link?
      @embedBox = new EmbedBox embedOptions, data.link
      @setClass "two-columns"  if @twoColumns
    else
      @embedBox = new KDCustomHTMLView

    @timeAgoView = new KDTimeAgoView {}, @getData().meta.createdAt

    @editWidgetWrapper = new KDCustomHTMLView
      cssClass         : "edit-widget-wrapper hidden"


  formatContent: (str = "")->
    str = @utils.applyMarkdown str
    str = @utils.expandTokens str, @getData()
    return  str

  viewAppended:->
    return if @getData().constructor is KD.remote.api.CStatusActivity
    super
    @setTemplate @pistachio()
    @template.update()

    @setAnchors()

    @utils.defer =>
      predicate = @getData().link?.link_url? and @getData().link.link_url isnt ''
      if predicate
      then @embedBox.show()
      else @embedBox.hide()

  setAnchors: ->
    @$("article a").each (index, element) ->
      {location: {origin}} = window
      href = element.getAttribute "href"
      return  unless href

      beginning = href.substring 0, origin.length
      rest      = href.substring origin.length + 1

      if beginning is origin
        element.setAttribute "href", "/#{rest}"
        element.classList.add "internal"
      else
        element.setAttribute "target", "_blank"

  click: (event) ->
    super event
    {target} = event
    if $(target).is "article a.internal"
      @utils.stopDOMEvent event
      href = target.getAttribute "href"
      KD.singleton("router").handleRoute href

  pistachio:->
    """
      {{> @avatar}}
      {{> @settingsButton}}
      {{> @author}}
      {{> @editWidgetWrapper}}
      {article{@formatContent #(body)}}
      {{> @embedBox}}
      <footer>
        {{> @actionLinks}}
        {{> @timeAgoView}}
      </footer>
      {{> @commentBox}}
    """
