var Asset = {};

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

Asset.AttachButton = Behavior.create({
  initialize: function(){
    console.log('attacher:', this.element);
  },
  onClick: function (e) {
    e.stop();
    var url = this.element.href;
    new Ajax.Updater('attachments', url, {
      asynchronous : true, 
      evalScripts  : true, 
      method       : 'post'
    });
  }
});

Asset.CopyButton = Behavior.create({
  initialize: function(){
    console.log('copier:', this.element);
  },
  initialize: function(){
    var clip = new ZeroClipboard.Client();
    var asset_id = this.element.id.replace('copy_', '');
    clip.setText('<r:assets:image size="" id="' + asset_id + '" />');
    clip.setHandCursor( true );
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
  '#filesearchform a.deselective': Asset.NoFileTypes,
  '#filesearchform a.selective': Asset.FileTypes,
  'a.copy': Asset.CopyButton,
  'a.attach': Asset.AttachButton
});
