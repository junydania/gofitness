//Fucntion to display the group members select field
$(document).on("turbolinks:load", function() {
    $("#group_plan_select").change(function() {
        if($("#group_plan_select").val() == "true") {
            $(".group_member_hide").fadeIn('fast');
        }else {
            $(".group_member_hide").fadeOut('fast'); 
        }
    })
 });


