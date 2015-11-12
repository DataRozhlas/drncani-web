style = document.createElement 'style'
    ..innerHTML = ig.data.style
font1 = document.createElement \link
  ..href = 'https://fonts.googleapis.com/css?family=Roboto:100,300,400,400italic,500,700,900&subset=latin,latin-ext'
  ..rel = 'stylesheet'
  ..type = 'text/css'

font2 = document.createElement \link
  ..href = 'https://fonts.googleapis.com/css?family=Roboto+Condensed:700'
  ..rel = 'stylesheet'
  ..type = 'text/css'


document.getElementsByTagName 'head' .0
  ..appendChild style
  ..appendChild font1
  ..appendChild font2
