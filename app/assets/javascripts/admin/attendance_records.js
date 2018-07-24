$(document).on("turbolinks:load", function() {
   
    $("#check_in_button").click(function(event) {

        var click_value = $("#check_in_button").val();
        var data = { id: click_value };
        var button_content = $("#check_in_button").text();

        if (button_content == 'Check In') {

            $.ajax({
                url: '/admin/member_check_in',
                type: 'POST',
                data: data,
                success: function(data, xhr) {
    
                    if ( data.message == "success" ) {
                                $('#check_in_button').removeClass('btn-info').addClass('btn-danger').text("Checked In");
                            
                    } else if(data.message == "failed" ) {
                        content = `<p>Can't Check in an Inactive Customer</p>`;
                        $('#check_in_message').append(content);
    
                    }  else if(data.message == "checkedin" ) {
                        content = `<p>Can't Check in an Inactive Customer</p>`;
                        $('#check_in_button').removeClass('btn-info').addClass('btn-danger').text("Already Checked In");
                    }
                },
                error: function() {
                    $('.loader').modal('hide');
                    content = 'Failed to Check In';
                    alert(content);
                } 
            });
        } else {
            content = 'User already checked in! Check Out Instead';
            alert(content);
        }
    });
});