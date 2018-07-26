$(document).on("turbolinks:load", function() {

    $("#wallet-paystack-button").click(function(event) {

        fundWithPaystack();
    });

    function fundWithPaystack(){
        
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
                                content = `<div class="card-body">
                                                <button class="tst2 btn btn-warning">Payment & Subscription Successful! Continue</button>
                                            </div>`;
                                $('#paystack-success').append(content);
                                $('.remove-back-button').remove();
                                $('#receive-payment').remove();
                                $('#paystack-button').remove();
                                $("#payment-next").fadeIn('fast');
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
});