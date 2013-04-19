$(function() {
  $("a[href*='/game/attending_status']").click(function(e) {
    e.preventDefault();
    function updateDiv(data) {
      $("#status_" + e.target.id).html(data);
    }
    console.log(e)
    $.get(e.target.href, { game_id: e.target.id }, updateDiv)
  });

  $( ".join_team" ).click(function(e) {
    e.preventDefault();
    var team_id = e.target.id
    $.get('/team/join', { team_id: team_id }, function(data) { $("#" + team_id).html(data) });
  });
});

$(document).ready(function() {
  $("#add_game_form").submit( function() {
    date = Date.parse($("#game_date_string").val())
    $("#massaged_date").text(date.toString("MM/DD/YYYY h:mm tt"))
  });
});

$('.datepicker').datepicker();

