$(document).ready(function() {
  $('#clear').click(function(event) {
    event.preventDefault()
    $.ajax('/', {
      type: 'DELETE',
      success: function() {
        $('#flash').html("You can refresh now, but the messages won't clear for 5 seconds.");
        setTimeout(function() {
          document.location = '/';
        }, 5000);
      }
    });
  });
});
