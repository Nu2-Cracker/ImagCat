import
  httpClient,
  htmlparser,
  os,
  xmltree,  # To use '$' for XmlNode
  strtabs,  # To access XmlAttributes
  strutils, # To use cmpIgnoreCase
  re


type
  LinkCheckResult = ref object
    link: string
    state: bool

proc checkLink(link: string): LinkCheckResult =
  var client = newHttpClient()
  try:
    return LinkCheckResult(link:link, state:client.get(link).code == Http200)
  except:
    return LinkCheckResult(link:link, state:false)

proc checkURIscheme(link: string): string =
  if match(link, re"^(http)"):
    return link

  return "https:" & link



proc getImage(url: string): bool =
  var client = newHttpClient()
  downloadFile(client, url, "log.html")
  var html = loadHtml("log.html")

  for img in html.findAll("img"):
    if img.attrs.hasKey "src":
      let (dir, filename, ext) = splitFile(img.attrs["src"])
      var imgURL = checkURIscheme(img.attrs["src"])
      var result = checkLink(imgURL)#画像urlがリンク切れしていないかどうかチェック
      echo result.link
      echo result.state

      if result.state:
        var filename = filename & ".png"
        downloadFile(client, imgURL, "output/" & filename)


  echo "downloaded!!"




echo "Please give me one URL!"
var url = readLine(stdin)

discard getImage(url)
