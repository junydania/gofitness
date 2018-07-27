$(document).on("turbolinks:load", function() {

    
    $('#wallet-pos-button').on('click', function() {
        if($('#wallet_cash_form').is(':visible') == true) {
            $('#wallet_cash_form').hide();
            $('#fund_wallet_pos_form').show();
        } else {
            $('#fund_wallet_pos_form').show();
        }
    });
   

    $('#wallet-cash-button').on('click', function() {
        if($('#fund_wallet_pos_form').is(':visible') == true) {
            $('#fund_wallet_pos_form').hide();
            $('#wallet_cash_form').show();
        } else {
            $('#wallet_cash_form').show();
        }
    });


    $("#wallet-paystack-button").click(function(event) {

        $("#wallet_amount_form").modal('show');
    
    });


    $("#pay_button").click(function(event) {

        $("#wallet_amount_form").modal('hide');
        var reg = new RegExp(/^\d+$/);
        var amount;
        input_received = $("#wallet_amount").val();
        if (reg.test(input_received) == true) {
            amount = parseInt(input_received * 100);
        }
        else {
            alert("Ensure amount doesn\'t have a comma or alphabet");
        }
        fundWithPaystack(amount);
        $("#form_reset")[0].reset();
    });

    function fundWithPaystack(amount){

        var handler = PaystackPop.setup({
            key: gon.publicKey,
            email: gon.email,
            amount: amount,
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
                // show loading gif
                $('.loader').modal('show');
                var member_id = $("#wallet-paystack-button").val();
                var data = { reference_code: response.reference,
                            id: member_id };
                $.ajax({
                    url: '/paystack_wallet_fund',
                    type: 'POST',
                    data: data,
                    success: function(data, textStatus, xhr) {
                        $('.loader').modal('hide');
                        if ( data.message == "success" ) {
                                    content = `<div class="card-body">
                                                    <p >Wallet Funding Successful!</p>
                                                </div>`;
                                    $('#paystack_wallet_status').append(content);
                                    $('.remove-back-button').remove();
                                    $("#access_profile").fadeIn('fast');                                
                        } else {
                            content = `<p>Card Payment wasn't successful! Verify payment on Paystack Dashboard</p>`;
                            $('#paystack_wallet_status').append(content);
                        }
                    },

                    error: function() {
                                $('.loader').modal('hide');
                                content = `<div class="card-body">
                                                <p>Wallet Funding was unsuccessful!</p>
                                            </div>`;
                                $('#paystack_wallet_status').append(content);
                            }
                });
            },
            onClose: function(){
                alert('Payment Window Closed');
            }
        });
        handler.openIframe();
    }
});
