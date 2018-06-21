$(document).on("turbolinks:load", function() {

    $("#paystack-button").click(function(event) {

        payWithPaystack();
    })

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
            var data = {reference_code: response.reference}
            $.ajax({
                url: '/admin/paystack_subscribe',
                type: 'POST',
                data: data,
                success: function(data, textStatus, xhr) {
                             content = `<div class="card-body">
                                             <button class="tst2 btn btn-warning">Payment & Subscription Successful! Continue</button>
                                        </div>`
                             $('#paystack-success').append(content);
                             $('.remove-back-button').remove();
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
            })
        },
        onClose: function(){
            alert('Payment Window Closed');
        }
        });

        handler.openIframe();
  }
        
 });


 //Code to display selectize field
$(document).on("turbolinks:load", function() {

    var HealthselectizeCallback = null;
    
    $(".health-modal").on("hide.bs.modal", function(e){
        if(HealthselectizeCallback != null) {
            HealthselectizeCallback();
            HealthselectizeCallback = null;
        }
        $("#health_condition_form").trigger("reset");
        $.rails.enableFormElements($("#health_condition_form"));
    });

    $('#health_condition_form').on('submit', function(e) {
        e.preventDefault();
        $.ajax({
            method: "POST",
            url: $(this).attr("action"),
            data: $(this).serialize(),
            success: function(response) {
                HealthselectizeCallback({value: response.id, text: response.condition_name});
                HealthselectizeCallback = null;

                $(".health-modal").modal('toggle');
            }
        })
    })
    $(".health_selectize").selectize({
        create: function(input, callback) {
            HealthselectizeCallback = callback
            $(".health-modal").modal();
            $("#health_condition_condition_name").val(input);
        }
    });
 });


 //Code to send reference manually to the backend for processing

 $(document).on("turbolinks:load", function() {

    $("#reference-submit").click(function(event) {

        var referenceCode = $("#manual-subscribe-reference").val()
        var data = {reference_code: referenceCode}
        $.ajax({
            url: '/admin/paystack_subscribe',
            type: 'POST',
            data: data,
            success: function(data, textStatus, xhr) {
                         content = `<div class="card-body">
                                         <button class="tst2 btn btn-warning">Payment & Subscription Successful! Continue</button>
                                    </div>`
                         $('#paystack-success').append(content)
                         $("#payment-next").fadeIn('fast')
                     },
            error: function() {
                        content = `<p>Recurring Subscription was stil unsuccessful, click back and select an alternate payment method</p>`
                        $("#reference-code").append(content)
                        $("#reference-code").fadeIn('fast')
                  }
        })

    })


 });
