(function($) {
    $.fn.randomize = function(childElem) {
        function shuffle(o) {
            for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
            return o;
        };
        return this.each(function() {
            var $this = $(this);
            var elems = $this.children(childElem);

            shuffle(elems);

            $this.detach(childElem);

            for(var i=0; i < elems.length; i++) {
                $this.append(elems[i]);
            }
        });
    }
})(jQuery);
