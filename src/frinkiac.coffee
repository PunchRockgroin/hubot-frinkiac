# Description:
#   Frinkiac Search


class Frinkiac
  search_url: "https://www.frinkiac.com/api/search?q="
  img_url: "https://www.frinkiac.com/img"
  caption_url: "https://www.frinkiac.com/api/caption"
  meme_url: "https://www.frinkiac.com/meme/S01E06/831112.jpg?lines=+%E2%99%AA+I%27M+THE+SADDEST+KID+IN%0A+GRADE+NUMBER+TWO.+%E2%99%AA"
  meme_url: "https://www.frinkiac.com/meme"
  max_line_length: 25
  regex: /frinkiac me.*?([a-zA-Z0-9_\-\.\s]*)$/i

  constructor: (robot, memeify)->
    @robot = robot
    @memeify = memeify

  encode: (str) =>
    return encodeURIComponent(str).replace(/%20/g, "+")

  calculateMemeText: (subtitles) =>
    subtitles = subtitles.map((x) -> return x.Content).join(" ").split(" ")

    line = "";
    lines = [];
    while (subtitles.length > 0)
      word = subtitles.shift()
      if ((line.length == 0) || (line.length + word.length <= @max_line_length))
        line += " " + word
      else
        lines.push(line);
        line = "";
        subtitles.unshift(word);

    if (line.length > 0)
      lines.push(line);

    return lines.join("\n");

  handleImageGet: (err, res, body) =>
    if (err)
      @msg.send "ERROR: #{err}"

    images = JSON.parse(body)
    if images?.length > 0
      image = @msg.random images
      if !@memeify
        @msg.send "#{@img_url}/#{image.Episode}/#{image.Timestamp}.jpg"
      else
        @robot.http("#{@caption_url}?e=#{image.Episode}&t=#{image.Timestamp}").get() @handleCaptionGet
    else
      @msg.send "http://bukk.it/fail.jpg"

  handleCaptionGet: (err, res, body) =>
    if (err)
      @msg.send "ERROR: #{err}"

    data = JSON.parse(body)
    ep = data.Frame.Episode
    stamp = data.Frame.Timestamp
    if data.Subtitles?.length > 0
      subtitles = this.encode(this.calculateMemeText(data.Subtitles))
      @msg.send "#{@meme_url}/#{ep}/#{stamp}.jpg?lines=#{subtitles}#.png"
    else
      @msg.send "#{@img_url}/#{ep}/#{stamp}.jpg"

  responseHandler: (msg) =>
    @msg = msg
    @query = @msg.match[1]
    @robot.http("#{@search_url}#{this.encode(@query)}").get() @handleImageGet

module.exports = (robot) ->
  frinkiac = new Frinkiac(robot, true)
  robot.hear frinkiac.regex, frinkiac.responseHandler

