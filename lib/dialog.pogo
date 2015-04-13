require './style'
container   = require './container'

dialog count = 0

onAnimationEnd(el, func)=
  register(eventName)=
    handler()=
      el.removeEventListener(eventName, func, false)
      func.apply(this, arguments)

    el.addEventListener(eventName, func, false)

  register 'animationend'
  register 'webkitAnimationEnd'
  register 'MSAnimationEnd'
  register 'oanimationend'

remove classes(el, classes)=
  for each @(className) in (classes)
    el.classList.remove(className)

overlay = '<div class="sidler-overlay"></div>'

module.exports.init(position = 'top', selector = nil, html = nil, modal = true, edge = true, onclosed() = nil) =
  ++dialog count

  modalDialog = nil

  makeModal()=
    overlay = document.createElement 'div'
    overlay.className = 'sidler-overlay'
    document.body.insertBefore(overlay, document.body.firstChild)
    closeModal(e)=
      parentElement = e.target
      clickedWithinDialog = false
      while (parentElement != null)
        if (parentElement == dialog.el)
          clickedWithinDialog := true
          parentElement := null
        else
          parentElement := parentElement.parentElement

      if (!clickedWithinDialog)
        dialog.hide()
        onclosed()

    overlay.addEventListener('click', closeModal, false)
    
    modalDialog := {
      remove()=
        document.body.removeChild(overlay)
        overlay.removeEventListener('click', closeModal, false)
        modalDialog := nil 
    } 

  dialog = {
    id = "sidler-dialog-#(dialog count)"
    show()=

      onAnimationEnd(self.el)
        remove classes(self.el, ['sidler-hide', 'sidler-hiding', 'sidler-showing'])
        self.el.classList.add('sidler-show')

      if (modal)
        makeModal()

      self.el.classList.add('sidler-showing')

    hide()=
      onAnimationEnd(self.el)
        remove classes(self.el, ['sidler-show', 'sidler-showing', 'sidler-hiding'])
        self.el.classList.add('sidler-hide')


      self.el.classList.add('sidler-hiding')
      if (modalDialog)
        modalDialog.remove()

    toggle()=
      showing = self.el.classList.contains('sidler-show')
      if (showing)
        self.hide()
      else
        self.show()
  }

  dialogs = container.get()
  if (selector)
    dialog.el = document.querySelector(selector)
    if (dialog.el.id)
      dialog.id = dialog.el.id
  else
    dialog.el = document.createElement 'div'
    dialog.el.id = dialog.id
    dialogs.appendChild(dialog.el)


  dialog.el.classList.add('sidler-dialog')
  dialog.el.classList.add('sidler-' + position)

  if (edge)
    dialog.el.classList.add('sidler-edge')
  else
    dialog.el.classList.add('sidler-flex')

  if (modal)
    dialog.el.classList.add('sidler-modal')

  if (html)
    dialog.el.innerHTML = html

  dialog

show(options)=
  dialog = module.exports.init(options)
  dialog.show()
  dialog

module.exports.top(options)=
  options.position = 'top'
  show(options)

module.exports.right(options)=
  options.position = 'right'
  show(options)

module.exports.bottom(options)=
  options.position = 'bottom'
  show(options)

module.exports.left(options)=
  options.position = 'left'
  show(options)
