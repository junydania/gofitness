$(document).on("turbolinks:load", function() {
    
    // Check if subscription plan is recurring
    $("#member_change_plan").change(function() {
        sub_plan = $("#member_change_plan").val();
        $('.loader').modal('show');
        $.ajax({
            url: '/admin/check_recurring',
            type: 'POST',
            data: { plan: sub_plan},
            success: function(data, textStatus, xhr) {
                            $('.loader').modal('hide');
                            if ( data.message == "non-recurring" ) {
                                $('.change_plan_method').fadeIn('slow');

                            } else {
                                $('.change_plan_method').hide();
                            }
                        },
            error: function() {
                         alert('You failed to select a plan');
                         $('.loader').modal('hide');
                    }
        });

    });

});
