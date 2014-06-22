# Htmless

[![Build Status](https://travis-ci.org/pitr-ch/htmless.png?branch=master)](https://travis-ci.org/pitr-ch/htmless)

**Fast** and **extensible** HTML5 builder written in pure **Ruby**, replaces templating engines without loosing speed bringing back the power of OOP.

-   Documentation: <http://blog.pitr.ch/htmless>
-   Source: <https://github.com/pitr-ch/htmless>
-   Blog: <http://blog.pitr.ch/blog/categories/htmless/>

## Quick syntax example

```ruby
Htmless::Formatted.new.go_in do
  html5
  html do
    head { title 'my_page' }
    body do
      div.content! do
        p.centered "my page's content"
      end
    end
  end
end.to_html
```

returns

```html
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>my_page</title>
  </head>
  <body>
    <div id="content">
      <p class="centered">my page's content</p>
    </div>
  </body>
</html>
```
