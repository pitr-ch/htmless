module Htmless
  module Data

    single_tags = %w[area base br col embed hr img input link meta param]

    double_tags = %w[
          a abbr article aside audio address b bdo blockquote body button canvas caption cite code colgroup command
          datalist dd del details dfn div dl dt em fieldset figure footer form h1 h2 h3 h4 h5 h6 head header hgroup html
          i iframe ins keygen kbd label legend li map mark meter nav noscript object ol optgroup option p pre progress
          q ruby rt rp s samp script section select small source span strong style sub sup table tbody td textarea tfoot
          th thead time title tr u ul var video]

    global_attributes = %w[
          accesskey class contenteditable contextmenu dir draggable dropzone hidden id lang
          spellcheck style tabindex title onabort onblur oncanplay oncanplaythrough onchange
          onclick oncontextmenu oncuechange ondblclick ondrag ondragend ondragenter ondragleave
          ondragover ondragstart ondrop ondurationchange onemptied onended onerror onfocus oninput
          oninvalid onkeydown onkeypress onkeyup onload onloadeddata onloadedmetadata onloadstart
          onmousedown onmousemove onmouseout onmouseover onmouseup onmousewheel onpause onplay
          onplaying onprogress onratechange onreadystatechange onreset onscroll onseeked onseeking
          onselect onshow onstalled onsubmit onsuspend ontimeupdate onvolumechange onwaiting role ]

    tag_attributes = {
        :a          => %w[href target ping rel media hreflang type],
        :abbr       => %w[], :address => %w[],
        :area       => %w[alt coords shape href target ping rel media hreflang type],
        :article    => %w[], :aside => %w[],
        :audio      => %w[src preload autoplay mediagroup loop controls],
        :b          => %w[],
        :base       => %w[href target],
        :bdi        => %w[], :bdo => %w[],
        :blockquote => %w[cite],
        :body       => %w[onafterprint onbeforeprint onbeforeunload onblur onerror onfocus onhashchange onload
                            onmessage onoffline ononline onpagehide onpageshow onpopstate onredo onresize onscroll
                            onstorage onundo onunload],
        :br         => %w[],
        :button     => %w[autofocus disabled form formaction formenctype formmethod formnovalidate formtarget name
                            type value],
        :canvas     => %w[width height],
        :caption    => %w[], :cite => %w[], :code => %w[], :col => %w[span],
        :colgroup   => %w[span],
        :command    => %w[type label icon disabled checked radiogroup],
        :datalist   => %w[option],
        :dd         => %w[],
        :del        => %w[cite datetime],
        :details    => %w[open],
        :dfn        => %w[], :div => %w[], :dl => %w[], :dt => %w[], :em => %w[],
        :embed      => %w[src type width height],
        :fieldset   => %w[disabled form name],
        :figcaption => %w[], :figure => %w[], :footer => %w[],
        :form       => %w[action autocomplete enctype method name novalidate target accept_charset],
        :h1         => %w[], :h2 => %w[], :h3 => %w[], :h4 => %w[], :h5 => %w[], :h6 => %w[], :head => %w[],
        :header     => %w[], :hgroup => %w[], :hr => %w[],
        :html       => %w[manifest],
        :i          => %w[],
        :iframe     => %w[src srcdoc name sandbox seamless width height],
        :img        => %w[alt src usemap ismap width height],
        :input      => %w[accept alt autocomplete autofocus checked dirname disabled form formaction formenctype
                            formmethod formnovalidate formtarget height list max maxlength min multiple name pattern
                            placeholder readonly required size src step type value width],
        :ins        => %w[cite datetime],
        :kbd        => %w[],
        :keygen     => %w[autofocus challenge disabled form keytype name],
        :label      => %w[form for],
        :legend     => %w[],
        :li         => %w[value],
        :link       => %w[href rel media hreflang type sizes],
        :map        => %w[name],
        :mark       => %w[],
        :menu       => %w[type label],
        :meta       => %w[name content charset http_equiv],
        :meter      => %w[value min max low high optimum form],
        :nav        => %w[], :noscript => %w[],
        :object     => %w[data type name usemap form width height],
        :ol         => %w[reversed start],
        :optgroup   => %w[disabled label],
        :option     => %w[disabled label selected value],
        :output     => %w[for form name],
        :p          => %w[],
        :param      => %w[name value],
        :pre        => %w[],
        :progress   => %w[value max form],
        :q          => %w[cite],
        :rp         => %w[], :rt => %w[], :ruby => %w[], :s => %w[], :samp => %w[],
        :script     => %w[src async defer type charset],
        :section    => %w[],
        :select     => %w[autofocus disabled form multiple name required size],
        :small      => %w[],
        :source     => %w[src type media],
        :span       => %w[], :strong => %w[],
        :style      => %w[media type scoped],
        :sub        => %w[], :summary => %w[], :sup => %w[],
        :table      => %w[border],
        :tbody      => %w[],
        :td         => %w[colspan rowspan headers],
        :textarea   => %w[autofocus cols disabled form maxlength name placeholder readonly required rows wrap],
        :tfoot      => %w[],
        :th         => %w[colspan rowspan headers scope],
        :thead      => %w[],
        :time       => %w[datetime pubdate],
        :title      => %w[], :tr => %w[],
        :track      => %w[default kind label src srclang],
        :u          => %w[], :ul => %w[], :var => %w[],
        :video      => %w[src poster preload autoplay mediagroup loop controls width height],
        :wbr        => %w[]
    }

    boolean_attributes = {
        :all      => %w{hidden draggable iscontenteditable spellcheck},
        :style    => %w{scoped},
        :script   => %w{async defer},
        :ol       => %w{reversed},
        :time     => %w{pubdate},
        :img      => %w{ismap},
        :iframe   => %w{seamless},
        :track    => %w{default},
        :audio    => %w{autoplay loop controls},
        :video    => %w{autoplay loop controls},
        :form     => %w{novalidate},
        :fieldset => %w{disabled},
        :input    => %w{autofocus checked disabled formnovalidate multiple readonly
                           required},
        :button   => %w{autofocus disabled formnovalidate},
        :select   => %w{autofocus disabled multiple required},
        :optgroup => %w{disabled},
        :option   => %w{disabled selected},
        :textarea => %w{autofocus disabled readonly required},
        :keygen   => %w{autofocus disabled},
        :details  => %w{open},
        :command  => %w{disabled checked}
    }

    enumerable_attributes = {
        'all'      => [{ 'dir' => %w{ltr rtl auto} }],
        'meta'     => [{ 'http-equiv' => %w{content-language content-type default-style refresh set-cookie} }],
        'track'    => [{ 'kind' => %w{subtitles captions descriptions chapters metadata} }],
        'video'    => [{ 'preload' => %w{none metadata auto} }],
        'area'     => [{ 'shape' => %w{circle default poly rect} }],
        'th'       => [{ 'scope' => %w{row col rowgroup colgroup auto} }],
        'form'     => [{ 'autocomplete' => %w{on off} }], # ala boolean
        'input'    => [{ 'type' => %w{hidden text search tel url email password datetime date month week time
                                        datetime-local number range color checkbox radio file submit image reset button} },
                       'autocomplete' => %w{on off}], # ommited for default?,
        'button'   => [{ 'type' => %w{submit reset button} }],
        'textarea' => [{ 'wrap' => %w{soft hard} }]
        # TODO
    }

    attribute_type = lambda do |tag, attr|
      if boolean_attributes[:all].include?(attr) || (boolean_attributes[tag] && boolean_attributes[tag].include?(attr))
        :boolean
      else
        :string
      end
    end

    HTML5 = OpenStruct.new(
        :abstract_attributes => global_attributes.map { |attr| Attribute.new(attr.to_sym, attribute_type[name, attr]) },

        :single_tags         => single_tags.map(&:to_sym).map do |name|
          Tag.new(name,
                  tag_attributes[name].map do |attr|
                    Attribute.new(attr.to_sym, attribute_type[name, attr])
                  end)
        end,

        :double_tags         => double_tags.map(&:to_sym).map do |name|
          Tag.new(name,
                  tag_attributes[name].map do |attr|
                    Attribute.new(attr.to_sym, attribute_type[name, attr])
                  end)
        end)

    #require 'pp'
    #pp HTML5
    #pp HTML5.abstract_attributes
    #pp HTML5.simple_tags
  end
end
