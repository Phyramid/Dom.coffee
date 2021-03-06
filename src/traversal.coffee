do ->
  matches = do ->
    ###
    From:
      https://github.com/desandro/matches-selector
      matchesSelector v1.0.3
      MIT license
    ###

    ensureHasParent = (elem) ->
      return if elem.parentNode
      fragment = document.createDocumentFragment()
      fragment.appendChild(elem)

    qsaFallback = (elem, selector) ->
      ensureHasParent(elem)
      elems = elem.parentNode.querySelectorAll(selector)
      for i in [0...elems.length]
        return true if elems[i] == elem
      return false

    matchChild = (elem, selector) ->
      ensureHasParent(elem)
      return match(elem, selector)

    getMatchesMethod = ->
      if Element.prototype.matches
        return 'matches'
      if Element.prototype.matchesSelector
        return 'matchesSelector'
      prefixes = ['webkit', 'moz', 'ms', 'o']
      for i in [0...prefixes.length]
        prefix = prefixes[i]
        method = prefix + 'MatchesSelector'
        if Element.prototype[method]
          return method

    matchesMethod = getMatchesMethod()
    match = (elem, selector) -> elem[matchesMethod](selector)
    matchesSelector = null

    if matchesMethod
      # IE9 supports matchesSelector, but doesn't work on orphaned elems
      # check for that
      div = document.createElement('div')
      supportsOrphans = match(div, 'div')
      matchesSelector = if supportsOrphans then match else matchChild
    else
      matchesSelector = qsaFallback

    return matchesSelector

  parent = (el) -> Dom(el.parentNode)

  thisOrClosestParent = (el, selector) ->
    return Dom(el) if el.nodeType == 1 && matches(el, selector)
    return closestParent(el, selector)

  closestParent = (el, selector) ->
    return if el.nodeType == 9
    el = el.parentNode
    while el && el.nodeType != 9
      return Dom(el) if el.nodeType == 1 && matches(el, selector)
      el = el.parentNode
    return null

  find = (el, selector) ->
    [].slice.call(el.querySelectorAll(selector))

  Dom.prototype.extend {
    matches: (selector) ->
      @imap (el) -> matches(el, selector)
    parent: -> @imap(parent)
    thisOrClosestParent: (selector) ->
      @imap (el) -> thisOrClosestParent(el, selector)
    closestParent: (selector) ->
      @imap (el) -> closestParent(el, selector)
    find: (selector) ->
      elGroups = @map (el) -> find(el, selector)
      els = elGroups.reduce(((acc, group) -> acc.concat(group)), [])
      return Dom(els)
    found: ->
      @els.length > 0
  }
