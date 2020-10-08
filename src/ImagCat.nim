import
  httpClient,
  htmlparser,
  os,
  xmltree,  # To use '$' for XmlNode
  strtabs,  # To access XmlAttributes
  strutils, # To use cmpIgnoreCase
  re,
  asyncdispatch


type
  LinkCheckResult = ref object
    link: string
    state: bool

var urlList: seq[string] = @[]


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


proc getloghtml(url: string): void =
  var client = newHttpClient()
  downloadFile(client, url, "log.html")


proc parsedhtml(url: string): seq[string] =
  var html = loadHtml("log.html")
  for img in html.findAll("img"):
    if img.attrs.hasKey "src":
      var imgURL = checkURIscheme(img.attrs["src"])
      var result = checkLink(imgURL)#画像urlがリンク切れしていないかどうかチェック
      if result.state:
        urlList.add(imgURL)
  return urlList

        

proc downloadImage(list: seq): void =
  var client = newHttpClient()

  for url in urlList:
    let (dir, filename, ext) = splitFile(url)
    try:
      downloadFile(client, url, "output/" & filename & ext)
    except:
      echo "Error: unhandled exception"
  echo "downloaded!!"

var list:seq[string] = @[]
echo "Please give me one URL!"
var url = readLine(stdin)

getloghtml(url)
list = parsedhtml(url)
downloadImage(list)


