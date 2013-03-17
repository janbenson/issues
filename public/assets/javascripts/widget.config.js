var isNumeric = function(input) {
   return (input - 0) == input && input.length > 0;
};

var getEmbed = function(widget) {
  return '<script src="http://opencongress.org/assets/widget.js" type="text/javascript"></scr' + 'ipt>\n' +
'<script>\n' +
'new OC.Widget(' + JSON.stringify(widget.getOptionsForSnippet(), null, '\t') + ').render();\n' +
'</scr' + 'ipt>\n';
};

var refreshEmbed = function(widget) {
  $('#embed-code').val(getEmbed(widget));
};

var refreshTheme = function(widget) {
  widget.setTheme({
    background: '#' + $('#widgetBG').val(),
    color: '#' + $('#widgetColor').val(),
    header: '#' + $('#widgetHeader').val(),
    links: '#' + $('#widgetLinks').val()
  }).setWidth($('#widgetWidth').val());

  // Set additional parameters relevant to specific widgets
  if (widget.type == 'bill_status') {
    widget.setBill($('#widgetData').data('bill'));
  } else if (widget.type == 'group') {
    widget.setGroup($('#widgetData').data('group'));
  }

  widget.reformat();

  refreshEmbed(widget);
}

$(function() {
  jscolor.init();

  // Fill in the basic embed code.
  refreshEmbed(testWidget);

  $('#widgetWidth').change(function() {
    if (isNumeric($(this).val())) {
      refreshTheme(testWidget);
    } else {
      alert("Width must be a number");
      return false;
    }
  });

  // Refresh the theme when colors are chosen
  $('.widgetVar').change(function() {
    refreshTheme(testWidget);
  });

  // Refresh the theme with this trigger is called
  $('#widgetData').bind('refresh', function() {
    refreshTheme(testWidget);
  });

  // Select all text when clicking on embed code box
  $('#embed-code').click(function() {
    this.select();
  });

  $('#embed-code').select(function() {
    this.select();
  });

});
