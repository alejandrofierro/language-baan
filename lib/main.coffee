SymbolsTreeView = require './symbols-tree-view'
console.log("main.coffe")
module.exports =
  config:
    autoToggle:
      type: 'boolean'
      default: true
      description: 'If this option is enabled then symbols-tree-view will auto open when you open files.'
    scrollAnimation:
      type: 'boolean'
      default: true
      description: 'If this option is enabled then when you click the item in symbols-tree it will scroll to the destination gradually.'
    autoHide:
      type: 'boolean'
      default: true
      description: 'If this option is enabled then symbols-tree-view is always hidden unless mouse hover over it.'
    zAutoHideTypes:
      title: 'AutoHideTypes'
      type: 'string'
      description: 'Here you can specify a list of types that will be hidden by default (ex: "variable class")'
      default: ''
    sortByNameScopes:
      type: 'string'
      description: 'Here you can specify a list of scopes that will be sorted by name (ex: "text.html.php")'
      default: ''
    defaultWidth:
      type: 'number'
      description: 'Width of the panel (needs Atom restart)'
      default: 300


  symbolsTreeView: null

  activate: (state) ->
    @symbolsTreeView = new SymbolsTreeView(state.symbolsTreeViewState)
    atom.commands.add 'atom-workspace', 'language-baan:toggle': => @symbolsTreeView.toggle()
    atom.commands.add 'atom-workspace', 'language-baan:show': => @symbolsTreeView.showView()
    atom.commands.add 'atom-workspace', 'language-baan:hide': => @symbolsTreeView.hideView()

    atom.config.observe 'tree-view.showOnRightSide', (value) =>
      if @symbolsTreeView.hasParent()
        @symbolsTreeView.remove()
        @symbolsTreeView.populate()
        @symbolsTreeView.attach()

    atom.config.observe "language-baan.autoToggle", (enabled) =>
      if enabled
        @symbolsTreeView.toggle() unless @symbolsTreeView.hasParent()
      else
        @symbolsTreeView.toggle() if @symbolsTreeView.hasParent()

  deactivate: ->
    @symbolsTreeView.destroy()

  serialize: ->
    symbolsTreeViewState: @symbolsTreeView.serialize()

  getProvider: ->
    view = @symbolsTreeView

    providerName: 'language-baan'
    getSuggestionForWord: (textEditor, text, range) =>
      range: range
      callback: ()=>
        view.focusClickedTag.bind(view)(textEditor, text)
