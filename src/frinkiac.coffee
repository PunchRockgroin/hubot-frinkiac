# Description:
#   Frinkiac Search and Meme generator
#
# Dependencies:
#   None
#
# Configuration:
#  HUBOT_FRINKIAC_MEMEIFY - True to place meme with caption on the image (Default: true)
#  HUBOT_FRINKIAC_RANDOMIZE - True to randomize the selected image (Default: false)
#  HUBOT_FRINKIAC_RESPOND_ONLY - True to respond only when directly addressed, false to respond to all messages (Default: false)
#
# Commands:
#   (hubot )frinkiac me <query> - Searches for the query in the Frinkiac database and responds with an image/meme. Respond/hear controlled by configuration.
#
# Notes:
#   Check out frinkiac.com, because it's pretty awesome!
#
# Author:
#   github.com/morinap


class Frinkiac
  # Init some URLS
  search_url: 'https://frinkiac.com/api/search?q='
  img_url: 'https://frinkiac.com/img'
  caption_url: 'https://frinkiac.com/api/caption'
  meme_url: 'https://frinkiac.com/meme'

  # Init some other settings
  max_line_length: 25
  regex: /frinkiac me.*?([a-zA-Z0-9_\-\.\s]*)$/i

  constructor: (robot, memeify, randomize)->
    @robot = robot
    @memeify = memeify
    @randomize = randomize

  # Helper for URL component generation
  encode: (str) =>
    return encodeURIComponent(str).replace(/%20/g, '+')

  # Determines actual meme text, with appropriate line breaks
  calculateMemeText: (subtitles) =>
    subtitles = subtitles.map((x) -> return x.Content).join(' ').split(' ')

    line = '';
    lines = [];
    while (subtitles.length > 0)
      word = subtitles.shift()
      if ((line.length == 0) || (line.length + word.length <= @max_line_length))
        line += ' ' + word
      else
        lines.push(line);
        line = '';
        subtitles.unshift(word);

    if (line.length > 0)
      lines.push(line);

    return lines.join('\n');

  # Handle response from initial frinkiac search
  handleImageGet: (err, res, body) =>
    if (err)
      @msg.send "ERROR: #{err}"

    images = JSON.parse(body)
    if images?.length > 0
      image = if @randomize then @msg.random images else images[0]
      if !@memeify
        @msg.send "#{@img_url}/#{image.Episode}/#{image.Timestamp}.jpg"
      else
        @robot.http("#{@caption_url}?e=#{image.Episode}&t=#{image.Timestamp}").get() @handleCaptionGet
    else
      @msg.send 'http://bukk.it/fail.jpg'

  # Handle response from caption API request
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

  # Handle message
  msgHandler: (msg) =>
    @msg = msg
    @query = @msg.match[1]
    @robot.http("#{@search_url}#{this.encode(@query)}").get() @handleImageGet

module.exports = (robot) ->
  # Grab settings
  memeify = if process.env.HUBOT_FRINKIAC_MEMEIFY == 'false' then false else true
  randomize = if process.env.HUBOT_FRINKIAC_RANDOMIZE == 'true' then true else false
  respond = if process.env.HUBOT_FRINKIAC_RESPOND_ONLY == 'true' then true else false

  # Create instance
  frinkiac = new Frinkiac(robot, memeify, randomize)

  # Hear or respond
  if respond
    robot.respond frinkiac.regex, frinkiac.msgHandler
  else
    robot.hear frinkiac.regex, frinkiac.msgHandler

