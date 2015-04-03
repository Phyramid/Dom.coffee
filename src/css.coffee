do ->
  # Many things in here heavily inspired by jQuery.
  reNotWhitespace = /\S+/g

  getStyle = (el, name) ->
    ###
    Falls back to using getComputedStyle if `el.style` doesn't have what we
    need. Perhaps consider optimising this.
    ###
    if el.style[name]? && el.style[name].length > 0
      return el.style[name]
    else
      return getComputedStyle(el).getPropertyValue(name)

  setStyle = (el, name, value) ->
    el.style[name] = value

  hide = (el) ->
    return if !isVisible(el)
    display = getStyle(el, 'display')
    Dom.setElemData(el, 'oldDisplay', display) if display != 'none'
    setStyle(el, 'display', 'none')

  show = (el) ->
    return if isVisible(el)
    newDisplay = Dom.getElemData(el, 'oldDisplay') ||
                 Dom.getDefaultDisplay(el.tagName)
    setStyle(el, 'display', newDisplay)

  isVisible = (el) ->
    getStyle(el, 'display') != 'none'

  toggle = (el) ->
    if isVisible(el)
      hide(el)
    else
      show(el)

  trimClass = (cls) ->
    cls.replace(/[\t\r\n\f]/g, ' ')

  spaceClass = (cls) ->
    if cls
      ' ' + trimClass(cls) + ' '
    else
      ' '

  containsClass = (parent, child) ->
    spaceClass(parent).indexOf(spaceClass(child)) != -1

  hasClass = (el, cls) ->
    containsClass(el.className, cls)

  removeClass = (el, strClasses) ->
    classes = strClasses.match(reNotWhitespace) || []
    return if classes.length == 0
    classes.map (cls) ->
      return if !hasClass(el, cls)
      newClassName = el.className
      while containsClass(newClassName, cls)
        newClassName = spaceClass(newClassName).replace(spaceClass(cls), ' ')
      el.className = newClassName.trim()

  addClass = (el, strClasses) ->
    classes = strClasses.match(reNotWhitespace) || []
    return if classes.length == 0
    classes.map (cls) ->
      return if hasClass(el, cls)
      newClassName = spaceClass(el.className) + cls + ' '
      el.className = newClassName.trim()

  toggleClass = (el, strClasses) ->
    classes = strClasses.match(reNotWhitespace) || []
    return if classes.length == 0
    classes.map (cls) ->
      if hasClass(el, cls)
        removeClass(el, cls)
      else
        addClass(el, cls)

  Dom.prototype.extend {
    style: (name, value) ->
      if value?
        @map (el) -> setStyle(el, name, value)
      else
        @map (el) -> getStyle(el, name)
    show: -> @map(show)
    hide: -> @map(hide)
    isVisible: -> @map(isVisible)
    toggle: -> @map(toggle)
    addClass: (cls) ->
      @map (el) -> addClass(el, cls)
    removeClass: (cls) ->
      @map (el) -> removeClass(el, cls)
    toggleClass: (cls) ->
      @map (el) -> toggleClass(el, cls)
    hasClass: (cls) ->
      @map (el) -> hasClass(el, cls)
  }
