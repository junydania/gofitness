 
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
            var data = {reference_code: response.reference};
            $.ajax({
                url: '/paystack_renewal',
                type: 'POST',
                data: data,
                success: function(data, textStatus, xhr) {
                             content = `<div class="card-body">
                                             <button class="tst2 btn btn-warning">Renewal Successful! Continue</button>
                                        </div>`;
                             $('#paystack-renew-success').append(content);
                             $('.remove-back-button').remove();
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
        
 });
