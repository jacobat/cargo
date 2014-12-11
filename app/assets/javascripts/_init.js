(function(){
  $(document).ready(function(){
    var containers_length = $('.docker-container').length;
    var $viewbtns = $('.view-btn'),
        $views = $('.view');
    $('.states').addClass('ready');

    $viewbtns.click(function(e){
      e.preventDefault();
      console.log('press');
      $viewbtns.toggleClass('active');
      $views.toggleClass('active');
    });
  });
})();
