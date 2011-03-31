document.observe("dom:loaded", function() {
  if($('page-attachments')){
    Asset.ChooseTabByName('page-attachments');
  }
  
});

var Asset = {};

Asset.Tabs = Behavior.create({
  onclick: function(e){
    e.stop();
    Asset.ChooseTab(this.element);
  }
});

// factored out so that it can be called in an ajax response

Asset.ChooseTab = function (element) {
  var pane = $(element.href.split('#')[1]);
  var panes = $('assets').select('.pane');
  
  var tabs = $('asset-tabs').select('.asset-tab');
  tabs.each(function(tab) {tab.removeClassName('here');});
  
  element.addClassName('here');;
  panes.each(function(pane) {Element.hide(pane);});
  Element.show($(pane));
}

Asset.ChooseTabByName = function (tabname) {
  var element = $('tab_' + tabname);
  Asset.ChooseTab(element);
}

// factored out so that it can be called after new page part creation

Asset.MakeDraggables = function () { 
  $$('div.asset').each(function(element){
    new Draggable(element, { revert: true });
    element.addClassName('move');
  });
}

Asset.DisableLinks = Behavior.create({
  onclick: function(e){
    e.stop();
  }
});

Asset.AddToPage = Behavior.create({
  onclick: function(e){
    e.stop();
    url = this.element.href;
    new Ajax.Updater('attachments', url, {
      asynchronous : true, 
      evalScripts  : true, 
      method       : 'get'
      // onComplete   : Element.highlight('page-attachments')
    });
    
  }
});

Asset.MakeDroppables = function () {
  $$('.textarea').each(function(box){
    if (!box.hasClassName('droppable')) {
      Droppables.add(box, {
        accept: 'asset',
        onDrop: function(element) {
          var asset_id = element.id.split('_').last();
          var classes = element.className.split(' ');
          var tag_type = classes[0];
          var tag = '<r:assets:' + tag_type + ' id="' + asset_id + '" size="original" />';
          //Form.Element.focus(box);
          if(!!document.selection){
            box.focus();
            var range = (box.range) ? box.range : document.selection.createRange();
            range.text = tag;
            range.select();
          }else if(!!box.setSelectionRange){
            var selection_start = box.selectionStart;
            box.value = box.value.substring(0,selection_start) + tag + box.value.substring(box.selectionEnd);
            box.setSelectionRange(selection_start + tag.length,selection_start + tag.length);
          }
          box.focus();
        }
      });      
      box.addClassName('droppable');
    }
  });
}

Asset.NoFileTypes = Behavior.create({
  onclick: function(e){
    e.stop();
    var element = this.element;
    var search_form = $('filesearchform');
    if(!element.hasClassName('pressed')) {
      $$('a.selective').each(function(el) { el.removeClassName('pressed'); });
      $$('input.selective').each(function(el) { el.removeAttribute('checked'); });
      element.addClassName('pressed');
      new Ajax.Updater('assets_table', search_form.action, {
        asynchronous: true, 
        evalScripts:  true, 
        parameters:   Form.serialize(search_form),
        method: 'get',
        onComplete: 'assets_table'
      });
    }
  }
});

Asset.FileTypes = Behavior.create({
  onclick: function(e){
    e.stop();
    var element = this.element;
    var type_id = element.readAttribute("rel");
    var type_check = $(type_id + '-check');
    var search_form = $('filesearchform');
    if(element.hasClassName('pressed')) {
      element.removeClassName('pressed');
      type_check.removeAttribute('checked');
      if ($$('a.selective.pressed').length == 0) $('select_all').addClassName('pressed');
    } else {
      element.addClassName('pressed');
      $$('a.deselective').each(function(el) { el.removeClassName('pressed'); });
      type_check.setAttribute('checked', 'checked');
    }
    new Ajax.Updater('assets_table', search_form.action, {
      asynchronous: true, 
      evalScripts:  true, 
      parameters:   Form.serialize(search_form),
      method: 'get',
      onComplete: 'assets_table'
    });
  }
});

Asset.WaitingForm = Behavior.create({
  onsubmit: function(e){
    this.element.addClassName('waiting');
    return true;
  }
});

Asset.CopyButton = Behavior.create({
  initialize: function(){
    var clip = new ZeroClipboard.Client();
    var asset_id = this.element.id.replace('copy_', '');
    clip.setText('<r:assets:image size="" id="' + asset_id + '" />');
    clip.setHandCursor( true );
    clip.glue(this.element);
    clip.addEventListener( 'onComplete', Asset.ConfirmCopy );
  },
  onClick: function (e) {
    e.stop();
  }
});

Asset.ConfirmCopy = function (client, text) {
  var element = client.domElement;
  element.update(element.innerHTML.replace('Copy', 'Copied'));
  element.addClassName('confirmed');
  window.setTimeout(function() { Asset.ResetConfirmation(element); }, 2000);
}

Asset.ResetConfirmation = function (element) {
  element.update(element.innerHTML.replace('Copied', 'Copy'));
  element.removeClassName('confirmed');
}

Asset.ResetForm = function (name) {
  var element = $('asset-upload');
  element.removeClassName('waiting');
  element.reset();
  Asset.MakeDroppables();
}

Asset.AddAsset = function (name) {
  element = $(name); 
  asset = element.select('.asset')[0];
  if (asset) {
    new Draggable(asset, { revert: true });
  }
}

Event.addBehavior({
  '#filesearchform a.deselective' : Asset.NoFileTypes,
  '#filesearchform a.selective ' : Asset.FileTypes,
  // '#asset-upload'     : Asset.WaitingForm,
  // 'a.add_asset'       : Asset.AddToPage,
  'a.copy'            : Asset.CopyButton
});
