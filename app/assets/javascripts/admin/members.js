 
//Code to display subscription plan with selectize
$(document).on("turbolinks:load", function() {
    $(".subscription-selectize").selectize({
        sortField: 'text'
    });

    $('#renew-cash-button').on('click', function() {
        if($('#renew-pos-box').is(':visible') == true) {
            $('#renew-pos-box').hide();
            $('#renew-cash-box').show();
        }
        else{
            $('#renew-cash-box').show();
        }
    });
    
    $('#renew-pos-button').on('click', function() {
        if($('#renew-cash-box').is(':visible') == true) {
            $('#renew-cash-box').hide();
            $('#renew-pos-box').show();
        } else {
            $('#renew-pos-box').show();
        }
    });
 });


$(document).on("turbolinks:load", function() {

    // SendInvoice
    $("#sendInvoice").click(function(event) {

        $('.loader').modal('show');

        var click_value = $("#sendInvoice").val();

        var data = { id: click_value };
        $.ajax({
            url: '/send_paystack_invoice',
            type: 'POST',
            data: data,
            success: function(data, xhr) {

                $('.loader').modal('hide');
                
                if ( data.message == "success" ) {
                    content = `<p>Invoice has been mailed to customer!</p>`;
                    $('#pause-message').append(content);

                } else if(data.message == "failed" ) {
                    content = `<p>Sorry, Tried sending invoice but failed. Retry!</p>`;
                    $('#pause-message').append(content);

                }  
            },
            error: function() {
                $('.loader').modal('hide');
                content = `<p>Error processing Invoice! </p>`;
                $('#pause-message').append(content);
            }
        });
    });

    // Check if subscription plan is recurring
    $("#member_subscription_plan_id").change(function() {
        sub_plan = $("#member_subscription_plan_id").val();
        $('.loader').modal('show');
        $.ajax({
            url: '/admin/check_recurring',
            type: 'POST',
            data: { plan: sub_plan},
            success: function(data, textStatus, xhr) {
                            $('.loader').modal('hide');
                            if ( data.message == "non-recurring" ) {
                                $('.payment_method_field').fadeIn('slow');

                            } else {
                                $('.payment_method_field').hide();
                            }
                        },
            error: function() {
                         alert('You failed to select a plan');
                    }
        });

    });
    
    
    
    $("#renew-wallet-button").click(function(event){ 

        $('.loader').modal('show');
        member = $("#renew-wallet-button").val();
        $.ajax({
            url: '/wallet_renewal',
            type: 'POST',
            data: { id: member},
            success: function(data, textStatus, xhr) {

                            $('.loader').modal('hide');
                            
                            content = `<div class="card-body">
                                            <button class="tst2 btn btn-info">Renewal Successful!</button>
                                    </div>`;
                            $('#paystack-renew-success').append(content);
                            $('.remove-back-button').remove();
                            $('#paystack-renew-button, #renew-cash-button, #renew-pos-button').remove();
                            $("#complete-renewal").fadeIn('fast');
                        },
            error: function() {
                        content = `<div class="card-body">
                                        <p>Recurring subscription wasn't successfully activated.</p>
                                        <p>Enter this reference code in the field below: ${response.reference} </p>
                                    </div>`
                        $("#reference-code").append(content);
                        $("#reference-code").fadeIn('fast');
                        $("#manual-subscribe").fadeIn('fast');                            
                    }
        });
    });

   
    $("#paystack-renew-button").click(function(event) {

        if(($('#renew-cash-box').is(':visible') == true) || ($('#renew-pos-box').is(':visible') == true)) {
            $('#renew-cash-box').hide();
            $('#renew-pos-box').hide();
            payWithPaystack();

        }else {

            payWithPaystack();
        }
    });

    function payWithPaystack(){
        
        var handler = PaystackPop.setup({
            key: gon.publicKey,
            email: gon.email,
            amount: gon.amount,
            // ref: ''+Math.floor((Math.random() * 1000000000) + 1), // generates a pseudo-unique reference. Please replace with a reference you generated. Or remove the line entirely so our API will generate one for you
            firstname: gon.firstName,
            lastname: gon.lastName,
            metadata: {
                custom_fields: [
                    {
                        display_name: "Mobile Number",
                        variable_name: "mobile_number",
                        value: gon.value
                    }
                ]
        },
        callback: function(response){
            var data = { reference_code: response.reference, id: parseInt(gon.member_id) };
            console.log (gon.member_id);
            $.ajax({
                url: '/paystack_renewal',
                type: 'POST',
                data: data,
                success: function(data, textStatus, xhr) {
                             content = `<div class="card-body">
                                             <button class="tst2 btn btn-info">Renewal Successful!</button>
                                        </div>`;
                             $('#paystack-renew-success').append(content);
                             $('.remove-back-button').remove();
                             $('#paystack-renew-button, #renew-cash-button, #renew-pos-button').remove();
                             $("#complete-renewal").fadeIn('fast');
                         },
                error: function() {
                            content = `<div class="card-body">
                                            <p>Recurring subscription wasn't successfully activated.</p>
                                            <p>Enter this reference code in the field below: ${response.reference} </p>
                                       </div>`
                            $("#reference-code").append(content);
                            $("#reference-code").fadeIn('fast');
                            $("#manual-subscribe").fadeIn('fast');                            
                      }
            });
        },
        onClose: function(){
            alert('Payment Window Closed');
        }
        });

        handler.openIframe();
    }

    $("#pause-subscriber").click(function(event) {

        $('.loader').modal('show');

        var click_value = $("#pause-subscriber").val();

        var data = { id: click_value };
        $.ajax({
            url: '/pause_subscription',
            type: 'POST',
            data: data,
            success: function(data, xhr) {

                $('.loader').modal('hide');
                
                if ( data.message == "success" ) {
                            $('#pause-subscriber').removeClass('btn-warning').addClass('btn-danger').text("Membership Paused");
                            window.location.reload(true);
                        
                } else if(data.message == "no subscription" ) {
                    content = `<p>Customer doesn't have an active recurring subscription & can't be paused!</p>`;
                    $('#pause-message').append(content);

                }  else if(data.message == "pause exceeded" ) {
                    content = `<p>Customer has exceeded permitted pause count.Subscription can't be paused!</p>`;
                    $('#pause-message').append(content);
                }

            },
            error: function() {
                $('.loader').modal('hide');
                content = `<p>Error pausing subscription! </p>`;
                $('#pause-message').append(content);
            }
        });
    });

    $("#cancel-pause").click(function(event) {

        var id = $("#cancel-pause").val();

        $('.loader').modal('show');

        var data = { id: id };
        $.ajax({
            url: '/cancel_pause',
            type: 'POST',
            data: data,
            success: function(data, xhr) {
                $('.loader').modal('hide');
                if ( data.message == "success" ) {
                    // $('#pause-subscriber').removeClass('btn-warning').addClass('btn-danger').text("Membership Paused");
                    content = `<button class="tst2 btn btn-info">Pause Cancellation was Successful!</button>`;
                    $('#cancel-message').append(content);
                    window.location.reload(true);
                
                }  else {
                    content = `<p>Pause Cancellation wasn't succesfull!</p>`;
                    $('#cancel-message').append(content);
                    window.location.reload(true);

                }
            },
            error: function() {
                $('.loader').modal('hide');
                content = `<p>Error pausing subscription! </p>`;
                $('#pause-message').append(content);
            }
        });
    });
});

function image_snapshot(){
    Webcam.snap(function(data_uri) {

        $('.loader').modal('show');

        id = $('[id*="_image"]');

        if (id.length) {
            id.val(data_uri);
        }
        data = { image: data_uri}   
        $.ajax({
            url: '/members/upload_image',
            type: 'POST',
            data: data,
            success: function(data, textStatus, xhr) {
                         $('.loader').modal('hide');
                         content = `<div class="card-body">
                                         <button class="tst2 btn btn-success">${data.message}</button>
                                    </div>`
                         $('#member_upload_status').append(content)
                         $("#complete_upload").fadeIn('fast')
                     },
            error: function(data) {
                $('.loader').modal('hide');
                content = `<div class="card-body">
                                    <button class="tst2 btn btn-danger">${data.message}</button>
                            </div>`
                $('#member_upload_status').append(content)

            }
        })

        document.getElementById('image_result').innerHTML = '<img src="' + data_uri + '"/>';
    });
}


$(document).ready(function() {
    if ($("#member_edit_camera").length) {
        Webcam.set({
            width: 320,
            height: 240,
            image_format: 'jpeg',
            jpeg_quality: 90
        });
        Webcam.attach('#member_edit_camera');
    }
});