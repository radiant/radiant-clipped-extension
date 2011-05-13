var Asset = {};

Asset.Attacher = Behavior.create({
  onsubmit: function (e) {
    if (e) e.stop();
    var form = this.element;
    form.down('input.commit').disable();
    form.down('.busy').show();
    new Ajax.Request(form.action, {
      asynchronous: true, 
      evalScripts: true, 
      method: 'get',
      parameters: form.serialize(),
      onSuccess: function(transport) { 
        Asset.AddToList(transport.responseText);
        $('attach_asset').closePopup();
        Asset.ResetAttachmentForm();
        form.down('.busy').hide();
        form.down('.commit').enable();
      }
    });
  }
});

Asset.Select = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    var container = this.element.up('li.asset');
    container.toggleClassName('selected');
    container.down('input.selector').checked = container.hasClassName('selected');
  }
});

Asset.Detach = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    Asset.RemoveFromList(this.element.up('li.asset'));
    Asset.ResetAttachmentForm();
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
  var list = $('attachment_fields');
  var new_id  = new Date().getTime();
  list.insert(html.replace(/new_attachment/g, new_id));
  if (list.hasClassName('empty')) {
    list.removeClassName('empty');
    list.slideDown();
  }
  Asset.Notify('Save page to commit changes');
  Asset.UpdateSearchFilter();
}

Asset.RemoveFromList = function (container) {
  var el = null;
  if (!!(el = container.down('input.attacher'))) el.remove();
  if (!!(el = container.down('input.destroyer'))) el.value = 1;
  container.dropOut({afterFinish: Asset.HideListIfEmpty});
  container.addClassName('detached');
  Asset.UpdateSearchFilter();
}

Asset.Notify = function (message) {
  $('attachment_list').down('span.message').update(message).addClassName('important');
}

Asset.HideListIfEmpty = function () {
  var list = $('attachment_fields');
  if (!list.down('li.asset:not(.detached)')) {
    list.addClassName('empty');
    list.slideUp();
    Asset.Notify('All assets detached. Save page to commit changes');
  } else {
    Asset.Notify('Assets detached. Save page to commit changes');
  }
}

Asset.ResetAttachmentForm = function () {
  var search_form = $('filesearchform');
  new Ajax.Updater('assets_table', search_form.action, {
    asynchronous: true, 
    evalScripts:  true, 
    parameters:   Form.serialize(search_form),
    method: 'get',
    onComplete: 'assets_table'
  });
}

Asset.UpdateSearchFilter = function () {
  var ids = [];
  $$('#attachment_fields > li.asset:not(.detached)').each(function (element) {
    ids.push(element.id.split('_').last());
  });
  $('omit_asset_ids').value = ids.join(',');
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
  'a.select_asset': Asset.Select,
  'a.attach_asset': Asset.Attach,
  'a.detach_asset': Asset.Detach,
  'form.attach_assets': Asset.Attacher,
  'form.upload_assets': Asset.Uploader,
  'a.deselective': Asset.NoFileTypes,
  'a.selective': Asset.FileTypes,
  'a.copy': Asset.CopyButton
});
