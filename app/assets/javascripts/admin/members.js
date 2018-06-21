 
//Code to display subscription plan with selectize
$(document).on("turbolinks:load", function() {
    $(".subscription-selectize").selectize({
        sortField: 'text'
    });
 });
