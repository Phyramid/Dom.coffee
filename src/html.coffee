do ->
  empty = (el) -> el.innerHTML = ''

  setHTML = (el, content) ->
    el.innerHTML = content

  getHTML = (el, content) ->
    return el.innerHTML

  append = (el, content) ->
    if typeof content == 'string'
      el.innerHTML ||= ''
      el.innerHTML += content
    else if Dom.isNode(content)
      el.appendChild(content)
    else if content instanceof Dom
      content.map (appendee) ->
        el.appendChild(appendee)
    else
      throw new Error('Dom.coffee: Invalid argument to .append(), must be either string, DOM element or Dom instance')

  appendTo = (el, parent) ->
    if Dom.isNode(parent)
      parent.appendChild(el)
    else if parent instanceof Dom
      parent.map (appender) ->
        appender.appendChild(el)
    else
      throw new Error('Dom.coffee: Invalid argument to .appendTo(), must be either DOM element or Dom instance')

  clone = (el, deep) ->
    el.cloneNode(deep)

  getAttribute = (el, name) -> el.getAttribute(name)

  setAttribute = (el, name, value) -> el.setAttribute(name, value)

  removeAttribute = (el, name) -> el.removeAttribute(name)

  disable = (el) -> setAttribute(el, 'disabled', 'disabled')

  enable = (el) -> removeAttribute(el, 'disabled')

  remove = (el) -> el.parentNode.removeChild(el)

  checked = (el) -> el.checked

  selectedOption = (el) -> el.options[el.selectedIndex]

  setValue = (el, value) -> el.value = value

  getValue = (el) ->
    if el.tagName.toLowerCase() == 'input'
      if el.type.toLowerCase() == 'checkbox'
        return el.checked
      return el.value
    if el.tagName.toLowerCase() == 'textarea'
      return el.value
    if el.tagName.toLowerCase() == 'select'
      return el.options[el.selectedIndex].value
    # Whatever, let's try anyway
    return el.value

  Dom.prototype.extend {
    empty: ->
      @imap(empty)
      return this
    html: (content) ->
      if content?
        @imap (el) -> setHTML(el, content)
        return this
      else
        return @imap (el) -> getHTML(el)
    append: (content) ->
      @imap (el) -> append(el, content)
      return this
    appendTo: (parent) ->
      @imap (el) -> appendTo(el, parent)
      return this
    clone: (deep) ->
      @imap (el) -> clone(el, deep)
      return this
    attr: (name, value) ->
      if value?
        @imap (el) -> setAttribute(el, name, value)
        return this
      else
        return @imap (el) -> getAttribute(el, name)
    removeAttr: (name) ->
      @imap (el) -> removeAttribute(el, name)
      return this
    disable: ->
      @imap(disable)
      return this
    enable: ->
      @imap(enable)
      return this
    remove: ->
      @imap(remove)
      return this
    checked: ->
      return @imap(checked)
    selectedOption: ->
      return Dom(@imap(selectedOption))
    value: (value) ->
      if value?
        @imap (el) -> setValue(el, value)
        return this
      else
        return @imap (el) -> getValue(el)
  }
