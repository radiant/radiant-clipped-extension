var Asset = {};

Asset.Uploader = Behavior.create({
  onsubmit: function (e) {
    if (e) e.stop();
    var form = this.element;
    var filefield = form.down('input.file');
    
    // remove file field
    // get to new asset
    // place results in attachment bar
    // add file field
    // post form again
    
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

Asset.GenerateUUID = function () {
  // http://www.ietf.org/rfc/rfc4122.txt
  var s = [];
  var hexDigits = "0123456789ABCDEF";
  for (var i = 0; i < 32; i++) { s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1); }
  s[12] = "4";                                       // bits 12-15 of the time_hi_and_version field to 0010
  s[16] = hexDigits.substr((s[16] & 0x3) | 0x8, 1);  // bits 6-7 of the clock_seq_hi_and_reserved to 01
  return s.join('');
};

Asset.AddToList = function (html) {
  var list = $('attachment_fields');
  list.insert(html);
  if (list.hasClassName('empty')) {
    list.removeClassName('empty');
    list.slideDown();
  }
  Asset.Notify('Save page to commit changes');
}

Asset.RemoveFromList = function (container) {
  var el = null;
  if (!!(el = container.down('input.attacher'))) el.remove();
  if (!!(el = container.down('input.destroyer'))) el.value = 1;
  container.dropOut({afterFinish: Asset.HideListIfEmpty});
  container.addClassName('detached');
}

Asset.AddUploaderToList = function (argument) {
  
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
  'a.select_asset': Asset.Select,
  'a.attach_asset': Asset.Attach,
  'a.detach_asset': Asset.Detach,
  'form.attach_assets': Asset.Attacher,
  'form.upload_asset': Asset.Uploader,
  'a.deselective': Asset.NoFileTypes,
  'a.selective': Asset.FileTypes,
  'a.copy': Asset.CopyButton
});
