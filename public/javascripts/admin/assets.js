var Asset = {};

Asset.Attach = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    var url = this.element.href;
    new Ajax.Request(url, {
      asynchronous: true, 
      evalScripts: true, 
      method: 'get',
      onSuccess: function(transport) { 
        Asset.AddToList(transport.responseText);
        $('attach_asset').closePopup();
      }
    });
  }
});

Asset.Detach = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    Asset.RemoveFromList(this.element.up('li.asset'));
  }
});

Asset.Upload = Behavior.create({
  onload: function (e) {
    if (e) e.stop();
    var html = this.element.contentDocument.body.innerHTML;
    if (html && html != "") { // the iframe is empty on initial page load
      Asset.AddToList(html);
      $('upload_asset').closePopup();
      this.element.empty();
    }
  }
});

Asset.AddToList = function (html) {
  var new_id  = new Date().getTime();
  $('attachment_fields').insert(html.replace(/new_attachment/g, new_id));
  if ($('attachment_list').hasClassName('empty')) {
    $('attachment_list').removeClassName('empty');
    $('attachment_list').slideDown();
  }
  Asset.Notify('Save page to commit changes');
}

Asset.RemoveFromList = function (container) {
  var el = null;
  if (!!(el = $('attachment_list').down('input.attacher'))) el.remove();
  if (!!(el = $('attachment_list').down('input.destroyer'))) el.value = 1;
  container.dropOut();
  Asset.Notify('Save page to commit changes');
}

Asset.Notify = function (message) {
  // $('attachment_list').down('span.note').update(message);
}

// Asset-filter and search functions are available wherever the asset_table partial is displayed

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

Asset.CopyButton = Behavior.create({
  initialize: function(){
    var clip = new ZeroClipboard.Client();
    var asset_id = this.element.id.replace('copy_', '');
    clip.setText('<r:assets:image size="" id="' + asset_id + '" />');
    clip.setHandCursor( true );
    
    // this doesn't position the clip correctly if the buttons aren't visible at the time
    clip.glue(this.element);
    
    clip.addEventListener( 'onComplete', function (client, text) {
      var element = client.domElement;
      var contents = element.innerHTML;
      element.update(contents.replace('Copy', 'Copied'));
      element.update().delay(2000, contents);
    });
  },
  onClick: function (e) {
    e.stop();
  }
});

Event.addBehavior({
  'iframe#ulframe': Asset.Upload,
  'a.attach_asset': Asset.Attach,
  'a.unattach_asset': Asset.Detach,
  'a.detach_asset': Asset.Detach,
  'form.upload_asset': Asset.Uploader,
  'a.deselective': Asset.NoFileTypes,
  'a.selective': Asset.FileTypes,
  'a.copy': Asset.CopyButton
});
