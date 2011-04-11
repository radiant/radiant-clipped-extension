var Asset = {};

Asset.AddNewAttachment = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    var url = this.element.href;
    new Ajax.Request(url, {
      asynchronous: true, 
      evalScripts: true, 
      method: 'get',
      onSuccess: function(response) {
        // append response html to #attachments
        var new_id  = new Date().getTime();
        $('attachment_fields').insert(response.responseText.replace(/new_attachment/g, new_id));
        $('attachments').down('span.note').update('save page to commit changes');
      }
    });
  }
});

Asset.RemoveNewAttachment = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    var container = this.element.up('li');
    container.down('input').remove();
    container.dropOut();
  }
});

Asset.DetachAttachment = Behavior.create({
  onclick: function (e) {
    if (e) e.stop();
    var container = this.element.up('li');
    container.down('input.destroyer').value = 1;
    container.dropOut();
    $('attachments').down('span.note').update('Save page to commit changes');
  }
});

Asset.CatchUpload = Behavior.create({
  onload: function (e) {
    if (e) e.stop();
    var html = this.element.contentDocument.body.innerHTML;
    if (html && html != "") {
      var new_id  = new Date().getTime();
      $('attachment_fields').insert(html.replace(/new_attachment/g, new_id));
      $('upload-asset').closePopup();
      this.element.empty();
    }
  }
});





// alternatively, you can create an attachment immediately. The whole attachments list is refreshed.

Asset.Attacher = Behavior.create({
  onclick: function (e) {
    console.log("attach!");
    if (e) e.stop();
    var attachment_form = this.element.parentNode;
    console.log("attaching!", attachment_form.action);
    new Ajax.Updater('attachments', attachment_form.action, {
      asynchronous: true, 
      evalScripts: true, 
      parameters: Form.serialize(attachment_form),
      method: 'post'
    });
  }
});

Asset.Detacher = Behavior.create({
  onclick: function (e) {
    e.stop();
    var url = this.element.href;
    new Ajax.Updater('attachments', url, {
      asynchronous : true, 
      evalScripts : true, 
      method: 'post'
    });
  }
});


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
  'iframe#ulframe': Asset.CatchUpload,
  'a.attach_asset': Asset.AddNewAttachment,
  'a.unattach_asset': Asset.RemoveNewAttachment,
  'a.detach_asset': Asset.DetachAttachment,
  'form.upload_asset': Asset.Uploader,
  'a.deselective': Asset.NoFileTypes,
  'a.selective': Asset.FileTypes,
  'a.copy': Asset.CopyButton
});
