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


 //Code to display selectize field
$(document).on("turbolinks:load", function() {

    var selectizeCallback = null;

    $(".feature-modal").on("hide.bs.modal", function(e){
        if(selectizeCallback != null) {
            selectizeCallback();
            selectizeCallback = null;
        }
        $("#new_feature_form").trigger("reset");
        $.rails.enableFormElements($("#new_feature_form"));
    });

    $('#new_feature_form').on('submit', function(e) {
        e.preventDefault();
        $.ajax({
            method: "POST",
            url: $(this).attr("action"),
            data: $(this).serialize(),
            success: function(response) {
                selectizeCallback({value: response.id, text: response.name});
                selectizeCallback = null;

                $(".feature-modal").modal('toggle');
            }
        })
    })
    $(".selectize").selectize({
        create: function(input, callback) {
            selectizeCallback = callback
            $(".feature-modal").modal();
            $("#feature_name").val(input);
            
        }
    });
 });



